//
//  MainAppView.swift
//  rmProApp
//
//  Created by William Castellano on 4/3/25.
//

import SwiftUI

struct MainAppView: View {
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
                    case .havenResidents:
                        HavenResidentsView(navigationPath: $navigationPath)
                    case .pembrokeResidents:
                        PembrokeResidentsView(navigationPath: $navigationPath)
                    case .residentDetails(let tenant):
                        NewResidentDetailView(navigationPath: $navigationPath, tenant: tenant)
                    case .noticesBuilder(let unit):
                        ViolationBuilderView(navigationPath: $navigationPath, unit: unit)
                    case .specialTask:
                        GetBoxNumbersForUDF(navigationPath: $navigationPath)
                    case .contentView:
                        // Present your existing ContentView and pass the NavigationPath binding
                        ContentView(navigationPath: $navigationPath)
                    }
                }
        }
        .environmentObject(tenantDataManager)
        .onAppear {
            Task {
                // Only fetch tenants if authenticated and we don't have them already
                if tokenManager.isAuthenticated && tenantDataManager.allTenants.isEmpty {
                    await tenantDataManager.fetchTenants()
                }
            }
        }
    }
}

enum AppDestination: Hashable {
    
    case home
    case rentIncreaseBuilder
    case documents
    case documentViewer(URL)
    case residentsHome
    case havenResidents
    case pembrokeResidents
    case residentDetails(WCLeaseTenant)
    case noticesBuilder(RMUnit)
    case specialTask
    case contentView // NEW: Route to legacy ContentView
}
