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
    
    func getProperties() -> [RMProperty] {
        
        var properties = [RMProperty]()
        
        
        guard let currentKey = tokenManager.token else {
            print("Token is nil")
            return [RMProperty]() // or break, continue, etc. depending on the context
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
            
            do {
                properties = try JSONDecoder().decode([RMProperty].self, from: data)
                print("One: \(properties.count)")
            } catch {
                print("Failed to decode JSON: \(error)")
            }
         
        }
        
        task.resume()
        print("Two: \(properties.count)")
        return properties
    }
    
    func getPropertiesAsync() async -> [RMProperty] {
        var properties = [RMProperty]()
        
        guard let currentKey = tokenManager.token else {
            print("Token is nil")
            return [RMProperty]() // or break, continue, etc. depending on the context
        }
        
        let headers = [
            "X-RM12Api-ApiToken": currentKey, "Content-Type": "application/json"
        ]
        
        var request = URLRequest(url: URL(string: "https://trieq.api.rentmanager.com/Properties")!, timeoutInterval: Double.infinity)
        request.allHTTPHeaderFields = headers
        request.httpMethod = "GET"
        
        print(request.allHTTPHeaderFields!)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                properties = try JSONDecoder().decode([RMProperty].self, from: data)
                print("One: \(properties.count)")
            } else {
                print("Failed to fetch data: \(response)")
            }
        } catch {
            print("Failed to decode JSON: \(error)")
        }
        
        print("Two: \(properties.count)")
        return properties
    }
}
