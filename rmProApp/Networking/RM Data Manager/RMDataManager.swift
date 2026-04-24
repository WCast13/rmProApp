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
        unitsWithBasicData = await UnitRepository.shared.syncUnits(.basic)
        recomputeVacantUnits()
    }

    func loadUnits() async {
        unitsWithBasicData = await UnitRepository.shared.syncUnits(.full)
        recomputeVacantUnits()
    }

    private func recomputeVacantUnits() {
        vacantUnits = unitsWithBasicData.filter { $0.isVacant == true && $0.name?.components(separatedBy: " ").last != "Loan" }
        print("Units: \(unitsWithBasicData.count)  Vacant Units: \(vacantUnits.count)")
    }

    // MARK: - UDF sync (delegates to UDFRepository)

    @MainActor
    func loadUDFsOnStartup() async -> [RMUserDefinedValue] {
        await UDFRepository.shared.syncUDFs()
    }

    /// Get cached UDFs filtered by parent type. Direct SwiftData read
    /// (no sync) for view-layer pickers.
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

    /// Force refresh UDFs from API (resets the sync window).
    @MainActor
    func refreshUDFs() async -> [RMUserDefinedValue] {
        print("🔄 Force refreshing UDFs from API...")
        return await UDFRepository.shared.syncUDFs(forceRefresh: true)
    }
}

