//
//  ResidentsHomeView.swift
//  rmProApp
//
//  Created by William Castellano on 4/3/25.
//

import SwiftUI

struct ResidentsHomeView: View {
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        
        HStack {
            HomeButton(title: "Haven", destination: AppDestination.havenResidents)
            HomeButton(title: "Pembroke", destination: AppDestination.pembrokeResidents)
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
