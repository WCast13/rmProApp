//
//  rmProAppApp.swift
//  rmProApp
//
//  Created by William Castellano on 8/7/24.
//

// rmProAppApp.swift
import SwiftUI
import SwiftData

@main
struct rmProAppApp: App {
    @StateObject private var tokenManager = TokenManager.shared
    @State private var tenantDataManager = TenantDataManager.shared

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
                    VStack {
                        ProgressView("Checking authentication...")
                        Text("Please wait...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else if tokenManager.isAuthenticated {
                    RootView()
                } else {
                    LoginView()
                }
            }
            .environmentObject(tokenManager)
            .environment(tenantDataManager)
        }
        .modelContainer(for: [
            RMTenant.self,
            RMUnit.self,
            RMLease.self,
            RMLoan.self,
            RMContact.self,
            RMPhoneNumber.self,
            RMUserDefinedValue.self,
            WCLeaseTenant.self,
            WCTransaction.self,
        ])
    }
}
