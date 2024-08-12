//
//  ContentView.swift
//  rmProApp
//
//  Created by William Castellano on 8/7/24.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    @EnvironmentObject var tokenManager: TokenManager
    @State private var networkManager: NetworkManager?
    
    @State private var units: [RMUnit]?
    
    var body: some View {
        VStack {
            Text("# of Properties")
            
            if let token = tokenManager.token {
                Text("Current Token: \(token)")
                    .font(.footnote)
            } else {
                Text("Fetching Token...")
            }
            
            Button("fetch Unit Data") {
                networkManager?.getProperties()
            }
            
        }
        .padding()
        .onAppear {
            tokenManager.refreshToken()
            self.networkManager = NetworkManager(tokenManager: tokenManager)
        }
    }
}






/*
 func getPropSimp() {
     let currentKey = tokenManager.token
     print(currentKey!)
     
     var request = URLRequest(url: URL(string: "https://trieq.api.rentmanager.com/Properties/1")!,timeoutInterval: Double.infinity)
     print(currentKey!)
     request.addValue("sgWF_QPg_4Sl2BGyLCu4U8jfxBHXkfclRuyODiwLEWwMEoEZxcxmh84a_DU4o-Ze-9DAIqFvm5_6Fc4M2T7KdtPVjqA-Te7d7DDDdqVRymE=", forHTTPHeaderField: "X-RM12Api-ApiToken")
     request.addValue("application/json", forHTTPHeaderField: "Content-Type")
     request.httpMethod = "GET"
     
     print(request.allHTTPHeaderFields!)

     let task = URLSession.shared.dataTask(with: request) { data, response, error in
       guard let data = data else {
         print(String(describing: error))
         return
       }
       print(String(data: data, encoding: .utf8)!)
     }

     task.resume()
 }
 */
