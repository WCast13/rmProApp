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
    @State private var tenants: [RMTenant]? // TODO: Fix Tenants
    @State private var units: [RMUnit]?
    @State private var contacts: [RMContact]?
    
    var body: some View {
        VStack {
            Text("# of Properties: \(properties?.count ?? 0)")
            Text("# of Units: \(units?.count ?? 0)")
//            Text("# of Tenents: \(tenants?.count ?? 0)")
//            Text("# of Contacts: \(contacts?.count ?? 0)")
        }
        .padding()
        .onAppear {
            Task {
                await TokenManager.shared.refreshToken()
                properties = await RentManagerAPIClient.shared.request(endpoint: .properties, responseType: [RMProperty].self)
                units = await RentManagerAPIClient.shared.request(responseType: [RMUnit].self, urlString: "https://trieq.api.rentmanager.com/Units?filters=Property.IsActive,eq,true")
//                units = await RentManagerAPIClient.shared.request(endpoint: .units, responseType: [RMUnit].self)
//                tenants = await RentManagerAPIClient.shared.request(endpoint: .tenants, responseType: [RMTenant].self, fields: [.contactID, .firstName, .lastName])
//                contacts = await RentManagerAPIClient.shared.request(responseType: [RMContact].self, urlString: URLStringEndPoints.contactAllData.rawValue)
//                print(contacts ?? "No contacts found")
            }
        }
    }
}
