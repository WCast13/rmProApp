//
//  TenantDataManager.swift
//  rmProApp
//
//  Created by William Castellano on 4/11/25.
//

import Foundation

@MainActor
class TenantDataManager: ObservableObject {
    // MARK: Main Tenant Groups
    @Published var havenTenants: [RMTenant] = []
    @Published var pembrokeTenants: [RMTenant] = []
    @Published var allTenants: [RMTenant] = []
    @Published var singleTenant: RMTenant?
    @Published var allUnitTenants: [WCLeaseTenant] = []
    @Published var allUnits : [RMUnit] = []

    @Published var tenantsInDeliquency: [RMTenant]?
    @Published var rentIncreaseTenants: [WCRentIncreaseTenant] = []

    // MARK: Caching and Performance
    private var tenantCache: [String: RMTenant] = [:]
    private var lastFetchTime: Date?
    private let cacheTimeout: TimeInterval = 300 // 5 minutes
    private var isCurrentlyFetching = false

    static let shared = TenantDataManager()

    private init() {}
    
    
    // Enum representing different tenant data categories that may be updated
    enum TenantDataSection {
        case leases
        case contacts
        case addresses
        case charges
        case payments
        case paymentReversals
        case recurringCharges
        case userDefinedValues
        case loans
    }
    
    // MARK: Temporary Timing Function
    // Temporary Function- time api calls
    private func timeAPICall<T>(_ label: String, _ operation: () async -> T) async -> (result: T, duration: TimeInterval) {
        let startTime = Date()
        let result = await operation()
        let duration = Date().timeIntervalSince(startTime)
        print("\(label): \(duration) seconds")
        return (result, duration)
    }
    
    // MARK: Fetch Tenants- Haven/Pembroke
    func fetchTenants(forceRefresh: Bool = false) async {
        // Check if we should use cached data
        if !forceRefresh, let lastFetch = lastFetchTime,
           Date().timeIntervalSince(lastFetch) < cacheTimeout,
           !allTenants.isEmpty {
            print("📋 Using cached tenant data")
            return
        }

        // Prevent concurrent fetches
        if isCurrentlyFetching {
            print("⏳ Fetch already in progress, waiting...")
            return
        }

        isCurrentlyFetching = true
        defer { isCurrentlyFetching = false }

        let startTime = Date()

        // Hydrate from SwiftData on the first call of a fresh launch so the
        // delta merge below has something to merge into.
        if allTenants.isEmpty {
            allTenants = loadCachedTenants()
            if !allTenants.isEmpty {
                print("📦 Hydrated \(allTenants.count) tenants from SwiftData cache")
            }
        }

        // forceRefresh resets the sync window so we pull everything again
        if forceRefresh {
            await SyncCoordinator.shared.resetSyncDate(for: RMTenant.self)
        }

        // 1. Fetch base tenant data (delta if we have a prior sync, full otherwise)
        let deltaFilter = await SyncCoordinator.shared.deltaFilter(for: RMTenant.self)
        let fetched = await fetchTenantBase(deltaFilter: deltaFilter)

        if deltaFilter == nil {
            // First sync this window — fetched IS the world.
            allTenants = fetched
        } else {
            // Delta sync — merge changed records into the existing in-memory set
            for updated in fetched {
                guard let newID = updated.tenantID else { continue }
                if let idx = allTenants.firstIndex(where: { $0.tenantID == newID }) {
                    allTenants[idx] = updated
                } else {
                    allTenants.append(updated)
                }
            }
            print("🔁 Delta sync merged \(fetched.count) updated tenants (total in memory: \(allTenants.count))")
        }

        // Persist the fetched set to SwiftData (upsert via @Attribute(.unique) id)
        if !fetched.isEmpty {
            persistTenants(fetched)
        }

        // Mark the successful sync boundary for the next pull
        await SyncCoordinator.shared.markSynced(RMTenant.self)

        let tenantsSnapshot = self.allTenants

        // 2. Fetch sections concurrently for better performance
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await self.fetchSection(for: tenantsSnapshot, embeds: TenantEmbeds.udfEmbeds, fields: TenantFields.udfFields, section: .userDefinedValues)
            }
            group.addTask {
                await self.fetchSection(for: tenantsSnapshot, embeds: TenantEmbeds.leaseEmbeds, fields: TenantFields.leaseFields, section: .leases)
            }
            group.addTask {
                await self.fetchSection(for: tenantsSnapshot, embeds: TenantEmbeds.contactsEmbeds, fields: TenantFields.contactFields, section: .contacts)
            }
            group.addTask {
                await self.fetchSection(for: tenantsSnapshot, embeds: TenantEmbeds.addressEmbeds, fields: TenantFields.addressFields, section: .addresses)
            }
            group.addTask {
                await self.fetchSection(for: tenantsSnapshot, embeds: TenantEmbeds.loanEmbeds, fields: TenantFields.loanFields, section: .loans)
            }

            // 3. Load units concurrently with other sections
            group.addTask {
                await RMDataManager.shared.loadUnits()
            }
        }

        // 4. Update cache and build derived data
        updateTenantCache()
        buildRentIncreaseTenants()
        lastFetchTime = Date()

        let totalTime = Date().timeIntervalSince(startTime)
        print("🚀 Total fetch time: \(totalTime) seconds")
    }
    
    // MARK: SwiftData-backed tenant cache

    private func loadCachedTenants() -> [RMTenant] {
        do {
            return try SwiftDataManager.shared.loadAll(of: RMTenant.self)
        } catch {
            print("❌ loadCachedTenants failed: \(error.localizedDescription)")
            return []
        }
    }

    private func persistTenants(_ tenants: [RMTenant]) {
        do {
            try SwiftDataManager.shared.save(tenants)
        } catch {
            print("❌ persistTenants failed: \(error.localizedDescription)")
        }
    }

    private func fetchTenantBase(deltaFilter: RMFilter? = nil) async -> [RMTenant] {
        var filters: [RMFilter] = [RMFilter(key: "Status", operation: "ne", value: "Past")]
        if let deltaFilter {
            filters.append(deltaFilter)
            print("🔁 fetchTenantBase delta: \(deltaFilter.key),\(deltaFilter.operation),\(deltaFilter.value)")
        } else {
            print("🌊 fetchTenantBase full sync")
        }

        let label = deltaFilter == nil ? "Base fetch for tenants (full): " : "Base fetch for tenants (delta): "

        let (result, _) = await timeAPICall(label) {
            do {
                return try await RMAPIClient.shared.send(GetTenantsRequest(filters: filters))
            } catch {
                print("❌ fetchTenantBase failed: \(error.localizedDescription)")
                return []
            }
        }

        return result
    }
    
    private func fetchSection(for tenants: [RMTenant], embeds: [TenantEmbeds], fields: [TenantFields], section: TenantDataSection) async {
        let request = GetTenantsRequest(embeds: embeds, fields: fields)

        let (tenantData, duration) = await timeAPICall("Section \(section)") {
            do {
                return try await RMAPIClient.shared.send(request)
            } catch {
                print("❌ fetchSection \(section) failed: \(error.localizedDescription)")
                return []
            }
        }

        for newData in tenantData {
            mergeTenant(newData: newData, section: section)
        }
    }
    
    private func mergeTenant(newData: RMTenant, section: TenantDataSection) {
        
        guard let newID = newData.tenantID, let index = allTenants.firstIndex(where: { $0.tenantID == newID }) else { return }
        var existing = allTenants[index]
        
        switch section {
        case .leases:
            existing.leases = newData.leases
        case .contacts:
            existing.contacts = newData.contacts
        case .charges:
            existing.charges = newData.charges
        case .payments:
            existing.payments = newData.payments
        case .paymentReversals:
            existing.paymentReversals = newData.paymentReversals
        case .addresses:
            existing.addresses = newData.addresses
        case .recurringCharges:
            existing.recurringChargeSummaries = newData.recurringChargeSummaries
        case .userDefinedValues:
            existing.udfs = newData.udfs
        case .loans:
            existing.loans = newData.loans
        }
        
        allTenants[index] = existing
//        print(allTenants.count)
    }
    
    // MARK: Cache Management
    private func updateTenantCache() {
        tenantCache.removeAll()
        for tenant in allTenants {
            if let tenantID = tenant.tenantID {
                tenantCache[String(tenantID)] = tenant
            }
        }
    }

    private func getCachedTenant(id: String) -> RMTenant? {
        return tenantCache[id]
    }

    // MARK: Get Single Tenant- Details
    func fetchSingleTenant(tenantID: String) async -> RMTenant? {
        // Check cache first
        if let cachedTenant = getCachedTenant(id: tenantID) {
            print("📋 Using cached tenant: \(tenantID)")
            singleTenant = cachedTenant
            return cachedTenant
        }

        // If not in cache, fetch from API
        let request = GetTenantDetailRequest(
            tenantID: tenantID,
            embeds: TenantEmbeds.fullEmbeds,
            fields: TenantFields.fullFields
        )

        let (tenant, duration) = await timeAPICall("Single tenant fetch") {
            do {
                return try await RMAPIClient.shared.send(request) as RMTenant?
            } catch {
                print("❌ fetchSingleTenant failed: \(error.localizedDescription)")
                return nil
            }
        }

        if let tenant = tenant {
            singleTenant = tenant
            tenantCache[tenantID] = tenant
        }

        return tenant
    }
    
    func fetchSingleTenantTransactions(tenantID: String) async -> RMTenant? {
        let request = GetTenantDetailRequest(
            tenantID: tenantID,
            embeds: [.charges, .charges_ChargeType, .payments, .paymentReversals],
            fields: [.charges, .payments, .paymentReversals]
        )
        do {
            return try await RMAPIClient.shared.send(request)
        } catch {
            print("❌ fetchSingleTenantTransactions failed: \(error.localizedDescription)")
            return nil
        }
    }

    func fetchAddresses(tenant: WCLeaseTenant) async -> [RMAddress] {
        let request = GetTenantDetailRequest(
            tenantID: String(tenant.tenantID ?? 0),
            embeds: [.addresses, .addresses_AddressType],
            fields: [.addresses]
        )
        do {
            let tenantDetail = try await RMAPIClient.shared.send(request)
            return tenantDetail.addresses ?? []
        } catch {
            print("❌ fetchAddresses failed: \(error.localizedDescription)")
            return []
        }
    }

    func fetchContacts(tenant: WCLeaseTenant) async -> [RMContact] {
        let request = GetTenantDetailRequest(
            tenantID: String(tenant.tenantID ?? 0),
            embeds: [.contacts],
            fields: [.contacts]
        )
        do {
            let tenantDetail = try await RMAPIClient.shared.send(request)
            print(tenantDetail.contacts?.count ?? 0)
            return tenantDetail.contacts ?? []
        } catch {
            print("❌ fetchContacts failed: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: Generate Rent Increase Tenants for Mailing Labels
    func buildRentIncreaseTenants() {
        var rentIncreaseTenants: [WCRentIncreaseTenant] = []
        
        for tenant in allTenants {
            guard let leases = tenant.leases else { continue }
            
            let activeLeases = leases.filter { $0.moveOutDate == nil }
            if activeLeases.isEmpty { continue }
            
            for lease in activeLeases {
                guard let unit = lease.unit, let address = unit.addresses?.first else { continue }
                
                if lease.unit?.unitType?.name == "Loan" {
                    continue
                }
                
                var rentIncreaseTenant = WCRentIncreaseTenant()
                rentIncreaseTenant.unitName = unit.name ?? "No Unit Name"
                rentIncreaseTenant.city = address.city ?? "No City"
                rentIncreaseTenant.state = address.state ?? "No State"
                rentIncreaseTenant.postalCode = address.postalCode ?? "No Zip"
                
                if tenant.propertyID == 3, let streetParts = address.street?.components(separatedBy: "\r\n") {
                    rentIncreaseTenant.street = streetParts.first ?? "No Street"
                    rentIncreaseTenant.boxNumber = streetParts.last ?? "No Box"
                } else {
                    rentIncreaseTenant.street = address.street ?? "No Street"
                    rentIncreaseTenant.boxNumber = ""
                }
                
                rentIncreaseTenant.contacts = tenant.contacts?.filter { $0.isShowOnBill == true } ?? []
                rentIncreaseTenants.append(rentIncreaseTenant)
                
                let tenantToAdd: WCLeaseTenant = makeLeaseTenants(tenant: tenant, lease: lease)
                
                allUnitTenants.append(tenantToAdd)
            }
        }
        
        self.rentIncreaseTenants = rentIncreaseTenants
    }
    
    func makeLeaseTenants(tenant: RMTenant, lease: RMLease) -> WCLeaseTenant {
        let leaseTenant = WCLeaseTenant(
            accountGroupID: tenant.accountGroupID,
            accountGroupMasterTenantID: tenant.accountGroupMasterTenantID,
            addresses: tenant.addresses,
            allLeases: tenant.leases,
            balance: tenant.balance,
            charges: tenant.charges,
            chargeTypes: tenant.chargeTypes,
            checkPayeeName: tenant.checkPayeeName,
            colorID: tenant.colorID,
            comment: tenant.comment,
            contacts: tenant.contacts,
            createDate: tenant.createDate,
            createUserID: tenant.createUserID,
            defaultTaxTypeID: tenant.defaultTaxTypeID,
            doNotAcceptChecks: tenant.doNotAcceptChecks,
            doNotAcceptPayments: tenant.doNotAcceptPayments,
            doNotAllowTWAPayments: tenant.doNotAllowTWAPayments,
            doNotChargeLateFees: tenant.doNotChargeLateFees,
            doNotPrintStatements: tenant.doNotPrintStatements,
            doNotSendARAutomationNotifications: tenant.doNotSendARAutomationNotifications,
            evictionID: tenant.evictionID,
            failedCalls: tenant.failedCalls,
            firstContact: tenant.firstContact,
            firstName: tenant.firstName,
            flexibleRentInternalStatus: tenant.flexibleRentInternalStatus,
            flexibleRentStatus: tenant.flexibleRentStatus,
            isAccountGroupMaster: tenant.isAccountGroupMaster,
            isCompany: tenant.isCompany,
            isProspect: tenant.isProspect,
            isShowCommentBanner: tenant.isShowCommentBanner,
            lastContact: tenant.lastContact,
            lastName: tenant.lastName,
            lastNameFirstName: tenant.lastNameFirstName,
            lease: lease, // Set the single lease
            loans: tenant.loans,
            name: tenant.name,
            openBalance: tenant.openBalance,
            overrideCreateDate: tenant.overrideCreateDate,
            overrideCreateUserID: tenant.overrideCreateUserID,
            overrideReason: tenant.overrideReason,
            overrideScreeningDecision: tenant.overrideScreeningDecision,
            overrideUpdateDate: tenant.overrideUpdateDate,
            overrideUpdateUserID: tenant.overrideUpdateUserID,
            payments: tenant.payments,
            paymentReversals: tenant.paymentReversals,
            postingStartDate: tenant.postingStartDate,
            propertyID: tenant.propertyID,
            recurringChargeSummaries: tenant.recurringChargeSummaries,
            rentDueDay: tenant.rentDueDay,
            rentPeriod: tenant.rentPeriod,
            screeningStatus: tenant.screeningStatus,
            securityDepositHeld: tenant.securityDepositHeld,
            securityDepositSummaries: tenant.securityDepositSummaries,
            statementMethod: tenant.statementMethod,
            status: tenant.status,
            tenantDisplayID: tenant.tenantDisplayID,
            tenantID: tenant.tenantID,
            totalCalls: tenant.totalCalls,
            totalEmails: tenant.totalEmails,
            totalVisits: tenant.totalVisits,
            udfs: tenant.udfs,
            unit: lease.unit, // Use the unit from the lease
            updateDate: tenant.updateDate,
            updateUserID: tenant.updateUserID,
            webMessage: tenant.webMessage,
            primaryContact: tenant.primaryContact
        )
        
        return leaseTenant
    }
}

