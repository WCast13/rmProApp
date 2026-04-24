//
//  TenantDataManager.swift
//  rmProApp
//
//  Created by William Castellano on 4/11/25.
//
//  App-wide tenant store. Holds the hydrated RMTenant list (sourced
//  from TenantRepository) plus the flattened WCLeaseTenant rows the
//  residents list consumes. Kicks off units/tenants fetches on login.
//

import Foundation

@Observable
@MainActor
class TenantDataManager {
    var allTenants: [RMTenant] = []
    var allUnitTenants: [WCLeaseTenant] = []

    private var lastFetchTime: Date?
    private let cacheTimeout: TimeInterval = 300 // 5 minutes
    private var isCurrentlyFetching = false

    static let shared = TenantDataManager()

    private init() {}

    func fetchTenants(forceRefresh: Bool = false) async {
        if !forceRefresh,
           let lastFetch = lastFetchTime,
           Date().timeIntervalSince(lastFetch) < cacheTimeout,
           !allTenants.isEmpty {
            print("📋 Using cached tenant data")
            return
        }

        if isCurrentlyFetching {
            print("⏳ Fetch already in progress, waiting...")
            return
        }

        isCurrentlyFetching = true
        defer { isCurrentlyFetching = false }

        let startTime = Date()

        async let hydrated = TenantRepository.shared.syncFull(forceRefresh: forceRefresh)
        async let _ = RMDataManager.shared.loadUnits()
        allTenants = await hydrated

        allUnitTenants = buildLeaseTenants(from: allTenants)
        lastFetchTime = Date()

        print("🚀 Total fetch time: \(Date().timeIntervalSince(startTime)) seconds")
    }

    /// Flatten hydrated tenants into one row per active, unit-addressed,
    /// non-loan lease. Each row is a WCLeaseTenant scoped to the single
    /// lease — the residents list renders one card per row.
    private func buildLeaseTenants(from tenants: [RMTenant]) -> [WCLeaseTenant] {
        var result: [WCLeaseTenant] = []
        for tenant in tenants {
            guard let leases = tenant.leases else { continue }
            let activeLeases = leases.filter { $0.moveOutDate == nil }
            for lease in activeLeases {
                guard let unit = lease.unit,
                      unit.addresses?.first != nil,
                      unit.unitType?.name != "Loan" else { continue }
                result.append(WCLeaseTenant(tenant: tenant, lease: lease))
            }
        }
        return result
    }
}
