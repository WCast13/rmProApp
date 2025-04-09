//
//  ContentView.swift
//  rmProApp
//
//  Created by William Castellano on 8/7/24.
//

import SwiftUI
import Combine

struct ContentView: View {
//    @State private var properties: [RMProperty]?
    @State private var tenants: [RMTenant]?
    @State private var units: [RMUnit]?
//    @State private var contacts: [RMContact]?
    @State private var community: String = "Haven Lake Estates"
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        // Need segmented Control to Filter Units by Type
        // Haven or Pembroke
        // Sorted by Group or Unit
        VStack {
            HStack {
                Spacer()
                Button("Haven Labels") {
                    let filteredUnits = units?.filter { $0.propertyID == 3 }.sorted { ($0.userDefinedValues?.last?.value)! > ($1.userDefinedValues?.last?.value)! }
                    let filteredTenants = tenants?.filter { $0.propertyID == 3 }
                    
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let pdfURL = documentsDirectory.appendingPathComponent("HavenFINAL2.pdf")
                    let templateURL = Bundle.main.url(forResource: "Avery 5160 Template PDF", withExtension: "pdf")!
                    
                    LabelGeneratorManager.shared.generatePDFLabels(units: filteredUnits!, tenants: filteredTenants!, saveTo: pdfURL, templatePDF: templateURL)
                    
                    let ps3877templateURL = Bundle.main.url(forResource: "ps3877", withExtension: "pdf")!
                    let ps3877PdfURL = documentsDirectory.appendingPathComponent("Filled_PS_Form_3877.pdf")
                    
                    PS3877FormManager.shared.create3877Form(units: filteredUnits!, tenants: filteredTenants!, saveTo: ps3877PdfURL, templatePDF: ps3877templateURL)
                    print("PDF generated at: \(pdfURL)")
                    
                    let csvURL = documentsDirectory.appendingPathComponent("Units.csv")

                    LabelGeneratorManager.shared.generateCSVFile(units: filteredUnits!, tenants: filteredTenants!, saveTo: csvURL)

                }
                
                Spacer()
                
                Button("Pembroke Labels") {
                   
                    let filteredUnits = units?.filter { $0.propertyID == 12 }.sorted { ($0.unitType?.unitTypeID)! < ($1.unitType?.unitTypeID)! }
                    let filteredTenants = tenants?.filter { $0.propertyID == 12 }
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let pdfURL = documentsDirectory.appendingPathComponent("PembrokeUnitLabels- \(Date.now.formatted(date: .abbreviated, time: .shortened)).pdf")
                    let templateURL = Bundle.main.url(forResource: "Avery 5160 Template PDF", withExtension: "pdf")!
                    
                    LabelGeneratorManager.shared.generatePDFLabels(units: filteredUnits!, tenants: filteredTenants!, saveTo: pdfURL, templatePDF: templateURL)
                    
                    print("PDF generated at: \(pdfURL)")
                }
                Spacer()
            }
            
            if let units = units {
                List(units) { unit in
                    MailingLabelView(unit: unit)
                }
            } else {
                ProgressView("Loading Units...")
            }
        }
        .onAppear {
            Task {
                await TokenManager.shared.refreshToken()
//                properties = await RentManagerAPIClient.shared.request(endpoint: .properties, responseType: [RMProperty].self)
                tenants = await RentManagerAPIClient.shared.request(responseType: [RMTenant].self, urlString: "https://trieq.api.rentmanager.com//Tenants?embeds=Contacts,UserDefinedValues&filters=PropertyID,eq,3&fields=Contacts,Name,PropertyID,TenantID,UserDefinedValues&PageSize=20000")
                units = await RentManagerAPIClient.shared.request(responseType: [RMUnit].self, urlString: "https://trieq.api.rentmanager.com/Units?embeds=CurrentOccupants,PrimaryAddress,Property.Addresses,UnitType,Leases,Leases.Tenant,UserDefinedValues&filters=PropertyID,in,(3%2C12)&fields=CurrentOccupants,Name,PrimaryAddress,PropertyID,UnitType,Leases,UserDefinedValues")
                
            }
        }
    }
}


/*
 UNITS ITERATION- For Labels
 
 https://trieq.api.rentmanager.com/Units?embeds=CurrentOccupants,PrimaryAddress,Property.Addresses,UnitType,Leases,Leases.Tenant&filters=PropertyID,in,(3%2C12)&fields=CurrentOccupants,Name,PrimaryAddress,PropertyID,UnitType,Leases")
 
 /Units?embeds=CurrentOccupants,PrimaryAddress,Property.Addresses,UnitType&filters=Property.IsActive,eq,true&fields=CurrentOccupants,Name,PrimaryAddress,PropertyID,UnitType
 
 /Units?embeds=CurrentOccupants,PrimaryAddress,Property.Addresses,UnitType,Leases,Leases.Tenant&filters=PropertyID,in,(3%2C12)&fields=CurrentOccupants,Name,PrimaryAddress,PropertyID,UnitType,Leases
 
 /Units?embeds=Leases,Leases.Tenant&fields=Leases,Name
 */

