//
//  ResidentDetailView.swift
//  rmProApp
//
//  Created by William Castellano on 4/3/25.
//

import SwiftUI
import Playgrounds

struct ResidentDetailView: View {
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var tenantDataManager: TenantDataManager

    @State var tenant: WCLeaseTenant
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text("Unit: \(tenant.unit?.name ?? "N/A")")
                Text(String(describing: tenant.balance ?? 0.0))
                Text(tenant.primaryContact?.firstName ?? "")
                Text(tenant.contacts?.first?.firstName ?? "")
                Text("Move in Date: \(tenant.lease?.moveInDate ?? "")")
                Text("Unit Type: \(tenant.unit?.unitType?.name ?? "N/A")")
                Text("Security Deposit: \(String(describing: tenant.securityDepositHeld ?? 0))")
                Text("Transactions Count: \(tenant.transactions?.count ?? 0)")
                Text("\(tenant.transactions?.first?.transactionDate ?? "")")
                Text(String(describing: tenant.transactions?.first?.amount ?? 0))
//                Text("Address: \(tenant.lease?.unit?.addresses?.first?.address ?? "")")
                
                Text("Contacts Count: \(tenant.contacts?.count ?? 0)")
                
                Button("Print contacts to console") {
                    print("Contacts: \(String(describing: tenant.contacts))")
                }
                
                /*
                 
                 Text("Balance", tenant.balance ?? "$0.00")
                                Text("Primary Contact", tenant.primaryContact?.firstName ?? "N/A")
                                Text("Secondary Contact", tenant.contacts?.dropFirst().first?.firstName ?? "N/A")
                                Text("Move In", tenant.lease?.moveInDate ?? "N/A")
                                Text("Site Type", tenant.unit?.unitType?.name ?? "N/A")
                                Text("Security Deposit", "\(tenant.securityDepositHeld ?? 0)")
                 */
                
               
            }
        }
        .onAppear() {
            Task {
                await processTenantTransasactions()
                
                // Only fetch if data is missing (basic cache strategy)
                async let addresses: [RMAddress] = tenant.addresses?.isEmpty != false ? tenantDataManager.fetchAddresses(tenant: tenant) : tenant.addresses ?? []
                async let contacts: [RMContact] = tenant.contacts?.isEmpty != false ? tenantDataManager.fetchContacts(tenant: tenant) : tenant.contacts ?? []
                
                tenant.addresses = await addresses
                tenant.contacts = await contacts
                
                print(tenant.udfs?.first ?? "NA")
            }
        }
        .padding()
        .navigationTitle("Resident Details")
    }
    
    func processTenantTransasactions() async {
        let transactionData = await tenantDataManager.fetchSingleTenantTransactions(tenantID: String(tenant.tenantID ?? 0))
        
        if let charges = transactionData?.charges, !charges.isEmpty, let payments = transactionData?.payments, !payments.isEmpty, let paymentReversals = transactionData?.paymentReversals {
            
            tenant.charges = charges
            tenant.payments = payments
            tenant.paymentReversals = paymentReversals
            
            let transactions = await TenantTransactionsManager.shared.processTransactions(tenant: tenant)
            
            tenant.transactions = transactions
        }
    }
}

// MARK: Information Section
struct InformationSection: View {
    let tenant: WCLeaseTenant
    
    var body: some View {
        InfoGrid(pairs: [
            ("Unit #", tenant.unit?.name ?? "N/A"),
            ("Balance", tenant.balance?.formatted() ?? "$0.00"),
            ("Primary Contact", tenant.primaryContact?.firstName ?? "N/A"),
            ("Secondary Contact", tenant.contacts?.dropFirst().first?.firstName ?? "N/A"),
            ("Move In", tenant.lease?.moveInDate ?? "N/A"),
            ("Site Type", tenant.unit?.unitType?.name ?? "N/A"),
            ("Security Deposit", "\(tenant.securityDepositHeld ?? 0)")
        ])
    }
}

// MARK: Contacts Section
struct ContactSection: View {
    let contacts: [RMContact]
    var body: some View {
        ForEach(contacts, id: \.self) { contact in
            ContactDetailView(contact: contact)
        }
    }
}

struct ContactDetailView: View {
    let contact: RMContact
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(contact.firstName ?? "") \(contact.lastName ?? "")")
                .font(.subheadline)
            let phoneNumbers = contact.phoneNumbers
            let cellPhone = phoneNumbers.filter { $0.phoneNumberID == 3 }.first?.phoneNumber ?? ""
            Text("Phone: \(cellPhone)")
            Text("Email: \(contact.email ?? "")")
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: Lease Section
struct LeaseSection: View {
    let leases: [RMLease]
    let recurringCharges: [RMRecurringCharges]
    
    var body: some View {
        ForEach(leases) { lease in
            VStack(alignment: .leading) {
                Text("Unit: \(lease.unit?.name ?? "")")
                Text("Move In: \(lease.moveInDate ?? "N/A")")
                Text("Move Out: \(lease.moveOutDate ?? "N/A")")
                Text("Recurring Charges:")
                ForEach(recurringCharges) { charge in
                    Text("\(charge.amount ?? 0)")
                        .font(.subheadline)
                    Text("\(charge.chargeType?.description ?? "N/A")")
                        .font(.subheadline)
                }
            }
        }
    }
}

struct TitleSectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline).bold()
            .foregroundColor(.accentColor)
            .padding(.vertical, 4)
    }
}

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
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

/*
     #Preview {
     ResidentDetailView()
     }
     */
    
    /*
     Text("FEATURES")
     .bold()
     Text("Possible Buttons for quick actions: Start Violation/Make 7 day notice template, add charge, add notes, etc.")
     Text("Search by Name, Unit #, Phone #, email, Mail Box Number- Need UDF for Box Number")
     Text("INFORMATION")
     .bold()
     Text("Unit #, Balance, Primary Contact, Secondary Contact, Box number, Move In Date, Site Type")
     Text("Sections")
     .bold()
     Text("Contacts")
     Text("Charges")
     Text("Transactions")
     Text("Payments")
     Text("Leases")
     Text("Notes")
     Text("Violations")
     Text("ePay?")
     Text("Security Deposit")
     */

