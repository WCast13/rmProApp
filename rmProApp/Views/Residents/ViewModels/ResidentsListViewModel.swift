//
//  ResidentsListViewModel.swift
//  rmProApp
//
//  Owns the filter + search state for the residents list. Reads the
//  shared tenant list from TenantDataManager (still the app-scope store
//  until per-entity repositories take over the orchestration in a later
//  phase), and exposes a derived `filteredTenants` for the view.
//

import Foundation

@Observable
@MainActor
final class ResidentsListViewModel {
    enum Filter: String, CaseIterable, Identifiable {
        case all = "All Residents"
        case haven = "Haven"
        case pembroke = "Pembroke"
        case delinquent = "Delinquent"
        case fireProtectionGroup = "Fire Protection Group"
        case ptpA = "Prospectus A"
        case ptpWater = "Prospectus B - Lake"
        case ptpDry = "Prospectus B - Dry"
        case loans = "Loans"

        var id: String { rawValue }
    }

    var searchText: String = ""
    var selectedFilter: Filter = .all
    var isShowingFilters: Bool = false

    private let tenantDataManager: TenantDataManager

    init(tenantDataManager: TenantDataManager) {
        self.tenantDataManager = tenantDataManager
    }

    var filteredTenants: [WCLeaseTenant] {
        let residents = tenantDataManager.allUnitTenants
        let query = searchText.lowercased()

        return residents.filter { tenant in
            let matchesSearch = query.isEmpty
                || tenant.name?.lowercased().contains(query) == true
                || tenant.lease?.unit?.name?.lowercased().contains(query) == true

            guard matchesSearch else { return false }

            switch selectedFilter {
            case .all:
                return true
            case .haven:
                return tenant.propertyID == 3
            case .pembroke:
                return tenant.propertyID == 12
            case .delinquent:
                return (tenant.openBalance ?? 0) > 0
            case .fireProtectionGroup:
                return tenant.lease?.unit?.unitType?.name == "HEI- Fire Protection"
            case .ptpA:
                return tenant.lease?.unit?.unitType?.name == "PTP- Pros A"
            case .ptpWater:
                return tenant.lease?.unit?.unitType?.name == "PTP- Pros B - Lake"
            case .ptpDry:
                return tenant.lease?.unit?.unitType?.name == "PTP- Pros B - Dry"
            case .loans:
                return (tenant.loans?.count ?? 0) > 0
            }
        }
        .sorted { ($0.lease?.unit?.name ?? "") < ($1.lease?.unit?.name ?? "") }
    }
}
