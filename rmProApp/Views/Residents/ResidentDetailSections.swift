//
//  HeaderView.swift
//  rmProApp
//
//  Created by William Castellano on 10/24/25.
//

import Foundation
import SwiftUI

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
