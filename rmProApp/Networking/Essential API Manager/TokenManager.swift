//
//  TokenManager.swift
//  rmProApp
//
//  Created by William Castellano on 8/9/24.
//

// TokenManager.swift (Secured Version)
import Foundation
import Combine
import Security

@MainActor
class TokenManager: ObservableObject {
    @Published var token: String?
    @Published var isAuthenticated = false
    @Published var authenticationError: AuthError?
    
    private var refreshTimer: Timer?
    private let tokenEndpoint = "https://trieq.api.rentmanager.com/Authentication/AuthorizeUser/"
    private let keychain = KeychainService()
    
    static let shared = TokenManager()
    
    enum AuthError: Error, LocalizedError {
        case missingCredentials
        case invalidCredentials
        case networkError(String)
        case tokenRefreshFailed
        
        var errorDescription: String? {
            switch self {
            case .missingCredentials:
                return "No stored credentials found. Please log in."
            case .invalidCredentials:
                return "Invalid username or password"
            case .networkError(let message):
                return "Network error: \(message)"
            case .tokenRefreshFailed:
                return "Failed to refresh authentication token"
            }
        }
    }
    
    private init() {
        // Check for existing credentials on init
        Task {
            await checkAndRefreshToken()
        }
    }
    
    // MARK: - Public Authentication Methods
    
    /// Authenticate with username and password
    func authenticate(username: String, password: String, saveCredentials: Bool = true) async -> Bool {
        do {
            // Try to get token with provided credentials
            let token = try await fetchToken(username: username, password: password)
            
            self.token = token
            self.isAuthenticated = true
            self.authenticationError = nil
            
            // Save credentials if requested
            if saveCredentials {
                try keychain.saveCredentials(username: username, password: password)
            }
            
            // Start refresh timer
            startTokenRefreshTimer()
            
            return true
        } catch {
            self.authenticationError = error as? AuthError ?? .networkError(error.localizedDescription)
            self.isAuthenticated = false
            return false
        }
    }
    
    /// Sign out and clear credentials
    func signOut() {
        token = nil
        isAuthenticated = false
        authenticationError = nil
        refreshTimer?.invalidate()
        refreshTimer = nil
        
        // Optionally clear stored credentials
        try? keychain.deleteCredentials()
    }
    
    /// Check for stored credentials and refresh token
    func checkAndRefreshToken() async {
        guard keychain.hasStoredCredentials else {
            authenticationError = .missingCredentials
            isAuthenticated = false
            return
        }
        
        await refreshToken()
    }
    
    // MARK: - Private Token Management
    
    private func refreshToken() async {
        guard let credentials = keychain.getCredentials() else {
            authenticationError = .missingCredentials
            isAuthenticated = false
            return
        }
        
        do {
            let newToken = try await fetchToken(
                username: credentials.username,
                password: credentials.password
            )
            
            self.token = newToken
            self.isAuthenticated = true
            self.authenticationError = nil
            
            // Ensure timer is running
            if refreshTimer == nil {
                startTokenRefreshTimer()
            }
        } catch {
            self.authenticationError = error as? AuthError ?? .tokenRefreshFailed
            self.isAuthenticated = false
        }
    }
    
    private func fetchToken(username: String, password: String) async throws -> String {
        let parameters = [
            "Username": username,
            "Password": password
        ]
        
        guard let postData = try? JSONEncoder().encode(parameters) else {
            throw AuthError.invalidCredentials
        }
        
        var request = URLRequest(url: URL(string: tokenEndpoint)!)
        request.httpMethod = "POST"
        request.httpBody = postData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.networkError("Invalid response")
            }
            
            switch httpResponse.statusCode {
            case 200:
                guard let tokenString = String(data: data, encoding: .utf8) else {
                    throw AuthError.tokenRefreshFailed
                }
                return tokenString.trimmingCharacters(in: .init(charactersIn: "\""))
            case 401:
                throw AuthError.invalidCredentials
            default:
                throw AuthError.networkError("Server returned status code: \(httpResponse.statusCode)")
            }
        } catch {
            if let authError = error as? AuthError {
                throw authError
            }
            throw AuthError.networkError(error.localizedDescription)
        }
    }
    
    private func startTokenRefreshTimer() {
        refreshTimer?.invalidate()
        
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 13 * 60, repeats: true) { _ in
            Task { @MainActor in
                await self.refreshToken()
            }
        }
        
        // Also add to RunLoop to ensure it works
        if let timer = refreshTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    deinit {
        refreshTimer?.invalidate()
    }
}
