//
//  HomeView.swift
//  rmProApp
//
//  Created by William Castellano on 9/2/24.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            
            NavigationLink(destination: ContentView()) {
                Text("Sites")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .bold()
            }
            .padding(.horizontal)
            .padding(.bottom)
            
            
            NavigationLink(destination: DocumentsView()) {
                Text("Documents")
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

struct DocumentsView: View {
    var body: some View {
        Text("Document View will be built here later.")
            .font(.largeTitle)
    }
}
