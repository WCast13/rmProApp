//
//  RootView.swift
//  rmProApp
//
//  Top-level app shell. Hosts three tabs (Residents, Mailings, Settings),
//  each with its own NavigationStack and destination enum. iPad split-view
//  branching is deferred to a follow-up phase.
//

import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(TenantDataManager.self) private var tenantDataManager
    @EnvironmentObject private var tokenManager: TokenManager

    var body: some View {
        TabView {
            ResidentsTab()
                .tabItem { Label("Residents", systemImage: "person.2.fill") }

            MailingsTab()
                .tabItem { Label("Mailings", systemImage: "envelope.fill") }

            SettingsTab()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .task {
            await initializeStartupData()
            if tokenManager.isAuthenticated && tenantDataManager.allTenants.isEmpty {
                await tenantDataManager.fetchTenants()
            }
        }
    }

    @MainActor
    private func initializeStartupData() async {
        SwiftDataManager.shared.setModelContext(modelContext)
        print("🚀 Initializing startup data...")
        _ = await RMDataManager.shared.loadUDFsOnStartup()
        print("✅ Startup data initialization complete")
    }
}
