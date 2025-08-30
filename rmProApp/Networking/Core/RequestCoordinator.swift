//
//  RequestCoordinator.swift
//  rmProApp
//
//  Request coalescing to prevent duplicate API calls
//

import Foundation

actor RequestCoordinator {
    static let shared = RequestCoordinator()
    
    // Track in-flight requests by URL
    private var activeRequests: [String: Task<Any, Error>] = [:]
    
    // Coalesce identical requests into a single API call
    func coalesceRequest<T: Decodable>(
        url: URL,
        responseType: T.Type,
        execute: @escaping () async throws -> T?
    ) async throws -> T? {
        let key = url.absoluteString
        
        // Check if identical request is already in-flight
        if let existingTask = activeRequests[key] {
            print("🔄 Coalescing request: \(url.lastPathComponent)")
            
            // Wait for existing request to complete
            do {
                let result = try await existingTask.value
                return result as? T
            } catch {
                // If existing request fails, remove it and throw
                activeRequests[key] = nil
                throw error
            }
        }
        
        // Create new request task
        let task = Task<Any, Error> {
            defer {
                // Clean up when done
                Task { await self.removeRequest(key: key) }
            }
            
            // Execute the actual request
            guard let result = try await execute() else {
                throw NetworkError.noData
            }
            return result
        }
        
        // Store task for coalescing
        activeRequests[key] = task
        
        // Wait for result
        do {
            let result = try await task.value
            return result as? T
        } catch {
            activeRequests[key] = nil
            throw error
        }
    }
    
    private func removeRequest(key: String) {
        activeRequests[key] = nil
    }
    
    func cancelAllRequests() {
        for (_, task) in activeRequests {
            task.cancel()
        }
        activeRequests.removeAll()
    }
    
    var activeRequestCount: Int {
        activeRequests.count
    }
}

enum NetworkError: LocalizedError {
    case noData
    case requestCancelled
    
    var errorDescription: String? {
        switch self {
        case .noData:
            return "No data received from server"
        case .requestCancelled:
            return "Request was cancelled"
        }
    }
}