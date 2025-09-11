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
    @Published var isAuthenticating = false
    
    private var timerCancellable: AnyCancellable?
    private var refreshTask: Task<Void, Never>?
    private var tokenExpirationDate: Date?
    private let tokenLifetime: TimeInterval = 15 * 60 // 15 minutes
    private let tokenEndpoint = "https://trieq.api.rentmanager.com/Authentication/AuthorizeUser/"
    private let keychain = KeychainService()
    
    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 30
        return URLSession(configuration: config)
    }()
    
    static let shared = TokenManager()
    
    enum AuthError: Error, LocalizedError {
        case missingCredentials
        case invalidCredentials
        case networkError(String)
        case tokenRefreshFailed
        case authenticationInProgress
        
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
            case .authenticationInProgress:
                return "Authentication already in progress"
            }
        }
    }
    
    private init() {
        // TokenManager is initialized but won't auto-fetch tokens
        // Call initializeAuthentication() on app startup
    }
    
    // MARK: - Public Authentication Methods
    
    /// Authenticate with username and password
    func authenticate(username: String, password: String, saveCredentials: Bool = true) async -> Bool {
        // Prevent multiple simultaneous authentication attempts
        guard !isAuthenticating else {
            authenticationError = .authenticationInProgress
            return false
        }
        
        isAuthenticating = true
        authenticationError = nil
        
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
            
            // Set token expiration and start refresh timer
            self.tokenExpirationDate = Date().addingTimeInterval(tokenLifetime)
            startTokenRefreshTimer()
            
            isAuthenticating = false
            return true
        } catch {
            self.authenticationError = error as? AuthError ?? .networkError(error.localizedDescription)
            self.isAuthenticated = false
            isAuthenticating = false
            return false
        }
    }
    
    /// Sign out and clear credentials
    func signOut() {
        token = nil
        tokenExpirationDate = nil
        isAuthenticated = false
        isAuthenticating = false
        authenticationError = nil
        timerCancellable?.cancel()
        timerCancellable = nil
        refreshTask?.cancel()
        refreshTask = nil
        
        // Clear stored credentials
        try? keychain.deleteCredentials()
    }
    
    /// Check for stored credentials and refresh token
    func checkAndRefreshToken() async {
        guard keychain.hasStoredCredentials else {
            authenticationError = .missingCredentials
            isAuthenticated = false
            return
        }
        
        await refreshTokenIfNeeded()
    }
    
    /// Initialize authentication on app startup
    func initializeAuthentication() async {
        // Check if we have stored credentials and try to authenticate
        if keychain.hasStoredCredentials {
            await checkAndRefreshToken()
        } else {
            // No credentials stored, user needs to log in
            isAuthenticated = false
            authenticationError = .missingCredentials
        }
    }
    
    // MARK: - Private Token Management
    
    private func shouldRefreshToken() -> Bool {
        guard let expirationDate = tokenExpirationDate else { return true }
        return Date().addingTimeInterval(60) > expirationDate // Refresh 1 min before expiry
    }
    
    private func refreshTokenIfNeeded() async {
        guard shouldRefreshToken() else { return }
        await refreshToken()
    }
    
    private func refreshToken() async {
        // Prevent duplicate refresh requests
        if let existingTask = refreshTask {
            await existingTask.value
            return
        }
        
        refreshTask = Task {
            await performTokenRefresh()
            refreshTask = nil
        }
        
        await refreshTask?.value
    }
    
    private func performTokenRefresh() async {
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
            self.tokenExpirationDate = Date().addingTimeInterval(tokenLifetime)
            self.isAuthenticated = true
            self.authenticationError = nil
            
            // Ensure timer is running
            if timerCancellable == nil {
                startTokenRefreshTimer()
            }
        } catch {
            // If refresh fails, sign out the user
            self.authenticationError = error as? AuthError ?? .tokenRefreshFailed
            self.isAuthenticated = false
            // Don't clear credentials on refresh failure - user can try again
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
            let (data, response) = try await urlSession.data(for: request)
            
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
        timerCancellable?.cancel()
        
        timerCancellable = Timer.publish(every: 13 * 60, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                Task { await self.refreshTokenIfNeeded() }
            }
    }
    
    deinit {
        timerCancellable?.cancel()
        refreshTask?.cancel()
    }
}
