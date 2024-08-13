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
    
    var body: some View {
        VStack {
            Text("# of Properties: \(properties?.count ?? 0)")
            
        }
        .padding()
        .onAppear {
            Task {
                await TokenManager.shared.refreshToken()
                properties = await RentManagerAPIClient.shared.request(endpoint: "Properties", responseType: [RMProperty].self)
            }
        }
    }
}
