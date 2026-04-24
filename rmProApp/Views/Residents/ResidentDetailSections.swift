//
//  ResidentDetailSections.swift
//  rmProApp
//
//  Cards on the resident detail screen. Each one uses the shared
//  Card + SectionHeader components; body composition lives here.
//

import SwiftUI

// MARK: - Header

struct HeaderView: View {
    let tenant: WCLeaseTenant

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.s) {
            Text("\(tenant.primaryContact?.firstName ?? "Resident") \(tenant.primaryContact?.lastName ?? "")")
                .font(DSTypography.largeTitle)
                .foregroundColor(DSColor.primary)
            Text("Unit: \(tenant.unit?.name ?? "N/A")")
                .font(DSTypography.subheadline)
                .foregroundColor(DSColor.secondary)
        }
        .padding(.vertical, DSSpacing.m)
    }
}

// MARK: - Information Card

struct InformationCard: View {
    let tenant: WCLeaseTenant

    var body: some View {
        Card("Resident Information") {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: DSSpacing.l),
                    GridItem(.flexible(), spacing: DSSpacing.l),
                ],
                spacing: DSSpacing.l
            ) {
                InfoItem(label: "Unit #", value: tenant.unit?.name ?? "N/A")
                InfoItem(label: "Balance", value: tenant.balance?.formatted() ?? "$0.00")
                InfoItem(label: "Primary Contact", value: tenant.primaryContact?.firstName ?? "N/A")
                InfoItem(label: "Secondary Contact", value: tenant.contacts?.dropFirst().first?.firstName ?? "N/A")
                InfoItem(label: "Move In", value: tenant.lease?.moveInDate ?? "N/A")
                InfoItem(label: "Site Type", value: tenant.unit?.unitType?.name ?? "N/A")
                InfoItem(label: "Security Deposit", value: "$\(tenant.securityDepositHeld ?? 0)")
            }
        }
    }
}

// MARK: - Addresses Card

struct AddressesCard: View {
    let tenant: WCLeaseTenant

    var body: some View {
        Card("Addresses") {
            if let address = tenant.lease?.unit?.addresses?.first {
                AddressItem(
                    street: address.street,
                    city: address.city,
                    state: address.state,
                    zip: address.postalCode
                )
            } else {
                Text("No address available")
                    .font(DSTypography.subheadline)
                    .foregroundColor(DSColor.secondary)
            }
        }
    }
}

// MARK: - Contacts Card

struct ContactsCard: View {
    let contacts: [RMContact]

    var body: some View {
        Card("Contact Details") {
            if contacts.isEmpty {
                Text("No contacts available")
                    .font(DSTypography.subheadline)
                    .foregroundColor(DSColor.secondary)
            } else {
                VStack(spacing: DSSpacing.m) {
                    ForEach(contacts) { contact in
                        ContactItem(contact: contact)
                    }
                }
            }
        }
    }
}

// MARK: - Lease Card

struct LeaseCard: View {
    let leases: [RMLease]
    let recurringCharges: [RMRecurringCharges]

    var body: some View {
        Card("Lease Details") {
            if leases.isEmpty {
                Text("No lease information available")
                    .font(DSTypography.subheadline)
                    .foregroundColor(DSColor.secondary)
            } else {
                VStack(alignment: .leading, spacing: DSSpacing.l) {
                    ForEach(leases) { lease in
                        LeaseItem(lease: lease, recurringCharges: recurringCharges)
                    }
                }
            }
        }
    }
}

// MARK: - Transactions Card

struct TransactionsCard: View {
    let transactions: [WCTransaction]
    let isLoading: Bool

    var body: some View {
        Card("Transactions") {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else if transactions.isEmpty {
                Text("No transactions available")
                    .font(DSTypography.subheadline)
                    .foregroundColor(DSColor.secondary)
            } else {
                VStack(spacing: DSSpacing.m) {
                    ForEach(transactions.prefix(5)) { transaction in
                        TransactionItem(transaction: transaction)
                    }
                    if transactions.count > 5 {
                        Text("\(transactions.count - 5) more not shown")
                            .font(DSTypography.caption)
                            .foregroundColor(DSColor.secondary)
                            .padding(.top, DSSpacing.s)
                    }
                }
            }
        }
    }
}
