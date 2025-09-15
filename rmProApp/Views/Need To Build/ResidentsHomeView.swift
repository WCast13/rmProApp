//
//  ResidentsHomeView.swift
//  rmProApp
//
//  Created by William Castellano on 4/3/25.
//

import SwiftUI

struct ResidentsHomeView: View {
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var tenantDataManager: TenantDataManager
    @State private var searchText: String = ""
    @State private var selectedFilter: ResidentFilter = .all
    @State private var isShowingFilters = false
    @State private var showDocumentsAlert = false
    
    enum ResidentFilter: String, CaseIterable, Identifiable {
        case all = "All Residents"
        case haven = "Haven"
        case pembroke = "Pembroke"
        case delinquent = "Delinquent"
        case fireProtectionGroup = "Fire Protection Group 25"
        case fireProtectionGroup26 = "Fire Protection Group 26"
        case ptpA = "Prospectus A"
        case ptpWater = "Prospectus B - Lake"
        case ptpDry = "Prospectus B - Dry"
        case loans = "Loans"
        
        var id: String { rawValue }
    }
    
    private var filteredResidents: [WCLeaseTenant] {
        let residents = tenantDataManager.allUnitTenants
        let searchText = searchText.lowercased()
        
        return residents.filter { tenant in
            let matchesSearch = searchText.isEmpty || tenant.name?.lowercased().contains(searchText) == true || tenant.lease?.unit?.name?.lowercased().contains(searchText) == true
            
            switch selectedFilter {
            case .all:
                return matchesSearch
            case .haven:
                return matchesSearch && tenant.propertyID == 3
            case .pembroke:
                return matchesSearch && tenant.propertyID == 12
            case .delinquent:
                return matchesSearch && (tenant.openBalance ?? 0) > 0
            case .fireProtectionGroup:
                return matchesSearch && tenant.udfs?.filter { $0.userDefinedFieldID == 59 }.first?.value == "Yes"
            case .fireProtectionGroup26:
                return matchesSearch && tenant.udfs?.filter { $0.userDefinedFieldID == 64 }.first?.value == "Yes"
            case .ptpA:
                return matchesSearch && tenant.lease?.unit?.unitType?.name == "PTP- Pros A"
            case .ptpWater:
                return matchesSearch && tenant.lease?.unit?.unitType?.name == "PTP- Pros B - Lake"
            case .ptpDry:
                return matchesSearch && tenant.lease?.unit?.unitType?.name == "PTP- Pros B - Dry"
            case .loans:
                return matchesSearch && tenant.loans?.count ?? 0 > 0
            }
        }
        .sorted { $0.lease?.unit?.name ?? "" < $1.lease?.unit?.name ?? "" }
    }
    
    var body: some View {
        
        // Background Gradient
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.gray.opacity(0.2), .white]), startPoint: .topLeading, endPoint: .bottom)
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // Header
                HStack {
                    Text("Residents")
                        .font(.title)
                        .bold()
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: { isShowingFilters.toggle() }) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                            .padding(10)
                            .background(Circle().fill(Color.white.opacity(0.8)))
                            .shadow(radius: 2)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
            
                Text("Resident Count: \(filteredResidents.count)")

                
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search by Name or Unit", text: $searchText)
                        .textFieldStyle(.plain)
                        .font(.body)
                        .frame(minHeight: 50)
                        .padding(.horizontal)
                }
                
                // Filter Chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(ResidentFilter.allCases) { filter in
                            FilterChipView(title: filter.rawValue, isSelected: selectedFilter == filter) {
                                withAnimation(.easeInOut) {
                                    selectedFilter = filter
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                }
                
                // Residents List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredResidents, id: \.id) { tenant in
                            ResidentCardV2(tenant: tenant, navigationPath: $navigationPath)
                                .padding(.horizontal)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal)
                
            }
        }
        .sheet(isPresented: $isShowingFilters) {
            FilterSheet(selectedFilter: $selectedFilter)
                .presentationDetents([.medium])
        }
        .alert("Labels Created", isPresented: $showDocumentsAlert) {
            Button("Go to Documents") {
                navigationPath.append(AppDestination.documents)
            }
            Button("Stay Here", role: .cancel) { }
        } message: {
            Text("Labels and PS3877 forms have been created for Haven and Pembroke residents. Would you like to view them in Documents?")
        }
        .navigationBarBackButtonHidden(false)
    }
}


// MARK: View Helpers
// Filter Chip
struct FilterChipView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : .gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(.capsule)
        }
    }
}

// Resident Card (legacy, kept for reference; not used in the list anymore)
struct ResidentCard : View {
    let tenant: WCLeaseTenant
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        Button(action: {
            navigationPath.append(AppDestination.residentDetails((tenant)))
        }) {
            HStack(alignment: .top, spacing: 12) {
                //Initials Circle
                ZStack {
                    Circle()
                        .fill( LinearGradient(colors: [.blue, .black], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 50, height: 50)
                    Text(initials(from: tenant.name ?? "N/A"))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                // Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(tenant.name ?? "N/A")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.red)
                    
                    if let unitName = tenant.lease?.unit?.name {
                        Text("Unit: \(unitName)")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.green)
                    }
                    
                    if let balance = tenant.openBalance, balance > 0 {
                        // Avoid deprecated interpolation with Decimal by using a localized format style.
                        // We bridge Decimal to NSDecimalNumber/NSNumber for format style support.
                        let number = balance as NSDecimalNumber
                        (Text("Balance: ") + Text(number as Decimal.FormatStyle.Currency.FormatInput, format: .currency(code: "USD")))
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.red)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.system(size: 16))
            }
        }
        .padding()
        .background( RoundedRectangle(cornerRadius: 12)
            .fill(Color.white)
            .shadow(radius: 2))
    }
}

// New Resident Card with Fire Protection toggle
struct ResidentCardV2: View {
    let tenant: WCLeaseTenant
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject private var tenantDataManager: TenantDataManager
    
    @State private var isFireProtMember: Bool = false
    @State private var isUpdatingFireProt: Bool = false
    @State private var updateError: Bool = false
    
    private var initialsText: String {
        initials(from: tenant.name ?? "N/A")
    }
    
    private var unitNameText: String? {
        tenant.lease?.unit?.name
    }
    
    private var positiveBalanceText: Text? {
        guard let balance = tenant.openBalance, balance > 0 else { return nil }
        let number = balance as NSDecimalNumber
        let formatted = Text(number as Decimal.FormatStyle.Currency.FormatInput, format: .currency(code: "USD"))
        return Text("Balance: ") + formatted
    }
    
    var body: some View {
        Button(action: {
            navigationPath.append(AppDestination.residentDetails(tenant))
        }) {
            HStack(alignment: .center, spacing: 12) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.blue, .black], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 50, height: 50)
                    Text(initialsText)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                // Details
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(tenant.name ?? "N/A")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        
                        Spacer(minLength: 8)
                        
                        // Fire Protection toggle button
                        fireProtectionButton
                    }
                    
                    if let unitName = unitNameText {
                        Text("Unit: \(unitName)")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    
                    if let balanceText = positiveBalanceText {
                        balanceText
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.red)
                    }
                }
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.system(size: 16))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(.plain)
        .onAppear {
//            isFireProtMember = computeFireProtectionMembership(from: tenant)
        }
        .alert("Update Failed", isPresented: $updateError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("We couldn't update Fire Protection Group membership. Please try again.")
        }
    }
    
    private var fireProtectionButton: some View {
        Button {
            Task {
                await toggleFireProtection()
            }
        } label: {
            HStack(spacing: 6) {
                if isUpdatingFireProt {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: isFireProtMember ? "shield.checkerboard" : "shield")
                        .imageScale(.small)
                }
                Text("Fire Prot.")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isFireProtMember ? Color.green.opacity(0.9) : Color.gray.opacity(0.3))
            )
            .foregroundColor(isFireProtMember ? .white : .primary)
        }
        .buttonStyle(.plain)
        .disabled(isUpdatingFireProt || tenant.tenantID == nil)
        .accessibilityLabel("Toggle Fire Protection Group membership")
        .accessibilityValue(isFireProtMember ? "Member" : "Not a member")
    }
    
    private func computeFireProtectionMembership(from tenant: WCLeaseTenant) -> Bool {
        guard let udfs = tenant.udfs else { return false }
        // UDF 59: "HEI- Fire Protection Approved 2025" with "Yes"/"No"
        return udfs.contains { $0.userDefinedFieldID == 59 && ($0.value?.localizedCaseInsensitiveCompare("Yes") == .orderedSame) }
    }
    
    private func toggleFireProtection() async {
        guard let id = tenant.tenantID else { return }
        let isMember = tenant.udfs?.contains { $0.userDefinedFieldID == 59 }.description == "No" ? false : true
       
        TenantDataManager.shared.updateFireProtectionGroup(tenantID: id, isMember: isMember)
    }
}

private func initials(from name: String) -> String {
   let components = name.split(separator: " ")
   let initials = components.prefix(2).map { $0.first?.uppercased() ?? "" }.joined()
   return initials.isEmpty ? "N/A" : initials
}

struct FilterSheet: View {
    @Binding var selectedFilter: ResidentsHomeView.ResidentFilter
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(ResidentsHomeView.ResidentFilter.allCases) { filter in
                   
                    Button(action: {
                      selectedFilter = filter
                        dismiss()
                    }) {
                        HStack {
                            Text(filter.rawValue)
                                .foregroundColor(.primary)
                            Spacer()
                            if selectedFilter == filter {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}
