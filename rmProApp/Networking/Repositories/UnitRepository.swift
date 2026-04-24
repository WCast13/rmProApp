//
//  UnitRepository.swift
//  rmProApp
//
//  Owns the unit sync pipeline — same shape as TenantRepository but for
//  /Units. Two embed/fields preset tiers are supported via the `Preset`
//  enum so loadUnits (full) and loadUnitsWithBasicData share one code path.
//

import Foundation

actor UnitRepository {
    static let shared = UnitRepository()
    private init() {}

    enum Preset {
        case basic
        case full

        var embeds: [UnitEmbedOption] {
            switch self {
            case .basic:
                return [.addresses, .isVacant, .leases, .unitType]
            case .full:
                return [.addresses, .currentOccupants, .isVacant, .primaryAddress, .property, .property_Addresses, .leases_Tenant, .leases, .unitType]
            }
        }

        var fields: [UnitFieldOption] {
            switch self {
            case .basic:
                return [.addresses, .leases, .name, .unitType, .isVacant, .propertyID, .unitID, .updateDate]
            case .full:
                return [.addresses, .currentOccupants, .isVacant, .leases, .name, .primaryAddress, .property, .propertyID, .unitType, .userDefinedValues, .unitID, .updateDate]
            }
        }

        var label: String {
            switch self {
            case .basic: return "loadUnitsWithBasicData"
            case .full:  return "loadUnits"
            }
        }
    }

    // Canonical in-memory cache of units (post-merge).
    private var cache: [RMUnit] = []

    func syncUnits(_ preset: Preset, forceRefresh: Bool = false) async -> [RMUnit] {
        if cache.isEmpty {
            let cached = await Self.loadCachedUnits()
            if !cached.isEmpty {
                cache = cached
                print("📦 UnitRepository hydrated \(cached.count) units from SwiftData")
            }
        }

        if forceRefresh {
            await SyncCoordinator.shared.resetSyncDate(for: RMUnit.self)
        }

        var filters: [RMFilter] = [RMFilter(key: "Property.IsActive", operation: "eq", value: "true")]
        let deltaFilter = await SyncCoordinator.shared.deltaFilter(for: RMUnit.self)
        if let deltaFilter {
            filters.append(deltaFilter)
            print("🔁 \(preset.label) delta (UpdateDate,gte,\(deltaFilter.value))")
        } else {
            print("🌊 \(preset.label) full fetch")
        }

        let request = GetUnitsRequest(embeds: preset.embeds, fields: preset.fields, filters: filters)
        let fetched: [RMUnit]
        do {
            fetched = try await RMAPIClient.shared.send(request)
        } catch {
            print("❌ UnitRepository \(preset.label) failed: \(error.localizedDescription)")
            return cache
        }

        if deltaFilter == nil {
            cache = fetched
        } else {
            for updated in fetched {
                guard let newID = updated.unitID else { continue }
                if let idx = cache.firstIndex(where: { $0.unitID == newID }) {
                    cache[idx] = updated
                } else {
                    cache.append(updated)
                }
            }
            print("🔁 UnitRepository delta merged \(fetched.count) updated (total: \(cache.count))")
        }

        if !fetched.isEmpty {
            await Self.persistUnits(fetched)
        }

        await SyncCoordinator.shared.markSynced(RMUnit.self)
        return cache
    }

    func allUnits() -> [RMUnit] {
        cache
    }

    // MARK: - Private helpers

    @MainActor
    private static func loadCachedUnits() -> [RMUnit] {
        do {
            return try SwiftDataManager.shared.loadAll(of: RMUnit.self)
        } catch {
            print("❌ UnitRepository loadCachedUnits: \(error.localizedDescription)")
            return []
        }
    }

    @MainActor
    private static func persistUnits(_ units: [RMUnit]) {
        do {
            try SwiftDataManager.shared.save(units)
        } catch {
            print("❌ UnitRepository persistUnits: \(error.localizedDescription)")
        }
    }
}
