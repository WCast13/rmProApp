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

            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {

                    if let units = units {
                        ForEach(units, id: \.id) { unit in
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
