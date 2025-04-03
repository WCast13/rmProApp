//
//  SwiftUIView.swift
//  rmProApp
//
//  Created by William Castellano on 4/2/25.
//

import SwiftUI

struct RentIncreaseNoticeBuilder: View {
    var body: some View {
        
        NavigationView {
            VStack {
                
                NavigationLink(destination: ContentView()) {
                    Text("Create Mailing Labels")
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
                    Text("Completed Labels and ps3877 Form")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .bold()
                    
                    /*
                    NavigationLink(destination: DocumentsView()) {
                        Text("Label Documents")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .bold()
                     */
                }
                .padding(.horizontal)
                .padding(.bottom)
                .navigationTitle("Home")
            }
        }
    }
}

#Preview {
    RentIncreaseNoticeBuilder()
}
