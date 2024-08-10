//
//  ContentView.swift
//  rmProApp
//
//  Created by William Castellano on 8/7/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var apiKeyManager = APIKeyManager()
    
    var body: some View {
        VStack {
           Text("Back to Drawing Board")
        }
        .padding()
        .onAppear {
            apiKeyManager.refreshAPIKey()
        }
    }
}

#Preview {
    ContentView()
}
