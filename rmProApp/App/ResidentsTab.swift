//
//  ResidentsTab.swift
//  rmProApp
//
//  Residents tab: its own NavigationStack, its own destination enum.
//  Root is the existing ResidentsHomeView; pushing a WCLeaseTenant
//  lands on NewResidentDetailView.
//

import SwiftUI

enum ResidentsDestination: Hashable {
    case residentDetail(WCLeaseTenant)
}

struct ResidentsTab: View {
    @Binding var path: NavigationPath

    var body: some View {
        NavigationStack(path: $path) {
            ResidentsHomeView(navigationPath: $path)
                .navigationDestination(for: ResidentsDestination.self) { destination in
                    switch destination {
                    case .residentDetail(let tenant):
                        NewResidentDetailView(navigationPath: $path, tenant: tenant)
                    }
                }
        }
    }
}
