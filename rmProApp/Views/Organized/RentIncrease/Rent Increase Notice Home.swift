//
//  SwiftUIView.swift
//  rmProApp
//
//  Created by William Castellano on 4/2/25.
//

import SwiftUI

struct RentIncreaseNoticeBuilder: View {
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        
        NavigationView {
            VStack {
                HomeButton(title: "Labels & PS3877 (Legacy ContentView)", destination: AppDestination.contentView)
                HomeButton(title: "Completed Labels and ps3877 Form", destination: AppDestination.documents)
            }
            .padding(.horizontal)
            .padding(.bottom)
            .navigationTitle("Home")
        }
    }
}
