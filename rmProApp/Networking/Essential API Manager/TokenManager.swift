//
//  TokenManager.swift
//  rmProApp
//
//  Created by William Castellano on 8/9/24.
//

import Foundation
import Combine

@MainActor
class TokenManager: ObservableObject {
    @Published var token: String?
    private var refreshTimer: Timer?
    private let tokenEndpoint = "https://trieq.api.rentmanager.com/Authentication/AuthorizeUser/"
    
    static let shared = TokenManager() // Shared singleton instance
    
    private init() { // Private initializer
        Task {
            await refreshToken()
            startTokenRefreshTimer()
        }
    }
    
    func refreshToken() async {
        
        let parameters = "{\"Username\": \"w.castellano\",\n\"Password\": \"Trilogy123\"\n}"
        let postData = parameters.data(using: .utf8)
        
        var request = URLRequest(url: URL(string: tokenEndpoint)!)
        request.httpMethod = "POST"
        request.httpBody = postData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let newToken = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.token = newToken.trimmingCharacters(in: .init(charactersIn: "\""))
                    print(newToken)
                }
            }
        } catch {
            print("Error refreshing token: \(error.localizedDescription)")
        }
    }
    
    func startTokenRefreshTimer() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 13 * 60, repeats: true) { _ in
            Task {
                await self.refreshToken()
            }
        }
    }
    
    deinit {
        refreshTimer?.invalidate()
    }
}
