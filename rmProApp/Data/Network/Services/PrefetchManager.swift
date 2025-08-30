//
//  PrefetchManager.swift
//  rmProApp
//
//  Background prefetching for predictive data loading
//

import Foundation
import Combine

@MainActor
class PrefetchManager: ObservableObject {
    static let shared = PrefetchManager()
    
    private let tenantManager = TenantDataManager.shared
    private let apiClient = OptimizedAPIClient.shared
    private let urlBuilder = URLBuilder.shared
    
    // Track prefetch status
    @Published var isPrefetching = false
    private var prefetchTasks: Set<Task<Void, Never>> = []
    
    // Prefetch queue with priorities
    private var prefetchQueue: [(url: URL, priority: PrefetchPriority)] = []
    private let maxConcurrentPrefetches = 3
    
    private init() {}
    
    // MARK: - Intelligent Prefetching Strategies
    
    /// Prefetch tenant details when user hovers or is likely to tap
    func prefetchTenantDetails(tenantID: String) {
        // Check if already cached
        if tenantManager.getCachedTenant(id: tenantID) != nil {
            return
        }
        
        let task = Task(priority: .background) {
            _ = await tenantManager.fetchSingleTenant(tenantID: tenantID)
            print("📥 Prefetched tenant: \(tenantID)")
        }
        
        prefetchTasks.insert(task)
    }
    
    /// Prefetch next likely tenants based on current view
    func prefetchAdjacentTenants(currentTenantID: String, in tenantList: [RMTenant]) {
        guard let currentIndex = tenantList.firstIndex(where: { $0.tenantID == Int(currentTenantID) }) else {
            return
        }
        
        // Prefetch 2 before and 2 after current tenant
        let range = max(0, currentIndex - 2)..<min(tenantList.count, currentIndex + 3)
        
        for index in range {
            if let tenantID = tenantList[index].tenantID {
                prefetchTenantDetails(tenantID: String(tenantID))
            }
        }
    }
    
    /// Prefetch transactions when viewing tenant details
    func prefetchTransactions(for tenantID: String) {
        Task(priority: .background) {
            _ = await tenantManager.fetchSingleTenantTransactions(tenantID: tenantID)
            print("📥 Prefetched transactions for tenant: \(tenantID)")
        }
    }
    
    /// Prefetch property-specific data
    func prefetchPropertyData(propertyID: Int) {
        Task(priority: .background) {
            let filters = [
                RMFilter(key: "PropertyID", operation: "eq", value: String(propertyID)),
                RMFilter(key: "Status", operation: "ne", value: "Past")
            ]
            
            guard let url = urlBuilder.buildURL(endpoint: .tenants, filters: filters) else {
                return
            }
            
            _ = await apiClient.request(
                url: url,
                responseType: [RMTenant].self,
                cachePolicy: .useCache,
                priority: .low
            )
            
            print("📥 Prefetched property \(propertyID) data")
        }
    }
    
    /// Prefetch based on user navigation patterns
    func prefetchForRoute(_ route: AppRoute) {
        switch route {
        case .tenantList:
            // Prefetch first page of tenants
            prefetchInitialTenants()
            
        case .propertyView(let propertyID):
            // Prefetch property-specific data
            prefetchPropertyData(propertyID: propertyID)
            
        case .tenantDetail(let tenantID):
            // Prefetch tenant transactions and related data
            prefetchTransactions(for: tenantID)
            prefetchRelatedTenants(for: tenantID)
            
        case .rentIncrease:
            // Prefetch rent increase data
            Task(priority: .background) {
                tenantManager.buildRentIncreaseTenants()
            }
            
        default:
            break
        }
    }
    
    /// Prefetch initial tenant list for quick display
    private func prefetchInitialTenants() {
        Task(priority: .high) {
            isPrefetching = true
            
            // Fetch minimal fields for list display
            let minimalFields = "TenantID,FirstName,LastName,PropertyID,Balance"
            let filters = [RMFilter(key: "Status", operation: "ne", value: "Past")]
            
            guard let url = urlBuilder.buildURL(
                endpoint: .tenants,
                fields: minimalFields,
                filters: filters
            ) else {
                isPrefetching = false
                return
            }
            
            _ = await apiClient.request(
                url: url,
                responseType: [RMTenant].self,
                cachePolicy: .useCache,
                priority: .high
            )
            
            isPrefetching = false
            print("📥 Prefetched initial tenant list")
        }
    }
    
    /// Prefetch related tenants (same unit history, contacts, etc.)
    private func prefetchRelatedTenants(for tenantID: String) {
        Task(priority: .low) {
            // Get tenant's unit to find related tenants
            guard let tenant = await tenantManager.fetchSingleTenant(tenantID: tenantID),
                  let unitID = tenant.leases?.first?.unitID else {
                return
            }
            
            // Prefetch other tenants in same unit (history)
            let filters = [
                RMFilter(key: "Leases.UnitID", operation: "eq", value: String(unitID))
            ]
            
            guard let url = urlBuilder.buildURL(endpoint: .tenants, filters: filters) else {
                return
            }
            
            _ = await apiClient.request(
                url: url,
                responseType: [RMTenant].self,
                cachePolicy: .useCache,
                priority: .low
            )
            
            print("📥 Prefetched related tenants for unit: \(unitID)")
        }
    }
    
    // MARK: - Predictive Prefetching
    
    /// Learn from user behavior and prefetch accordingly
    func recordUserAction(_ action: UserAction) {
        switch action {
        case .scrolledToTenant(let index, let totalCount):
            // User is scrolling, prefetch next batch
            let batchSize = 20
            let nextBatchStart = index + 5
            if nextBatchStart < totalCount {
                prefetchTenantBatch(from: nextBatchStart, size: batchSize)
            }
            
        case .searchedFor(let query):
            // Prefetch common search results
            prefetchSearchResults(for: query)
            
        case .viewedProperty(let propertyID):
            // User viewed a property, prefetch its tenants
            prefetchPropertyData(propertyID: propertyID)
            
        case .openedTenantDetail(let tenantID):
            // Prefetch full details and transactions
            prefetchTransactions(for: tenantID)
        }
    }
    
    private func prefetchTenantBatch(from startIndex: Int, size: Int) {
        Task(priority: .background) {
            let filters = [
                RMFilter(key: "Status", operation: "ne", value: "Past"),
                RMFilter(key: "pageNumber", operation: "eq", value: String(startIndex / size + 1)),
                RMFilter(key: "pageSize", operation: "eq", value: String(size))
            ]
            
            guard let url = urlBuilder.buildURL(endpoint: .tenants, filters: filters) else {
                return
            }
            
            _ = await apiClient.request(
                url: url,
                responseType: [RMTenant].self,
                cachePolicy: .useCache,
                priority: .low
            )
            
            print("📥 Prefetched tenant batch starting at: \(startIndex)")
        }
    }
    
    private func prefetchSearchResults(for query: String) {
        guard query.count >= 2 else { return }
        
        Task(priority: .background) {
            // Prefetch likely search results
            let filters = [
                RMFilter(key: "Name", operation: "contains", value: query),
                RMFilter(key: "Status", operation: "ne", value: "Past")
            ]
            
            guard let url = urlBuilder.buildURL(endpoint: .tenants, filters: filters) else {
                return
            }
            
            _ = await apiClient.request(
                url: url,
                responseType: [RMTenant].self,
                cachePolicy: .useCache,
                priority: .medium
            )
            
            print("📥 Prefetched search results for: \(query)")
        }
    }
    
    // MARK: - Cleanup
    
    func cancelAllPrefetches() {
        for task in prefetchTasks {
            task.cancel()
        }
        prefetchTasks.removeAll()
        prefetchQueue.removeAll()
    }
    
    func clearPrefetchCache() {
        apiClient.clearCache()
        tenantManager.clearCache()
    }
}

// MARK: - Supporting Types

enum PrefetchPriority: Int {
    case low = 0
    case medium = 1
    case high = 2
}

enum AppRoute {
    case tenantList
    case propertyView(propertyID: Int)
    case tenantDetail(tenantID: String)
    case rentIncrease
    case dashboard
}

enum UserAction {
    case scrolledToTenant(index: Int, totalCount: Int)
    case searchedFor(query: String)
    case viewedProperty(propertyID: Int)
    case openedTenantDetail(tenantID: String)
}