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
        let fetched: [RMTenant]
        do {
            fetched = try await fetchFromAPI(deltaFilter: deltaFilter)
        } catch {
            print("❌ TenantRepository fetch failed: \(error.localizedDescription)")
            return cache
        }

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

    /// `syncBase` plus the section hydration step: run the 5 nested embed
    /// fetches (leases, contacts, addresses, loans, UDFs) concurrently and
    /// merge each back into the cache. Returns the hydrated list.
    ///
    /// Note: the section fetches are in-memory only — they don't re-persist
    /// through SwiftData. The base rows are the persistence surface.
    func syncFull(forceRefresh: Bool = false) async -> [RMTenant] {
        let base = await syncBase(forceRefresh: forceRefresh)
        return await hydrateSections(base)
    }

    // MARK: - Private helpers

    private enum Section {
        case leases, contacts, addresses, loans, userDefinedValues
    }

    private func hydrateSections(_ base: [RMTenant]) async -> [RMTenant] {
        await withTaskGroup(of: (Section, [RMTenant]).self) { group in
            group.addTask { (.userDefinedValues, await self.fetchSection(embeds: TenantEmbeds.udfEmbeds, fields: TenantFields.udfFields)) }
            group.addTask { (.leases, await self.fetchSection(embeds: TenantEmbeds.leaseEmbeds, fields: TenantFields.leaseFields)) }
            group.addTask { (.contacts, await self.fetchSection(embeds: TenantEmbeds.contactsEmbeds, fields: TenantFields.contactFields)) }
            group.addTask { (.addresses, await self.fetchSection(embeds: TenantEmbeds.addressEmbeds, fields: TenantFields.addressFields)) }
            group.addTask { (.loans, await self.fetchSection(embeds: TenantEmbeds.loanEmbeds, fields: TenantFields.loanFields)) }

            for await (section, fetched) in group {
                for newData in fetched {
                    merge(newData: newData, section: section)
                }
            }
        }
        return cache
    }

    private func fetchSection(embeds: [TenantEmbeds], fields: [TenantFields]) async -> [RMTenant] {
        do {
            return try await RMAPIClient.shared.send(GetTenantsRequest(embeds: embeds, fields: fields))
        } catch {
            print("❌ TenantRepository fetchSection failed: \(error.localizedDescription)")
            return []
        }
    }

    private func merge(newData: RMTenant, section: Section) {
        guard let newID = newData.tenantID,
              let index = cache.firstIndex(where: { $0.tenantID == newID }) else { return }
        var existing = cache[index]
        switch section {
        case .leases:             existing.leases = newData.leases
        case .contacts:           existing.contacts = newData.contacts
        case .addresses:          existing.addresses = newData.addresses
        case .loans:              existing.loans = newData.loans
        case .userDefinedValues:  existing.udfs = newData.udfs
        }
        cache[index] = existing
    }

    private func fetchFromAPI(deltaFilter: RMFilter?) async throws -> [RMTenant] {
        var filters: [RMFilter] = [RMFilter(key: "Status", operation: "ne", value: "Past")]
        if let deltaFilter {
            filters.append(deltaFilter)
            print("🔁 TenantRepository delta fetch (\(deltaFilter.key),\(deltaFilter.operation),\(deltaFilter.value))")
        } else {
            print("🌊 TenantRepository full fetch")
        }
        return try await RMAPIClient.shared.send(GetTenantsRequest(filters: filters))
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
