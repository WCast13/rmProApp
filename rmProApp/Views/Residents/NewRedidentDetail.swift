//
//  ResidentDetailView.swift
//  rmProApp
//
//  Created by William Castellano on 4/3/25.
//  Redesigned by Grok on 6/4/25.
//

import SwiftUI

struct NewResidentDetailView: View {
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var tenantDataManager: TenantDataManager
    @State var tenant: WCLeaseTenant
    @State private var isLoadingTransactions = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header with Quick Actions
                HeaderView(tenant: tenant)
                
                // Information Section
                InformationCard(tenant: tenant)
                
                // Addresses Section
                AddressesCard(tenant: tenant)
                
                // Contact Details Section
                ContactsCard(contacts: tenant.contacts ?? [])
                
                // Lease Details Section
                LeaseCard(leases: tenant.allLeases ?? [], recurringCharges: tenant.allLeases?.first?.unit?.unitType?.recurringCharges ?? [])
                
                // Transactions Section
                TransactionsCard(transactions: tenant.transactions ?? [], isLoading: isLoadingTransactions)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Resident Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                isLoadingTransactions = true
                await processTenantTransactions()
                isLoadingTransactions = false
            }
        }
    }
    
    func processTenantTransactions() async {
        let transactionData = await tenantDataManager.fetchSingleTenantTransactions(tenantID: String(tenant.tenantID ?? 0))
        
        if let charges = transactionData?.charges, !charges.isEmpty,
           let payments = transactionData?.payments, !payments.isEmpty,
           let paymentReversals = transactionData?.paymentReversals {
            tenant.charges = charges
            tenant.payments = payments
            tenant.paymentReversals = paymentReversals
            tenant.transactions = await TenantTransactionsManager.shared.processTransactions(tenant: tenant)
        }
    }
}

// MARK: - Header View
struct HeaderView: View {
    let tenant: WCLeaseTenant
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(tenant.primaryContact?.firstName ?? "Resident") \(tenant.primaryContact?.lastName ?? "")")
                .font(.largeTitle.bold())
                .foregroundColor(.primary)
            Text("Unit: \(tenant.unit?.name ?? "N/A")")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Quick Action Buttons
            HStack(spacing: 12) {
                ActionButton(title: "Add Charge", icon: "plus.circle", action: {})
                ActionButton(title: "Start Violation", icon: "exclamationmark.triangle", action: {})
                ActionButton(title: "Add Note", icon: "note.text", action: {})
            }
            .padding(.top, 8)
        }
        .padding(.vertical, 12)
    }
}

// MARK: - Information Card
struct InformationCard: View {
    let tenant: WCLeaseTenant
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Resident Information")
                .font(.title3.bold())
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                InfoItem(label: "Unit #", value: tenant.unit?.name ?? "N/A")
                InfoItem(label: "Balance", value: tenant.balance?.formatted() ?? "$0.00")
                InfoItem(label: "Primary Contact", value: tenant.primaryContact?.firstName ?? "N/A")
                InfoItem(label: "Secondary Contact", value: tenant.contacts?.dropFirst().first?.firstName ?? "N/A")
                InfoItem(label: "Move In", value: tenant.lease?.moveInDate ?? "N/A")
                InfoItem(label: "Site Type", value: tenant.unit?.unitType?.name ?? "N/A")
                InfoItem(label: "Security Deposit", value: "$\(tenant.securityDepositHeld ?? 0)")
//                InfoItem(label: "Mailbox #", value: tenant./*mailboxNumber*/ ?? "N/A")
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
        }
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Addresses Card
struct AddressesCard: View {
    let tenant: WCLeaseTenant
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Addresses")
                .font(.title3.bold())
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 12) {
                if let address = tenant.lease?.unit?.addresses?.first {
                    AddressItem(street: address.street, city: address.city, state: address.state, zip: address.postalCode)
                } else {
                    Text("No address available")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
        }
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Contacts Card
struct ContactsCard: View {
    let contacts: [RMContact]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Contact Details")
                .font(.title3.bold())
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            if contacts.isEmpty {
                Text("No contacts available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                VStack(spacing: 12) {
                    ForEach(contacts) { contact in
                        ContactItem(contact: contact)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray5), lineWidth: 1)
                )
            }
        }
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Lease Card
struct LeaseCard: View {
    let leases: [RMLease]
    let recurringCharges: [RMRecurringCharges]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Lease Details")
                .font(.title3.bold())
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            if leases.isEmpty {
                Text("No lease information available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(leases) { lease in
                        LeaseItem(lease: lease, recurringCharges: recurringCharges)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray5), lineWidth: 1)
                )
            }
        }
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Transactions Card
struct TransactionsCard: View {
    let transactions: [WCTransaction]
    let isLoading: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Transactions")
                .font(.title3.bold())
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            if isLoading {
                ProgressView()
                    .padding()
            } else if transactions.isEmpty {
                Text("No transactions available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                VStack(spacing: 12) {
                    ForEach(transactions.prefix(5)) { transaction in
                        TransactionItem(transaction: transaction)
                    }
                    if transactions.count > 5 {
                        Button("View All Transactions") {
                            // Navigate to full transactions view
                        }
                        .font(.subheadline.bold())
                        .foregroundColor(.accentColor)
                        .padding(.top, 8)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray5), lineWidth: 1)
                )
            }
        }
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Reusable Components
struct InfoItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(.primary)
        }
    }
}

struct AddressItem: View {
    let street: String?
    let city: String?
    let state: String?
    let zip: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(street ?? "N/A")
                .font(.subheadline.bold())
            Text("\(city ?? ""), \(state ?? "") \(zip ?? "")")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct ContactItem: View {
    let contact: RMContact
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(contact.firstName ?? "") \(contact.lastName ?? "")")
                .font(.subheadline.bold())
            Text("Phone: \(contact.phoneNumbers.first(where: { $0.phoneNumberID == 3 })?.phoneNumber ?? "N/A")")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("Email: \(contact.email ?? "N/A")")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct LeaseItem: View {
    let lease: RMLease
    let recurringCharges: [RMRecurringCharges]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Unit: \(lease.unit?.name ?? "N/A")")
                .font(.subheadline.bold())
            Text("Move In: \(lease.moveInDate ?? "N/A")")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("Move Out: \(lease.moveOutDate ?? "N/A")")
                .font(.subheadline)
                .foregroundColor(.secondary)
            if !recurringCharges.isEmpty {
                Text("Recurring Charges:")
                    .font(.subheadline.bold())
                ForEach(recurringCharges) { charge in
                    HStack {
                        Text(charge.chargeType?.description ?? "N/A")
                        Spacer()
                        Text("$\(charge.amount ?? 0)")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct TransactionItem: View {
    let transaction: WCTransaction
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.comment ?? "Transaction")
                    .font(.subheadline.bold())
                Text(transaction.transactionDate ?? "N/A")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text("$\(transaction.amount ?? 0)")
                .font(.subheadline.bold())
                .foregroundColor(transaction.amount ?? 0 >= 0 ? .green : .red)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .font(.subheadline.bold())
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.accentColor.opacity(0.1))
            .foregroundColor(.accentColor)
            .clipShape(Capsule())
        }
    }
}
