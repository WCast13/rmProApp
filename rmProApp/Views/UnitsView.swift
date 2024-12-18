//
//  UnitsView.swift
//  rmProApp
//
//  Created by William Castellano on 12/13/24.
//

import SwiftUI

struct UnitsView: View {
    
    @State private var units: [RMUnit]?
    
    var body: some View {
        
        VStack {
            Text("units: \(units?.count ?? 0)")
            
            if let units = units {
                // filter units that have unit tpe id of 12 or user defined value of yes
                let filteredUnits = units.filter { $0.UnitTypeID == 12 || $0.userDefinedValues?.last?.value == "Yes"}
                let fpgTenants = units.filter { $0.leases?.first?.tenant?.colorID == 38 || $0.userDefinedValues?.last?.value == "Yes"}
                List(units) { unit in
                    
                    VStack(alignment: .leading) {
                        
                        HStack {
                            Text("\(unit.name ?? "")")
                                .bold()
                                .foregroundColor(unit.leases?.first?.tenant?.colorID == 38 ? .red : .black)
                            
                            Spacer()
                            VStack {
                                Text("Lease")
                                Text(unit.leases?.first?.propertyUnit ?? "")
                                Text("\(unit.leases?.first?.tenant?.colorID ?? 0)")
                            }
                            
                        }
                        
                        
                        
                        
                        
                        HStack {
                            Text("FPG 2024- \(unit.UnitTypeID == 3 ? "No" : "Yes")")
                            Spacer()
                            Text("FPG 2025- \(unit.userDefinedValues?.last?.value ?? "")")
                        }
                        
                        Button("Remove from FPG") {
                            Task {
                                await RentManagerAPIClient.shared.fpgToRegularRent(unit: unit)
                            }
                            
                        }
                        .disabled(unit.userDefinedValues?.last?.value != "No") // Disable the button if the condition is false
                    }
                }
            }
        }
        .onAppear {
            Task {
                await TokenManager.shared.refreshToken()
                
//                units = await RentManagerAPIClient.shared.request(responseType: [RMUnit].self, urlString: "https://trieq.api.rentmanager.com/Units?filters=PropertyID,eq,3&embeds=UnitType,UserDefinedValues&fields=Name,PropertyID,UnitType,UserDefinedValues,UnitID,UnitTypeID")!
                
                units = await RentManagerAPIClient.shared.request(responseType: [RMUnit].self, urlString: "https://trieq.api.rentmanager.com/Units?embeds=CurrentOccupants,PrimaryAddress,Property.Addresses,UnitType,Leases,Leases.Tenant,UserDefinedValues&filters=PropertyID,in,(3%2C12)&fields=CurrentOccupants,Name,PrimaryAddress,PropertyID,UnitType,Leases,UserDefinedValues")!
            }
        }
    }
}



#Preview {
    UnitsView()
}


/*
 Update Fire Protection Units
 
 Version 1-
 List sites- Manually Update with Button
 
 
 
 
 1. Import CSV
 2. Lookup Sites to Edit
 - FPG to Normal
 - Normal to FPG
 
 Post Request-
 
 
 
 
 */
