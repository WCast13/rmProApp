//
//  HomeView.swift
//  rmProApp
//
//  Created by William Castellano on 9/2/24.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        
        NavigationView {
            VStack {
                
                /*
                 NavigationLink(destination: ResidentsView()) {
                 Text("Label Documents")
                 .frame(maxWidth: .infinity)
                 .padding()
                 .background(Color.blue)
                 .foregroundColor(.white)
                 .cornerRadius(10)
                 .bold()
                 */
                
                NavigationLink(destination: RentIncreaseNoticeBuilder()) {
                    Text("Rent Increase Builder")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .bold()
                }
                .padding(.horizontal)
                .padding(.bottom)
                
                
            }
            .padding(.horizontal)
            .padding(.bottom)
            .navigationTitle("Home")
        }
    }
}


#Preview {
    HomeView()
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
