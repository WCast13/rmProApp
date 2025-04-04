//
//  ResidentDetailView.swift
//  rmProApp
//
//  Created by William Castellano on 4/3/25.
//

import SwiftUI

struct ResidentDetailView: View {
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        VStack {
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
        }
        .padding()
    }
        
}

/*
#Preview {
    ResidentDetailView()
}
*/
