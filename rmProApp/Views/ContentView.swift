//
//  ContentView.swift
//  rmProApp
//
//  Created by William Castellano on 8/7/24.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    @EnvironmentObject var tokenManager: TokenManager
    @State private var networkManager: NetworkManager?
    
    @State private var properties: [RMProperty]?
    
    var body: some View {
        VStack {
            Text("# of Properties: \(properties?.count ?? 0)")
            
            if let token = tokenManager.token {
                Text("Current Token: \(token)")
                    .font(.footnote)
            } else {
                Text("Fetching Token...")
            }
            Button("Load Properties") {
                Task {
                    properties = await networkManager?.getRMData(from: "Properties", responseType: [RMProperty].self)
                }
            }
        }
        .padding()
        .onAppear {
            tokenManager.refreshToken()
            self.networkManager = NetworkManager(tokenManager: tokenManager)
        }
    }
}
