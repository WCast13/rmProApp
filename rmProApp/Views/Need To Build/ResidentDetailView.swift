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
    let tenantID: String
    
    var body: some View {
        VStack {
            if let tenant = tenantDataManager.singleTenant {
                Text("\(tenant.name ?? "Error Loading Tenant Data")")
            } else {
                Text("Loading...")
            }
        }
        .padding()
        .navigationTitle("Resident Details")
        .onAppear() {
            Task {
                await tenantDataManager.fetchSingleTenant(tenantID: tenantID)
            }
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
