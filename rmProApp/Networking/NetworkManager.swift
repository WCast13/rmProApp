//
//  NetworkManager.swift
//  rmProApp
//
//  Created by William Castellano on 8/9/24.
//

import Foundation
import Combine

class NetworkManager {
    
    // MARK: Get API Token
    private var tokenManager: TokenManager
    
    init(tokenManager: TokenManager) {
        self.tokenManager = tokenManager
    }
    
    // MARK: Async API Call- Properties
    func getProperties() async -> [RMProperty] {
        var properties = [RMProperty]()
        
        guard let currentKey = tokenManager.token else {
            print("Token is nil")
            return [RMProperty]() // or break, continue, etc. depending on the context
        }
        
        let headers = [
            "X-RM12Api-ApiToken": currentKey, "Content-Type": "application/json"
        ]
        
        var request = URLRequest(url: URL(string: "https://trieq.api.rentmanager.com/Properties?filters=IsActive,eq,true")!, timeoutInterval: Double.infinity)
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
    
    // MARK: Async RM API Get Call
    
    func getRMData<T: Decodable>(from endpoint: String, responseType: T.Type) async -> T? {
        guard let currentKey = tokenManager.token else {
            print("Token is nil")
            return nil
        }
        
        let headers = [
            "X-RM12Api-ApiToken": currentKey, "Content-Type": "application/json"
        ]
        
        guard let url = URL(string: "https://trieq.api.rentmanager.com/\(endpoint)") else {
            print("Invalid URL")
            return nil
        }
        
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        request.allHTTPHeaderFields = headers
        request.httpMethod = "GET"
        
        print(request.allHTTPHeaderFields!)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let decodedData = try JSONDecoder().decode(responseType, from: data)
                return decodedData
            } else {
                print("Failed to fetch data: \(response)")
                return nil
            }
        } catch {
            print("Failed to decode JSON: \(error)")
            return nil
        }
    }
}
