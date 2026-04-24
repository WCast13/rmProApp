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

    func loadUserDefinedValues() async -> [RMUserDefinedValue] {
        do {
            return try await RMAPIClient.shared.send(GetUserDefinedFieldsRequest())
        } catch {
            print("❌ loadUserDefinedValues failed: \(error.localizedDescription)")
            return []
        }
    }

    // MARK: - Startup Cache Management

    /// Load UDFs with cache-first strategy on startup
    @MainActor
    func loadUDFsOnStartup() async -> [RMUserDefinedValue] {
        do {
            // Try to load from SwiftData first
            let cachedUDFs = try SwiftDataManager.shared.loadAll(of: RMUserDefinedValue.self)

            if !cachedUDFs.isEmpty {
                // Check if any cached data is stale
                let staleUDFs = cachedUDFs.filter { $0.isStale() }

                if staleUDFs.isEmpty {
                    print("📦 Using fresh cached UDFs (\(cachedUDFs.count) items)")
                    return cachedUDFs
                } else {
                    print("⏰ Found \(staleUDFs.count) stale UDFs, refreshing from API...")
                }
            } else {
                print("📭 No cached UDFs found, loading from API...")
            }

            // Load fresh data from API
            let freshUDFs = await loadUserDefinedValues()

            // Update sync dates and save to cache
            for udf in freshUDFs {
                udf.updateSyncDate()
            }

            // Replace all cached UDFs with fresh data
            try SwiftDataManager.shared.replaceAll(freshUDFs, of: RMUserDefinedValue.self)

            print("✅ Loaded and cached \(freshUDFs.count) UDFs on startup")
            return freshUDFs

        } catch {
            print("❌ Failed to load UDFs from cache: \(error)")

            // Fallback to API only
            let fallbackUDFs = await loadUserDefinedValues()
            print("⚠️ Using API fallback: \(fallbackUDFs.count) UDFs")
            return fallbackUDFs
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

    /// Force refresh UDFs from API
    @MainActor
    func refreshUDFs() async -> [RMUserDefinedValue] {
        print("🔄 Force refreshing UDFs from API...")
        let freshUDFs = await loadUserDefinedValues()

        do {
            // Update sync dates
            for udf in freshUDFs {
                udf.updateSyncDate()
            }

            // Replace cached data
            try SwiftDataManager.shared.replaceAll(freshUDFs, of: RMUserDefinedValue.self)
            print("✅ Refreshed and cached \(freshUDFs.count) UDFs")
        } catch {
            print("⚠️ Failed to cache refreshed UDFs: \(error)")
        }

        return freshUDFs
    }
}

