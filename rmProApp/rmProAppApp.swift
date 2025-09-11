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
    
    init() {
        // Initialize authentication on app startup
        Task {
            await TokenManager.shared.initializeAuthentication()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if tokenManager.isAuthenticating {
                    // Show loading screen while checking authentication
                    VStack {
                        ProgressView("Checking authentication...")
                        Text("Please wait...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else if tokenManager.isAuthenticated {
                    MainAppView()
                } else {
                    LoginView()
                }
            }
            .environmentObject(tokenManager)
        }
    }
}
