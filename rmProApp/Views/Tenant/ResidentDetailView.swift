//
//  ResidentDetailView.swift
//  rmProApp
//
//  Created by William Castellano on 4/3/25.
//

import SwiftUI

struct ResidentDetailView: View {
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var tenantDataManager: TenantDataManager
    @State var tenant: WCLeaseTenant
    
    @State private var isLoading = false
    @State private var selectedTab = 0
    @State private var showingActionSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Section with Resident Info
                ResidentHeaderView(tenant: tenant)
                
                // Quick Actions Section
                QuickActionsView(tenant: tenant, showingActionSheet: $showingActionSheet)
                
                // Tabbed Content
                VStack {
                    // Tab Selector
                    Picker("Sections", selection: $selectedTab) {
                        Text("Overview").tag(0)
                        Text("Transactions").tag(1)
                        Text("Contacts").tag(2)
                        Text("Lease Info").tag(3)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Tab Content
                    Group {
                        switch selectedTab {
                        case 0:
                            OverviewTabView(tenant: tenant)
                        case 1:
                            TransactionsTabView(tenant: tenant)
                        case 2:
                            ContactsTabView(tenant: tenant)
                        case 3:
                            LeaseInfoTabView(tenant: tenant)
                        default:
                            OverviewTabView(tenant: tenant)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle("Resident Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                isLoading = true
                await loadResidentData()
                isLoading = false
            }
        }
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(
                title: Text("Quick Actions"),
                buttons: [
                    .default(Text("Add Charge")) { /* TODO: Implement */ },
                    .default(Text("Add Payment")) { /* TODO: Implement */ },
                    .default(Text("Create Violation")) { /* TODO: Implement */ },
                    .default(Text("Add Note")) { /* TODO: Implement */ },
                    .cancel()
                ]
            )
        }
        .overlay(
            Group {
                if isLoading {
                    ProgressView("Loading resident data...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground).opacity(0.8))
                }
            }
        )
    }
    
    private func loadResidentData() async {
        await processTenantTransactions()
        
        // Load additional data if missing
        async let addresses: [RMAddress] = tenant.addresses?.isEmpty != false ? tenantDataManager.fetchAddresses(tenant: tenant) : tenant.addresses ?? []
        async let contacts: [RMContact] = tenant.contacts?.isEmpty != false ? tenantDataManager.fetchContacts(tenant: tenant) : tenant.contacts ?? []
        
        tenant.addresses = await addresses
        tenant.contacts = await contacts
    }
    
    private func processTenantTransactions() async {
        let transactionData = await tenantDataManager.fetchSingleTenantTransactions(tenantID: String(tenant.tenantID ?? 0))
        
        if let charges = transactionData?.charges, !charges.isEmpty,
           let payments = transactionData?.payments, !payments.isEmpty,
           let paymentReversals = transactionData?.paymentReversals {
            
            tenant.charges = charges
            tenant.payments = payments
            tenant.paymentReversals = paymentReversals
            
            let transactions = await TenantTransactionsManager.shared.processTransactions(tenant: tenant)
            tenant.transactions = transactions
        }
    }
}

// MARK: - Header View
struct ResidentHeaderView: View {
    let tenant: WCLeaseTenant
    
    var body: some View {
        VStack(spacing: 12) {
            // Resident Name and Unit
            HStack {
                VStack(alignment: .leading) {
                    Text(fullName)
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                    
                    Text("Unit \(tenant.unit?.name ?? "N/A")")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Balance
                VStack(alignment: .trailing) {
                    Text("Balance")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(balanceFormatted)
                        .font(.title3.bold())
                        .foregroundColor(balanceColor)
                }
            }
            
            // Status Indicators
            HStack(spacing: 12) {
                StatusBadge(title: "Move In", value: tenant.lease?.moveInDate ?? "N/A", color: .blue)
                StatusBadge(title: "Unit Type", value: tenant.unit?.unitType?.name ?? "N/A", color: .green)
                StatusBadge(title: "Security Deposit", value: "$\(tenant.securityDepositHeld ?? 0)", color: .orange)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var fullName: String {
        let first = tenant.firstName ?? ""
        let last = tenant.lastName ?? ""
        return "\(first) \(last)".trimmingCharacters(in: .whitespaces)
    }
    
    private var balanceFormatted: String {
        if let balance = tenant.balance {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            return formatter.string(from: NSDecimalNumber(decimal: balance)) ?? "$0.00"
        }
        return "$0.00"
    }
    
    private var balanceColor: Color {
        guard let balance = tenant.balance else { return .primary }
        return balance > 0 ? .red : (balance < 0 ? .green : .primary)
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.caption.bold())
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

// MARK: - Quick Actions
struct QuickActionsView: View {
    let tenant: WCLeaseTenant
    @Binding var showingActionSheet: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 12) {
                ActionButton(title: "Add Charge", icon: "plus.circle", color: .red) {
                    showingActionSheet = true
                }
                
                ActionButton(title: "Add Payment", icon: "creditcard", color: .green) {
                    showingActionSheet = true
                }
                
                ActionButton(title: "Create Note", icon: "note.text", color: .blue) {
                    showingActionSheet = true
                }
                
                ActionButton(title: "Violation", icon: "exclamationmark.triangle", color: .orange) {
                    showingActionSheet = true
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Action Button
struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Overview Tab
struct OverviewTabView: View {
    let tenant: WCLeaseTenant
    
    var body: some View {
        VStack(spacing: 16) {
            InfoGrid(pairs: [
                ("Tenant ID", "\(tenant.tenantID ?? 0)"),
                ("Property ID", "\(tenant.propertyID ?? 0)"),
                ("Move In Date", tenant.lease?.moveInDate ?? "N/A"),
                ("Move Out Date", tenant.lease?.moveOutDate ?? "N/A"),
                ("Primary Contact", tenant.primaryContact?.firstName ?? "N/A"),
                ("Phone", primaryPhone),
                ("Email", tenant.primaryContact?.email ?? "N/A"),
                ("Company", tenant.isCompany == true ? "Yes" : "No")
            ])
            
            // Recent Activity Summary
            VStack(alignment: .leading, spacing: 8) {
                Text("Recent Activity")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let transactions = tenant.transactions, !transactions.isEmpty {
                    ForEach(transactions.prefix(3), id: \.transactionDate) { transaction in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(transaction.description ?? "Transaction")
                                    .font(.body)
                                Text(transaction.transactionDate ?? "")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text("$\(transaction.amount ?? 0, specifier: "%.2f")")
                                .font(.body.bold())
                                .foregroundColor(transaction.amount ?? 0 > 0 ? .green : .red)
                        }
                        .padding(.vertical, 4)
                    }
                } else {
                    Text("No recent transactions")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private var primaryPhone: String {
        guard let contacts = tenant.contacts,
              let primary = contacts.first,
              let phoneNumbers = primary.phoneNumbers,
              let phone = phoneNumbers.first(where: { $0.phoneNumberID == 3 })?.phoneNumber else {
            return "N/A"
        }
        return phone
    }
}

// MARK: - Transactions Tab
struct TransactionsTabView: View {
    let tenant: WCLeaseTenant
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Transaction History")
                .font(.headline)
                .foregroundColor(.primary)
            
            if let transactions = tenant.transactions, !transactions.isEmpty {
                LazyVStack(spacing: 8) {
                    ForEach(transactions, id: \.transactionDate) { transaction in
                        TransactionRowView(transaction: transaction)
                    }
                }
            } else {
                Text("No transactions found")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
    }
}

// MARK: - Transaction Row
struct TransactionRowView: View {
    let transaction: WCTransaction
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.description ?? "Transaction")
                    .font(.body)
                    .foregroundColor(.primary)
                
                Text(transaction.transactionDate ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let reference = transaction.reference, !reference.isEmpty {
                    Text("Ref: \(reference)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("$\(transaction.amount ?? 0, specifier: "%.2f")")
                    .font(.body.bold())
                    .foregroundColor(transaction.amount ?? 0 > 0 ? .green : .red)
                
                Text(transaction.type ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Contacts Tab
struct ContactsTabView: View {
    let tenant: WCLeaseTenant
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Contact Information")
                .font(.headline)
                .foregroundColor(.primary)
            
            if let contacts = tenant.contacts, !contacts.isEmpty {
                LazyVStack(spacing: 12) {
                    ForEach(contacts, id: \.contactID) { contact in
                        ContactDetailView(contact: contact)
                    }
                }
            } else {
                Text("No contact information available")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
    }
}

// MARK: - Contact Detail
struct ContactDetailView: View {
    let contact: RMContact
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(contact.firstName ?? "") \(contact.lastName ?? "")")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if contact.isPrimary == true {
                    Text("PRIMARY")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue)
                        .cornerRadius(4)
                }
            }
            
            if let email = contact.email, !email.isEmpty {
                HStack {
                    Image(systemName: "envelope")
                        .foregroundColor(.blue)
                    Text(email)
                        .font(.body)
                }
            }
            
            if let phoneNumbers = contact.phoneNumbers, !phoneNumbers.isEmpty {
                ForEach(phoneNumbers, id: \.phoneNumberID) { phone in
                    HStack {
                        Image(systemName: "phone")
                            .foregroundColor(.green)
                        Text(phone.phoneNumber ?? "")
                            .font(.body)
                        
                        Spacer()
                        
                        Text(phoneTypeDescription(phone.phoneNumberID))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func phoneTypeDescription(_ phoneID: Int?) -> String {
        switch phoneID {
        case 1: return "Home"
        case 2: return "Work"
        case 3: return "Cell"
        case 4: return "Fax"
        default: return "Other"
        }
    }
}

// MARK: - Lease Info Tab
struct LeaseInfoTabView: View {
    let tenant: WCLeaseTenant
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Lease Information")
                .font(.headline)
                .foregroundColor(.primary)
            
            if let lease = tenant.lease {
                LeaseDetailView(lease: lease, tenant: tenant)
            } else {
                Text("No lease information available")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
    }
}

// MARK: - Lease Detail
struct LeaseDetailView: View {
    let lease: RMLease
    let tenant: WCLeaseTenant
    
    var body: some View {
        VStack(spacing: 16) {
            InfoGrid(pairs: [
                ("Lease ID", "\(lease.leaseID ?? 0)"),
                ("Move In", lease.moveInDate ?? "N/A"),
                ("Move Out", lease.moveOutDate ?? "N/A"),
                ("Lease From", lease.leaseFromDate ?? "N/A"),
                ("Lease To", lease.leaseToDate ?? "N/A"),
                ("Unit", lease.unit?.name ?? "N/A"),
                ("Property", "\(lease.propertyID ?? 0)"),
                ("Status", lease.occupancyStatusID.map { "\($0)" } ?? "N/A")
            ])
            
            // Recurring Charges
            if let charges = tenant.recurringCharges, !charges.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recurring Charges")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    ForEach(charges, id: \.recurringChargesID) { charge in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(charge.chargeType?.description ?? "Charge")
                                    .font(.body)
                                
                                Text("Due: \(charge.nextDueDate ?? "N/A")")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text("$\(charge.amount ?? 0, specifier: "%.2f")")
                                .font(.body.bold())
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
            }
        }
    }
}

// MARK: - Info Grid (Reused Component)
struct InfoGrid: View {
    let pairs: [(String, String)]
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(pairs, id: \.0) { label, value in
                VStack(alignment: .leading, spacing: 4) {
                    Text(label)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(value)
                        .font(.body.bold())
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}