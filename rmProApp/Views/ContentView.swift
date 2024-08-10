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
    
    
    var body: some View {
        VStack {
            if let token = tokenManager.token {
                Text("Current Token: \(token)")
            } else {
                Text("Fetching Token...")
            }
            
            Button("fetch Unit Data") {
                networkManager?.makeAuthenticatedRequest()
            }
        }
        .padding()
        .onAppear {
            self.networkManager = NetworkManager(tokenManager: tokenManager)
        }
    }
}
