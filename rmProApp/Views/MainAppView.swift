//
//  MainAppView.swift
//  rmProApp
//
//  Created by William Castellano on 4/3/25.
//

import SwiftUI

struct MainAppView: View {
    @State private var navigationPath = NavigationPath()
    
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
                    case .mailingLabels:
                        ContentView(navigationPath: $navigationPath)
                    case .documents:
                        DocumentsView(navigationPath: $navigationPath)
                    case .documentViewer(let url):
                        DocumentViewerView(documentURL: url, navigationPath: $navigationPath)
                    }
                }
        }
    }
}

#Preview {
    MainAppView()
}

enum AppDestination: Hashable {
    case home
    case rentIncreaseBuilder
    case mailingLabels
    case documents
    case documentViewer(URL)
}
