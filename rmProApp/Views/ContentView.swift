//
//  ContentView.swift
//  rmProApp
//
//  Created by William Castellano on 8/7/24.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State private var properties: [RMProperty]?
    @State private var tenants: [RMTenant]?
    @State private var units: [RMUnit]?
    @State private var contacts: [RMContact]?
    
    var body: some View {
        Button("Generate Labels") {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let pdfURL = documentsDirectory.appendingPathComponent("UnitLabels.pdf")
            let templateURL = Bundle.main.url(forResource: "Avery 5160 Template PDF", withExtension: "pdf")!
            
            LabelGeneratorManager.shared.generatePDFLabels(units: units!, saveTo: pdfURL, templatePDF: templateURL)

            print("PDF generated at: \(pdfURL)")
        }
        VStack {
            if let units = units {
                List(units) { unit in
                    UnitCellView(unit: unit)
                }
            } else {
                ProgressView("Loading Units...")
            }
        }
        .padding()
        .onAppear {
            Task {
                await TokenManager.shared.refreshToken()
                properties = await RentManagerAPIClient.shared.request(endpoint: .properties, responseType: [RMProperty].self)
                units = await RentManagerAPIClient.shared.request(responseType: [RMUnit].self, urlString: "https://trieq.api.rentmanager.com/Units?embeds=CurrentOccupants,PrimaryAddress,Property.Addresses,UnitType&filters=PropertyID,in,(3%2C12)&fields=CurrentOccupants,Name,PrimaryAddress,PropertyID,UnitType")
            }
        }
    }
}


/*
 UNITS ITERATION- For Labels
 
 /Units?embeds=CurrentOccupants,PrimaryAddress,Property.Addresses,UnitType&filters=Property.IsActive,eq,true&fields=CurrentOccupants,Name,PrimaryAddress,PropertyID,UnitType
 
 /Units?embeds=CurrentOccupants,PrimaryAddress,Property.Addresses,UnitType&filters=PropertyID,in,(3%2C12)&fields=CurrentOccupants,Name,PrimaryAddress,PropertyID,UnitType
 */

