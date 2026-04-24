//
//  UDFRepository.swift
//  rmProApp
//
//  Owns the user-defined-field sync pipeline: hydrate from SwiftData →
//  delta/full fetch via /UserDefinedFields → upsert → markSynced.
//

import Foundation

actor UDFRepository {
    static let shared = UDFRepository()
    private init() {}

    /// Full-on-first / delta-on-subsequent sync. Returns the merged cache
    /// loaded from SwiftData so callers see every known row (including
    /// ones the server didn't return in a delta response).
    func syncUDFs(forceRefresh: Bool = false) async -> [RMUserDefinedValue] {
        if forceRefresh {
            await SyncCoordinator.shared.resetSyncDate(for: RMUserDefinedValue.self)
        }

        let cached = await Self.loadCachedUDFs()
        if !cached.isEmpty {
            print("📦 UDFRepository hydrated \(cached.count) UDFs from SwiftData")
        }

        let deltaFilter = await SyncCoordinator.shared.deltaFilter(for: RMUserDefinedValue.self)
        let filters: [RMFilter] = deltaFilter.map { [$0] } ?? []
        if deltaFilter != nil {
            print("🔁 UDFRepository delta fetch")
        } else {
            print("🌊 UDFRepository full fetch")
        }

        let fetched: [RMUserDefinedValue]
        do {
            fetched = try await RMAPIClient.shared.send(GetUserDefinedFieldsRequest(filters: filters))
        } catch {
            print("❌ UDFRepository fetch failed: \(error.localizedDescription)")
            return cached
        }

        if !fetched.isEmpty {
            await Self.persistUDFs(fetched)
        }

        await SyncCoordinator.shared.markSynced(RMUserDefinedValue.self)

        // Return the merged world (post-upsert).
        return await Self.loadCachedUDFs()
    }

    /// Read-without-sync. Useful for callers that want the current cache
    /// without triggering a network hit.
    func allUDFs() async -> [RMUserDefinedValue] {
        await Self.loadCachedUDFs()
    }

    // MARK: - Private helpers

    @MainActor
    private static func loadCachedUDFs() -> [RMUserDefinedValue] {
        do {
            return try SwiftDataManager.shared.loadAll(of: RMUserDefinedValue.self)
        } catch {
            print("❌ UDFRepository loadCachedUDFs: \(error.localizedDescription)")
            return []
        }
    }

    @MainActor
    private static func persistUDFs(_ udfs: [RMUserDefinedValue]) {
        do {
            try SwiftDataManager.shared.save(udfs)
        } catch {
            print("❌ UDFRepository persistUDFs: \(error.localizedDescription)")
        }
    }
}
