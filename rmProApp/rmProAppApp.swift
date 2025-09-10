//
//  rmProAppApp.swift
//  rmProApp
//
//  Created by William Castellano on 8/7/24.
//

// rmProAppApp.swift
import SwiftUI

@main
struct rmProAppApp: App {
    @StateObject private var tokenManager = TokenManager.shared
    
    var body: some Scene {
        WindowGroup {
            if tokenManager.isAuthenticated {
                MainAppView()
                    .environmentObject(tokenManager)
            } else {
                MainAppView()
                    .environmentObject(tokenManager)
            }
        }
    }
}
