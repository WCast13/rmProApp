//
//  MainAppView.swift
//  rmProApp
//
//  Created by William Castellano on 4/3/25.
//

import SwiftUI
import SwiftData

struct MainAppView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var navigationPath = NavigationPath()
    @StateObject private var tenantDataManager = TenantDataManager.shared
    @StateObject private var tokenManager = TokenManager.shared
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            HomeView(navigationPath: $navigationPath)
                .navigationTitle("Home") // Ensure a title is set for the root view
                .navigationDestination(for: AppDestination.self) { destination in
                    
                    switch destination {
                    case .home:
                        HomeView(navigationPath: $navigationPath)
                    case .rentIncreaseBuilder:
                        RentIncreaseNoticeBuilder(navigationPath: $navigationPath)
                    case .documents:
                        DocumentsView(navigationPath: $navigationPath)
                    case .documentViewer(let url):
                        DocumentViewerView(documentURL: url, navigationPath: $navigationPath)
                    case .residentsHome:
                        ResidentsHomeView(navigationPath: $navigationPath)
                    case .residentDetails(let tenant):
                        NewResidentDetailView(navigationPath: $navigationPath, tenant: tenant)
                    }
                }
        }
        .environmentObject(tenantDataManager)
        .onAppear {
            Task {
                // Initialize UDFs cache on startup
                await initializeStartupData()

                // Only fetch tenants if authenticated and we don't have them already
                if tokenManager.isAuthenticated && tenantDataManager.allTenants.isEmpty {
                    await tenantDataManager.fetchTenants()
                }
            }
        }
    }

    // MARK: - Startup Initialization

    @MainActor
    private func initializeStartupData() async {
        // Set up SwiftData context for the data manager
        SwiftDataManager.shared.setModelContext(modelContext)

        // Initialize UDFs cache
        print("🚀 Initializing startup data...")
        let _ = await RMDataManager.shared.loadUDFsOnStartup()
        print("✅ Startup data initialization complete")
    }
}

enum AppDestination: Hashable {
    
    case home
    case rentIncreaseBuilder
    case documents
    case documentViewer(URL)
    case residentsHome
    case residentDetails(WCLeaseTenant)
}
