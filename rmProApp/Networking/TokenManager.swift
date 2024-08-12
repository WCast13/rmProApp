//
//  TokenManager.swift
//  rmProApp
//
//  Created by William Castellano on 8/9/24.
//

import Foundation
import Combine

class TokenManager: ObservableObject {
    @Published var token: String?
    private var refreshTimer: Timer?
    private let tokenEndpoint = "https://trieq.api.rentmanager.com/Authentication/AuthorizeUser/"
    
    init() {
        refreshToken()
        startTokenRefreshTimer()
    }
    
    func refreshToken() {
        
        let parameters = "{\"Username\": \"w.castellano\",\n\"Password\": \"Trilogy123\"\n}"
        let postData = parameters.data(using: .utf8)
        
        var request = URLRequest(url: URL(string: tokenEndpoint)!)
        request.httpMethod = "POST"
        request.httpBody = postData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error refreshing token: \(error?.localizedDescription ?? "Error")")
                return
            }
            
            if let newToken = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    
                    self.token = newToken.trimmingCharacters(in: .init(charactersIn: "\""))
                    print(newToken)
                }
            }
        }
        task.resume()
    }
    
    func startTokenRefreshTimer() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 13 * 60, repeats: true) { _ in
            self.refreshToken()
        }
    }
    
    deinit {
        refreshTimer?.invalidate()
    }
}
