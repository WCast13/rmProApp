//
//  SwiftUIAssets.swift
//  rmProApp
//
//  Created by William Castellano on 4/3/25.
//

import SwiftUI


struct HomeButton<Destination: Hashable>: View {
    let title: String
    let destination: Destination
    
    var body: some View {
        NavigationLink(value: destination) {
            Text(title)
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


           
