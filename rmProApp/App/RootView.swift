//
//  RootView.swift
//  rmProApp
//
//  Top-level app shell. Hosts three sections (Residents, Mailings,
//  Settings). Size-class branches the presentation: compact width
//  (iPhone) gets a TabView; regular width (iPad, wide landscape) gets
//  a NavigationSplitView with a sidebar.
//
//  Section selection and each section's NavigationStack path live here
//  so they survive a size-class change (rotation, split-screen resize).
//

import SwiftUI
import SwiftData

enum AppSection: String, Hashable, Identifiable, CaseIterable {
    case residents
    case mailings
    case settings

    var id: Self { self }

    var title: String {
        switch self {
        case .residents: return "Residents"
        case .mailings:  return "Mailings"
        case .settings:  return "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .residents: return "person.2.fill"
        case .mailings:  return "envelope.fill"
        case .settings:  return "gearshape.fill"
        }
    }
}

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(TenantDataManager.self) private var tenantDataManager
    @EnvironmentObject private var tokenManager: TokenManager

    @State private var selection: AppSection? = .residents
    @State private var residentsPath = NavigationPath()
    @State private var mailingsPath = NavigationPath()
    @State private var settingsPath = NavigationPath()

    var body: some View {
        Group {
            if sizeClass == .compact {
                tabShell
            } else {
                splitShell
            }
        }
        .task {
            await initializeStartupData()
            if tokenManager.isAuthenticated && tenantDataManager.allTenants.isEmpty {
                await tenantDataManager.fetchTenants()
            }
        }
    }

    // MARK: - Compact (iPhone)

    private var tabShell: some View {
        TabView(selection: $selection) {
            ResidentsTab(path: $residentsPath)
                .tabItem { Label(AppSection.residents.title, systemImage: AppSection.residents.systemImage) }
                .tag(AppSection?.some(.residents))

            MailingsTab(path: $mailingsPath)
                .tabItem { Label(AppSection.mailings.title, systemImage: AppSection.mailings.systemImage) }
                .tag(AppSection?.some(.mailings))

            SettingsTab(path: $settingsPath)
                .tabItem { Label(AppSection.settings.title, systemImage: AppSection.settings.systemImage) }
                .tag(AppSection?.some(.settings))
        }
    }

    // MARK: - Regular (iPad, wide split)

    private var splitShell: some View {
        NavigationSplitView {
            List(AppSection.allCases, selection: $selection) { section in
                NavigationLink(value: section) {
                    Label(section.title, systemImage: section.systemImage)
                }
            }
            .navigationTitle("rmProApp")
        } detail: {
            switch selection {
            case .residents:
                ResidentsTab(path: $residentsPath)
            case .mailings:
                MailingsTab(path: $mailingsPath)
            case .settings:
                SettingsTab(path: $settingsPath)
            case .none:
                ContentUnavailableView(
                    "Select a section",
                    systemImage: "sidebar.left",
                    description: Text("Choose Residents, Mailings, or Settings from the sidebar.")
                )
            }
        }
    }

    // MARK: - Startup

    @MainActor
    private func initializeStartupData() async {
        SwiftDataManager.shared.setModelContext(modelContext)
        print("🚀 Initializing startup data...")
        _ = await RMDataManager.shared.loadUDFsOnStartup()
        print("✅ Startup data initialization complete")
    }
}
