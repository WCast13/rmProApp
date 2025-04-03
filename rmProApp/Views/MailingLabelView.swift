//
//  UnitCellView.swift
//  rmProApp
//
//  Created by William Castellano on 8/15/24.
//

import SwiftUI

struct MailingLabelView: View {
    @State var unit: RMUnit
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(unit.name ?? "HR-44")
                    .font(.headline)
                    .bold()
                Text(unit.unitType?.name ?? "########")
                    .font(.caption2)
                Spacer()
                
                Text(unit.currentOccupants?.first?.name ?? "** Name **")
            }
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text("\(unit.primaryAddress?.street ?? "** No Street **")")
                Text("\(unit.primaryAddress?.city ?? "** No City **"), \(unit.primaryAddress?.state ?? "00") \(unit.primaryAddress?.postalCode ?? "** XXXXX **")")
            }
            .font(.footnote)
        }
    }
}

