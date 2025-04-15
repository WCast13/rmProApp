//
//  ResidentsHomeView.swift
//  rmProApp
//
//  Created by William Castellano on 4/3/25.
//

import SwiftUI

struct ResidentsHomeView: View {
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var tenantDataManager: TenantDataManager
    let allResidents: [RMTenant] = []
    
    var body: some View {
        
        HStack {
            HomeButton(title: "Haven", destination: AppDestination.havenResidents)
            HomeButton(title: "Pembroke", destination: AppDestination.pembrokeResidents)
            HomeButton(title: "Resident Details View", destination: AppDestination.residentDetails("305"))
        }
        .padding(.bottom)
        
        VStack {
            Text("ResidentsHomeView")
            Text("3 Buttons- Haven Residents, Pembroke Residents, and All Residents")
            Text("Possibly Load All Residents and be able to filter by Haven, Pembroke, or All")
            Text("Possibly add more options for more filters like Prospectus A/Dry/Lake, Fire Protection, etc.")
        }
        .padding(20)
    }
}

/*
#Preview {
    ResidentsHomeView()
}
*/
