//
//  HomeView.swift
//  rmProApp
//
//  Created by William Castellano on 9/2/24.
//

import SwiftUI

struct HomeView: View {
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var tenantDataManager: TenantDataManager
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            HomeButton(title: "Rent Increase Builder", destination: AppDestination.rentIncreaseBuilder)
            HomeButton(title: "Residents Home View", destination: AppDestination.residentsHome)
//            HomeButton(title: "Special Tasks- Resident Details View", destination: AppDestination.residentDetails("305"))
            
            HStack {
                Spacer()
                Text("\(tenantDataManager.allTenants.count)")
                Spacer()
                Text("\(tenantDataManager.allLease.count)")
                Spacer()
                Text("\(tenantDataManager.rentIncreaseTenants.count)")
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
        .navigationTitle("Home")
    }
}

struct DashboardView: View {
    var body: some View {
        Text("Dashboard will be built here later.")
            .font(.largeTitle)
    }
}

struct ResidentListView: View {
    var body: some View {
        Text("Resident List will be built here later.")
            .font(.largeTitle)
    }
}
