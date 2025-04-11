//
//  UnitsView.swift
//  rmProApp
//
//  Created by William Castellano on 12/13/24.
//

import SwiftUI

struct UnitsView: View {
    
    @State private var units: [RMUnit]?
    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        
        VStack {
            Text("units: \(units?.count ?? 0)")
            
            
            // filter units that have unit tpe id of 12 or user defined value of yes
//            let filteredUnits = units?.filter { $0.UnitTypeID == 12 || $0.userDefinedValues?.last?.value == "Yes"}
//            let fpgTenants = units?.filter { $0.currentOccupants?.first?.colorID == 38 || $0.userDefinedValues?.last?.value == "Yes"}
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    
                    if let units = units {
                        ForEach(units, id: \.uuid) { unit in
                            VStack {
                                Text("\(unit.name ?? "")")
                                Text(unit.currentOccupants?.first?.name ?? "")
                                
                                
                            }
                        }
                    } else {
                        Text("No units found")
                            .foregroundColor(.gray)
                    }
                }
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

