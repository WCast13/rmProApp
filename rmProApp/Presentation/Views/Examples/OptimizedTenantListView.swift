//
//  OptimizedTenantListView.swift
//  rmProApp
//
//  Example showing how to use request coalescing and prefetching
//

import SwiftUI

struct OptimizedTenantListView: View {
    @StateObject private var tenantManager = TenantDataManager.shared
    @StateObject private var prefetchManager = PrefetchManager.shared
    @State private var selectedTenantID: String?
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredTenants) { tenant in
                    TenantRowView(tenant: tenant)
                        .onAppear {
                            // Prefetch when row appears (user might tap it)
                            handleRowAppear(tenant: tenant)
                        }
                        .onTapGesture {
                            handleTenantTap(tenant: tenant)
                        }
                }
            }
            .searchable(text: $searchText)
            .onChange(of: searchText) { newValue in
                // Record search for predictive prefetching
                if !newValue.isEmpty {
                    prefetchManager.recordUserAction(.searchedFor(query: newValue))
                }
            }
            .navigationTitle("Tenants")
            .task {
                await loadTenants()
            }
            .onAppear {
                // Prefetch based on current route
                prefetchManager.prefetchForRoute(.tenantList)
            }
        }
    }
    
    private var filteredTenants: [RMTenant] {
        if searchText.isEmpty {
            return tenantManager.allTenants
        } else {
            return tenantManager.allTenants.filter {
                $0.name?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
    }
    
    private func loadTenants() async {
        // This will automatically use request coalescing
        // Multiple simultaneous calls will be merged into one
        await tenantManager.fetchTenants()
    }
    
    private func handleRowAppear(tenant: RMTenant) {
        guard let tenantID = tenant.tenantID else { return }
        
        // Prefetch tenant details in background
        prefetchManager.prefetchTenantDetails(tenantID: String(tenantID))
        
        // Prefetch adjacent tenants for smooth scrolling
        prefetchManager.prefetchAdjacentTenants(
            currentTenantID: String(tenantID),
            in: filteredTenants
        )
    }
    
    private func handleTenantTap(tenant: RMTenant) {
        guard let tenantID = tenant.tenantID else { return }
        
        selectedTenantID = String(tenantID)
        
        // Record user action for learning
        prefetchManager.recordUserAction(.openedTenantDetail(tenantID: String(tenantID)))
        
        // Prefetch transactions for detail view
        prefetchManager.prefetchTransactions(for: String(tenantID))
    }
}

struct TenantRowView: View {
    let tenant: RMTenant
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(tenant.name ?? "Unknown")
                    .font(.headline)
                
                if let unit = tenant.leases?.first?.unit?.name {
                    Text("Unit: \(unit)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if let balance = tenant.balance, balance > 0 {
                Text("$\(balance, specifier: "%.2f")")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Property-Specific View with Prefetching
struct PropertyTenantsView: View {
    let propertyID: Int
    @StateObject private var tenantManager = TenantDataManager.shared
    @StateObject private var prefetchManager = PrefetchManager.shared
    
    var propertyTenants: [RMTenant] {
        switch propertyID {
        case 1: return tenantManager.havenTenants
        case 3: return tenantManager.pembrokeTenants
        default: return []
        }
    }
    
    var body: some View {
        List(propertyTenants) { tenant in
            TenantRowView(tenant: tenant)
        }
        .onAppear {
            // Prefetch property data
            prefetchManager.prefetchForRoute(.propertyView(propertyID: propertyID))
            
            // Record user viewing property
            prefetchManager.recordUserAction(.viewedProperty(propertyID: propertyID))
        }
    }
}

// MARK: - Detail View Using Cached Data
struct OptimizedTenantDetailView: View {
    let tenantID: String
    @StateObject private var tenantManager = TenantDataManager.shared
    @State private var tenant: RMTenant?
    @State private var isLoading = false
    
    var body: some View {
        Group {
            if let tenant = tenant {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Basic Info (loaded from cache)
                        TenantInfoSection(tenant: tenant)
                        
                        // Transactions (prefetched)
                        TransactionsSection(tenant: tenant)
                        
                        // Addresses & Contacts (loaded on demand)
                        ContactsSection(tenant: tenant)
                    }
                    .padding()
                }
            } else if isLoading {
                ProgressView("Loading...")
            } else {
                Text("Tenant not found")
            }
        }
        .task {
            await loadTenant()
        }
    }
    
    private func loadTenant() async {
        isLoading = true
        
        // This will use cached data if available due to prefetching
        // Request coalescing prevents duplicate calls if already loading
        tenant = await tenantManager.fetchSingleTenant(tenantID: tenantID)
        
        isLoading = false
    }
}

// MARK: - Supporting Views
struct TenantInfoSection: View {
    let tenant: RMTenant
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(tenant.name ?? "Unknown")
                .font(.largeTitle)
                .bold()
            
            if let lease = tenant.leases?.first {
                Label("Unit: \(lease.unit?.name ?? "N/A")", systemImage: "house")
                Label("Move In: \(lease.moveInDate ?? "N/A")", systemImage: "calendar")
            }
            
            if let balance = tenant.balance {
                Label("Balance: $\(balance, specifier: "%.2f")", systemImage: "dollarsign.circle")
                    .foregroundColor(balance > 0 ? .red : .green)
            }
        }
    }
}

struct TransactionsSection: View {
    let tenant: RMTenant
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Recent Transactions")
                .font(.headline)
            
            if let charges = tenant.charges, !charges.isEmpty {
                ForEach(charges.prefix(5), id: \.chargeID) { charge in
                    HStack {
                        Text(charge.description ?? "Charge")
                        Spacer()
                        Text("$\(charge.amount ?? 0, specifier: "%.2f")")
                    }
                    .font(.caption)
                }
            } else {
                Text("No recent transactions")
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct ContactsSection: View {
    let tenant: RMTenant
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Contacts")
                .font(.headline)
            
            if let contacts = tenant.contacts, !contacts.isEmpty {
                ForEach(contacts, id: \.contactID) { contact in
                    VStack(alignment: .leading) {
                        Text("\(contact.firstName ?? "") \(contact.lastName ?? "")")
                        if let email = contact.email {
                            Text(email)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            } else {
                Text("No contacts")
                    .foregroundColor(.secondary)
            }
        }
    }
}