//
//  AuthenticateRM.swift
//  rmProApp
//
//  Created by William Castellano on 8/7/24.
//

import Foundation
import SwiftUI


/*
 func fetchAPIkey() {
     @AppStorage("apiKey", store: .standard) var apiKey: String = ""
     
     let parameters = "{\"Username\": \"w.castellano\",\n\"Password\": \"Trilogy123\"\n}"
     let postData = parameters.data(using: .utf8)
     
     var request = URLRequest(url: URL(string: "https://trieq.api.rentmanager.com/Authentication/AuthorizeUser/")!,timeoutInterval: Double.infinity)
     request.addValue("application/json", forHTTPHeaderField: "Content-Type")
     
     request.httpMethod = "POST"
     request.httpBody = postData
     
     let task = URLSession.shared.dataTask(with: request) { data, response, error in
         guard let data = data else {
             print(String(describing: error))
             return
         }
         
         print(String(data: data, encoding: .utf8)!)
         let newAPIString = String(data: data, encoding: .utf8)!
         apiKey = newAPIString
         
     }
     
     task.resume()
 }
 */

import SwiftUI
import Security
import Combine

class APIKeyManager: ObservableObject {
    @Published var apiKey: String? {
        didSet {
            if let key = apiKey {
                saveAPIKey(key)
            }
        }
    }

    private var timer: AnyCancellable?
    private let service = "com.yourapp.apikeyservice"
    private let account = "apikey"
    
    init() {
        apiKey = loadAPIKey()
        scheduleTokenRefresh()
    }

    // Simulate fetching the API key from a server
    func fetchNewAPIKey() -> String {
        var newAPIString: String = ""
        
        let parameters = "{\"Username\": \"w.castellano\",\n\"Password\": \"Trilogy123\"\n}"
        let postData = parameters.data(using: .utf8)
        
        var request = URLRequest(url: URL(string: "https://trieq.api.rentmanager.com/Authentication/AuthorizeUser/")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = "POST"
        request.httpBody = postData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            
            print(String(data: data, encoding: .utf8)!)
            newAPIString = String(data: data, encoding: .utf8)!
            
        }
        
        task.resume()
    
        return newAPIString
    }

    func scheduleTokenRefresh() {
        timer = Timer.publish(every: 800, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.refreshAPIKey()
            }
    }

    func refreshAPIKey() {
        let newKey = fetchNewAPIKey()
        apiKey = newKey
    }

    // Keychain storage methods
    func saveAPIKey(_ key: String) {
        let keyData = key.data(using: .utf8)!

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: keyData
        ]

        // Update existing item or add a new one
        SecItemDelete(query as CFDictionary) // Remove old key if exists
        SecItemAdd(query as CFDictionary, nil)
    }

    func loadAPIKey() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        SecItemCopyMatching(query as CFDictionary, &item)

        guard let keyData = item as? Data else { return nil }
        return String(data: keyData, encoding: .utf8)
    }
}
