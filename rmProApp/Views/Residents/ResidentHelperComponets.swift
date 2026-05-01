//
//  ResidentHelperFile.swift
//  rmProApp
//
//  Created by William Castellano on 10/24/25.
//

import Foundation
import SwiftUI

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
                        Text(charge.chargeType?.descriptionText ?? "N/A")
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

