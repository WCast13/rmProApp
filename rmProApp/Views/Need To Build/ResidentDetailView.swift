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
    
    var body: some View {
        VStack {
                Text("\(tenant.name ?? "Error Loading Tenant Data")")
                Text("\(tenant.charges?.count ?? 0)")
            
        }
        .onAppear() {
            Task {
//                tenant = await tenantDataManager.fetchSingleTenant(tenantID: tenantID)
                await processTenantTransasactions()
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

