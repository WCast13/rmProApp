//
//  RMDataManager.swift
//  rmProApp
//
//  Created by William Castellano on 9/19/25.
//

import Foundation

@MainActor
class RMDataManager: ObservableObject {
    
    @Published var unitsWithBasicData: [RMUnit] = []
    @Published var vacantUnits: [RMUnit] = []
    
    static let shared = RMDataManager()
    
    private init() {}
    
    func loadUnitsWithBasicData() async {
        let request = GetUnitsRequest(
            embeds: [.addresses, .isVacant, .leases, .unitType],
            fields: [.addresses, .leases, .name, .unitType, .isVacant, .propertyID, .unitID]
        )
        do {
            unitsWithBasicData = try await RMAPIClient.shared.send(request)
        } catch {
            print("❌ loadUnitsWithBasicData failed: \(error.localizedDescription)")
            unitsWithBasicData = []
        }
        vacantUnits = unitsWithBasicData.filter { $0.isVacant == true && $0.name?.components(separatedBy: " ").last != "Loan" }

        print("\n\n")
        print("Units: \(unitsWithBasicData.count)")
        print("Vacant Units: \(vacantUnits.count)")
    }

    func loadUnits() async {
        let request = GetUnitsRequest(
            embeds: [.addresses, .currentOccupants, .isVacant, .primaryAddress, .property, .property_Addresses, .leases_Tenant, .leases, .unitType],
            fields: [.addresses, .currentOccupants, .isVacant, .leases, .name, .primaryAddress, .property, .propertyID, .unitType, .userDefinedValues, .unitID]
        )
        do {
            unitsWithBasicData = try await RMAPIClient.shared.send(request)
        } catch {
            print("❌ loadUnits failed: \(error.localizedDescription)")
            unitsWithBasicData = []
        }
        vacantUnits = unitsWithBasicData.filter { $0.isVacant == true && $0.name?.components(separatedBy: " ").last != "Loan" }

        print("\n\n")
        print("Units: \(unitsWithBasicData.count)")
        print("Vacant Units: \(vacantUnits.count)")
    }

    func loadUserDefinedValues(deltaFilter: RMFilter? = nil) async -> [RMUserDefinedValue] {
        let filters: [RMFilter] = deltaFilter.map { [$0] } ?? []
        let label = deltaFilter == nil ? "UDFs (full sync)" : "UDFs (delta)"
        if deltaFilter != nil {
            print("🔁 loadUserDefinedValues delta: UpdateDate,gte,...")
        }

        do {
            let result = try await RMAPIClient.shared.send(GetUserDefinedFieldsRequest(filters: filters))
            print("✅ \(label): \(result.count) records")
            return result
        } catch {
            print("❌ loadUserDefinedValues failed: \(error.localizedDescription)")
            return []
        }
    }

    // MARK: - Startup Cache Management

    /// SwiftData-cache-first + SyncCoordinator delta sync on startup
    @MainActor
    func loadUDFsOnStartup() async -> [RMUserDefinedValue] {
        // 1. Hydrate from SwiftData for instant availability
        var cached: [RMUserDefinedValue] = []
        do {
            cached = try SwiftDataManager.shared.loadAll(of: RMUserDefinedValue.self)
            if !cached.isEmpty {
                print("📦 Hydrated \(cached.count) UDFs from SwiftData cache")
            }
        } catch {
            print("❌ UDF cache hydrate failed: \(error.localizedDescription)")
        }

        // 2. Delta (or full) sync via SyncCoordinator
        let deltaFilter = await SyncCoordinator.shared.deltaFilter(for: RMUserDefinedValue.self)
        let fetched = await loadUserDefinedValues(deltaFilter: deltaFilter)

        // 3. Upsert fetched records via @Attribute(.unique) id
        if !fetched.isEmpty {
            do {
                try SwiftDataManager.shared.save(fetched)
            } catch {
                print("❌ UDF persist failed: \(error.localizedDescription)")
            }
        }

        await SyncCoordinator.shared.markSynced(RMUserDefinedValue.self)

        // 4. Return the merged cache for callers
        do {
            return try SwiftDataManager.shared.loadAll(of: RMUserDefinedValue.self)
        } catch {
            print("❌ UDF post-sync reload failed: \(error.localizedDescription)")
            return cached.isEmpty ? fetched : cached
        }
    }

    /// Get cached UDFs filtered by parent type
    @MainActor
    func getCachedUDFs(for parentType: String) -> [RMUserDefinedValue] {
        do {
            return try SwiftDataManager.shared.load(
                of: RMUserDefinedValue.self,
                where: #Predicate { $0.parentType == parentType }
            )
        } catch {
            print("❌ Failed to load cached UDFs for \(parentType): \(error)")
            return []
        }
    }

    /// Force refresh UDFs from API (resets the sync window)
    @MainActor
    func refreshUDFs() async -> [RMUserDefinedValue] {
        print("🔄 Force refreshing UDFs from API...")
        await SyncCoordinator.shared.resetSyncDate(for: RMUserDefinedValue.self)
        return await loadUDFsOnStartup()
    }
}

