//
//  rmProAppApp.swift
//  rmProApp
//
//  Created by William Castellano on 8/7/24.
//

import SwiftUI

@main
struct rmProAppApp: App {
    @StateObject private var tokenManager = TokenManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(tokenManager)
        }
    }
}
