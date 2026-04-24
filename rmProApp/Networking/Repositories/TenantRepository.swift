//
//  TenantRepository.swift
//  rmProApp
//
//  Owns the base tenant sync pipeline:
//   hydrate from SwiftData → apply delta filter → fetch via RMAPIClient →
//   merge or replace → persist via SwiftData → markSynced.
//
//  Actor-isolated so the sync state machine is serialized and independent
//  of the main thread. SwiftData hops to the main actor internally since
//  SwiftDataManager is @MainActor-confined.
//

import Foundation

actor TenantRepository {
    static let shared = TenantRepository()
    private init() {}

    // Canonical in-memory cache of the base tenant list.
    private var cache: [RMTenant] = []

    /// Full sync on first call of a session (or after forceRefresh).
    /// Delta sync on subsequent calls using SyncCoordinator's lastSyncDate.
    /// Returns the merged cache.
    func syncBase(forceRefresh: Bool = false) async -> [RMTenant] {
        if cache.isEmpty {
            let cached = await Self.loadCachedTenants()
            if !cached.isEmpty {
                cache = cached
                print("📦 TenantRepository hydrated \(cached.count) tenants from SwiftData")
            }
        }

        if forceRefresh {
            await SyncCoordinator.shared.resetSyncDate(for: RMTenant.self)
        }

        let deltaFilter = await SyncCoordinator.shared.deltaFilter(for: RMTenant.self)
        let fetched = await fetchFromAPI(deltaFilter: deltaFilter)

        if deltaFilter == nil {
            cache = fetched
        } else {
            for updated in fetched {
                guard let newID = updated.tenantID else { continue }
                if let idx = cache.firstIndex(where: { $0.tenantID == newID }) {
                    cache[idx] = updated
                } else {
                    cache.append(updated)
                }
            }
            print("🔁 TenantRepository delta merged \(fetched.count) updated (total: \(cache.count))")
        }

        if !fetched.isEmpty {
            await Self.persistTenants(fetched)
        }

        await SyncCoordinator.shared.markSynced(RMTenant.self)
        return cache
    }

    /// Expose the current cache without triggering a sync. Useful for readers
    /// that just want the current state (e.g. after syncBase returned).
    func allTenants() -> [RMTenant] {
        cache
    }

    /// Replace the cache wholesale. Needed by the legacy data manager while
    /// section merges (leases/udfs/contacts/etc.) still live there.
    /// Will be removed when section fetches move into their own repositories.
    func overwriteCache(_ tenants: [RMTenant]) {
        cache = tenants
    }

    // MARK: - Private helpers

    private func fetchFromAPI(deltaFilter: RMFilter?) async -> [RMTenant] {
        var filters: [RMFilter] = [RMFilter(key: "Status", operation: "ne", value: "Past")]
        if let deltaFilter {
            filters.append(deltaFilter)
            print("🔁 TenantRepository delta fetch (UpdateDate,gte,\(deltaFilter.value))")
        } else {
            print("🌊 TenantRepository full fetch")
        }

        do {
            return try await RMAPIClient.shared.send(GetTenantsRequest(filters: filters))
        } catch {
            print("❌ TenantRepository fetch failed: \(error.localizedDescription)")
            return []
        }
    }

    @MainActor
    private static func loadCachedTenants() -> [RMTenant] {
        do {
            return try SwiftDataManager.shared.loadAll(of: RMTenant.self)
        } catch {
            print("❌ TenantRepository loadCachedTenants: \(error.localizedDescription)")
            return []
        }
    }

    @MainActor
    private static func persistTenants(_ tenants: [RMTenant]) {
        do {
            try SwiftDataManager.shared.save(tenants)
        } catch {
            print("❌ TenantRepository persistTenants: \(error.localizedDescription)")
        }
    }
}
