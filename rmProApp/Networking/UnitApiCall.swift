//
//  UnitApiCall.swift
//  rmProApp
//
//  Created by William Castellano on 8/9/24.
//

import Foundation
import Combine

class NetworkManager {
    private var tokenManager: TokenManager
    
    init(tokenManager: TokenManager) {
        self.tokenManager = tokenManager
    }
    
    func getProperties() {
        
        guard let currentKey = tokenManager.token else {
            print("Token is nil")
            return // or break, continue, etc. depending on the context
        }
        
        let headers = [
            "X-RM12Api-ApiToken": currentKey, "Content-Type": "application/json"
        ]
        
        var request = URLRequest(url: URL(string: "https://trieq.api.rentmanager.com/Properties")!,timeoutInterval: Double.infinity)
        request.allHTTPHeaderFields = headers
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
}


/*
 func getPropSimp() {
 
 let currentKey = tokenManager.token
 print(currentKey!)
 
 var request = URLRequest(url: URL(string: "https://trieq.api.rentmanager.com/Properties")!,timeoutInterval: Double.infinity)
 request.addValue("\(tokenManager.token!)", forHTTPHeaderField: "X-RM12Api-ApiToken")
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

