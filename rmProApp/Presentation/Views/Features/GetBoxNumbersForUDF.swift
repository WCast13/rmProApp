//
//  GetBoxNumbersForUDF.swift
//  rmProApp
//
//  Created by William Castellano on 4/9/25.
//

import SwiftUI

struct GetBoxNumbersForUDF: View {
    @State var units: [RMUnit]? = []
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        Text("Special Tasks")
            .onAppear {
                Task {
                    units = await RentManagerAPIClient.shared.request(url: URL(string: "https://trieq.api.rentmanager.com/Units?embeds=CurrentOccupants,PrimaryAddress,Property.Addresses,UnitType,Leases,Leases.Tenant,UserDefinedValues&filters=PropertyID,eq,3&fields=CurrentOccupants,Name,PrimaryAddress,PropertyID,UnitType,Leases,UserDefinedValues")!, responseType: [RMUnit].self)
                    getHavenBoxNumbers(units: units!)
                }
            }
    }
}

//    #Preview {
//        GetBoxNumbersForUDF()
//    }

func getHavenBoxNumbers(units: [RMUnit]) {
    for unit in units {
        print("\(unit.name ?? "")   \(unit.primaryAddress?.street?.components(separatedBy: "\r\n").last ?? "")")
    }
}
