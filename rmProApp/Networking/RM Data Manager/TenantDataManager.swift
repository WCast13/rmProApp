//
//  TenantDataManager.swift
//  rmProApp
//
//  Created by William Castellano on 4/11/25.
//

import Foundation
import Combine

@MainActor
class TenantDataManager: ObservableObject {
    // MARK: Main Tenant Groups
    @Published var havenTenants: [RMTenant] = []
    @Published var pembrokeTenants: [RMTenant] = []
    @Published var allTenants: [RMTenant] = []
    @Published var singleTenant: RMTenant?
    @Published var allUnitTenants: [WCLeaseTenant] = []
    
    // TODO: Dashboard Filters
    @Published var tenantsInDeliquency: [RMTenant]?
    @Published var tenantsInEviction: [RMTenant]? // TODO: Need RMEviction
    @Published var tenantPaymentReturns: [RMTenant]? // TODO: Might Not Need
    @Published var rentIncreaseTenants: [WCRentIncreaseTenant] = []
    
    // Performance tracking
    @Published var isLoading = false
    @Published var loadingMessage = ""
    
    // Caching
    private var tenantCache: [String: (tenant: RMTenant, timestamp: Date)] = [:]
    private let cacheTimeout: TimeInterval = 300 // 5 minutes
    private var cancellables = Set<AnyCancellable>()
    
    // API Client - Using optimized version
    private let apiClient = OptimizedAPIClient.shared
    
    static let shared = TenantDataManager()
    
    private init() {
        setupPropertyObservers()
    }
    
    private func setupPropertyObservers() {
        // Auto-update property-specific arrays when allTenants changes
        $allTenants
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tenants in
                self?.havenTenants = tenants.filter { $0.propertyID == 1 }
                self?.pembrokeTenants = tenants.filter { $0.propertyID == 3 }
                self?.tenantsInDeliquency = tenants.filter { ($0.balance ?? 0) > 0 }
            }
            .store(in: &cancellables)
    }
    
    
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
    
    // MARK: Fetch Tenants - OPTIMIZED with Parallel Execution
    func fetchTenants() async {
        isLoading = true
        loadingMessage = "Fetching tenant data..."
        let startTime = Date()
        
        // Fetch base tenant data first
        allTenants = await fetchTenantBase()
        
        // Fetch all sections in parallel using TaskGroup
        await withTaskGroup(of: (TenantDataSection, [RMTenant]?).self) { group in
            // Add tasks for each section
            group.addTask { [weak self] in
                let data = await self?.fetchSectionData(embeds: TenantEmbeds.leaseEmbeds, fields: TenantFields.leaseFields, section: .leases)
                return (.leases, data)
            }
            
            group.addTask { [weak self] in
                let data = await self?.fetchSectionData(embeds: TenantEmbeds.contactsEmbeds, fields: TenantFields.contactFields, section: .contacts)
                return (.contacts, data)
            }
            
            group.addTask { [weak self] in
                let data = await self?.fetchSectionData(embeds: TenantEmbeds.addressEmbeds, fields: TenantFields.addressFields, section: .addresses)
                return (.addresses, data)
            }
            
            // Also load units in parallel
            group.addTask {
                await UnitDataManager.shared.loadUnitsWithBasicData()
                return (.userDefinedValues, nil) // Dummy return for units task
            }
            
            // Process results as they complete
            for await (section, data) in group {
                if let tenantData = data {
                    for newData in tenantData {
                        mergeTenant(newData: newData, section: section)
                    }
                }
            }
        }
        
        buildRentIncreaseTenants()
        
        let duration = Date().timeIntervalSince(startTime)
        print("✅ Total fetch completed in \(String(format: "%.2f", duration)) seconds")
        
        isLoading = false
        loadingMessage = ""
    }
    
    private func fetchTenantBase() async -> [RMTenant] {
        let filters = [
            RMFilter(key: "Status", operation: "ne", value: "Past")
        ]
        
        guard let url = URLBuilder.shared.buildURL(endpoint: .tenants, filters: filters) else {
            return []
        }
        
        let (result, _) = await timeAPICall("Base fetch for tenants") {
            // Use optimized client with high priority for base data
            await apiClient.request(url: url, responseType: [RMTenant].self, priority: .high) ?? []
        }
        
        return result
    }
    
    // New optimized section fetch that returns data for parallel processing
    private func fetchSectionData(embeds: [TenantEmbeds], fields: [TenantFields], section: TenantDataSection) async -> [RMTenant]? {
        let embedsString = embeds.map(\.rawValue).joined(separator: ",")
        let fieldsString = fields.map(\.rawValue).joined(separator: ",")
        
        let filters = [
            RMFilter(key: "Status", operation: "ne", value: "Past")
        ]
        
        guard let url = URLBuilder.shared.buildURL(endpoint: .tenants, embeds: embedsString, fields: fieldsString, filters: filters) else {
            print("❌ Failed to build section URL for \(section)")
            return nil
        }
        
        // Use optimized client with caching
        let tenantData: [RMTenant]? = await apiClient.request(
            url: url, 
            responseType: [RMTenant].self,
            cachePolicy: .useCache,
            priority: .medium
        )
        
        return tenantData
    }
    
    private func fetchSection(for tenants: [RMTenant], embeds: [TenantEmbeds], fields: [TenantFields], section: TenantDataSection) async {
        if let data = await fetchSectionData(embeds: embeds, fields: fields, section: section) {
            for newData in data {
                mergeTenant(newData: newData, section: section)
            }
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
        }
        
        allTenants[index] = existing
//        print(allTenants.count)
    }
    
    // MARK: Get Single Tenant - OPTIMIZED with Caching
    func fetchSingleTenant(tenantID: String) async -> RMTenant? {
        // Check cache first
        if let cached = getCachedTenant(id: tenantID) {
            singleTenant = cached
            return cached
        }
        
        // Check if tenant exists in allTenants array
        if let existing = allTenants.first(where: { $0.tenantID == Int(tenantID) }) {
            // If we have basic data, check if we need full details
            if existing.leases != nil && existing.contacts != nil {
                singleTenant = existing
                return existing
            }
        }
        
        let fullEmbedsString = TenantEmbeds.fullEmbeds.map { $0.rawValue }.joined(separator: ",")
        let fullFieldsString = TenantFields.fullFields.map { $0.rawValue }.joined(separator: ",")
        
        guard let url = URLBuilder.shared.buildURL(endpoint: .tenants, embeds: fullEmbedsString, fields: fullFieldsString, id: tenantID) else {
            return nil
        }
        
        // Use optimized client with high priority for single tenant
        singleTenant = await apiClient.request(
            url: url, 
            responseType: RMTenant.self,
            cachePolicy: .useCache,
            priority: .high
        )
        
        // Cache the result
        if let tenant = singleTenant {
            cacheTenant(tenant, id: tenantID)
        }
        
        return singleTenant
    }
    
    func fetchSingleTenantTransactions(tenantID: String) async -> RMTenant? {
        let transactionsEmbeds: [TenantEmbeds] = [.charges, .charges_ChargeType, .payments, .paymentReversals]
        let transactionsFields: [TenantFields] = [.charges, .payments, .paymentReversals]
        
        let transactionEmbedsString = transactionsEmbeds.map { $0.rawValue }.joined(separator: ",")
        let transactionFieldsString = transactionsFields.map { $0.rawValue }.joined(separator: ",")
        
        guard let transactionURL = URLBuilder.shared.buildURL(endpoint: .tenants, embeds: transactionEmbedsString, fields: transactionFieldsString, id: tenantID) else {
            return nil
        }
        
        // Use optimized client with caching for transactions
        let transactions = await apiClient.request(
            url: transactionURL, 
            responseType: RMTenant.self,
            cachePolicy: .useCache,
            priority: .medium
        )
        return transactions
    }
    
    // OPTIMIZED: Batch fetch addresses and contacts together
    func fetchAddressesAndContacts(tenant: WCLeaseTenant) async -> (addresses: [RMAddress], contacts: [RMContact]) {
        guard let tenantID = tenant.tenantID else {
            return ([], [])
        }
        
        // Fetch both in parallel
        async let addressesFetch = fetchAddresses(tenant: tenant)
        async let contactsFetch = fetchContacts(tenant: tenant)
        
        let addresses = await addressesFetch
        let contacts = await contactsFetch
        
        return (addresses, contacts)
    }
    
    func fetchAddresses(tenant: WCLeaseTenant) async -> [RMAddress] {
        let addressEmbeds: [TenantEmbeds] = [.addresses, .addresses_AddressType]
        let addressFields: [TenantFields] = [.addresses]
        
        let addressEmbedsString = addressEmbeds.map { $0.rawValue }.joined(separator: ",")
        let addressFieldsString = addressFields.map { $0.rawValue }.joined(separator: ",")
        
        guard let addressURL = URLBuilder.shared.buildURL(endpoint: .tenants, embeds: addressEmbedsString, fields: addressFieldsString, id: String(tenant.tenantID ?? 0)) else {
            return []
        }
        
        let tenantAddresses = await apiClient.request(
            url: addressURL, 
            responseType: RMTenant.self,
            cachePolicy: .useCache
        )
        
        return tenantAddresses?.addresses ?? []
    }
    
    func fetchContacts(tenant: WCLeaseTenant) async -> [RMContact] {
        let contactEmbeds: [TenantEmbeds] = [.contacts]
        let contactFields: [TenantFields] = [.contacts]
        
        let contactEmbedsString = contactEmbeds.map { $0.rawValue }.joined(separator: ",")
        let contactFieldsString = contactFields.map { $0.rawValue }.joined(separator: ",")
        
        guard let contactURL = URLBuilder.shared.buildURL(endpoint: .tenants, embeds: contactEmbedsString, fields: contactFieldsString, id: "\(tenant.tenantID ?? 0)") else {
            return []
        }
        
        let contacts = await apiClient.request(
            url: contactURL, 
            responseType: RMTenant.self,
            cachePolicy: .useCache
        )
        
        return contacts?.contacts ?? []
    }
    
    // MARK: Generate Rent Increase Tenants for Mailing Labels
    // TODO: Need to Add Vacant Units to List
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

            }
        }
        
        self.rentIncreaseTenants = rentIncreaseTenants
    }
    
    // MARK: - Cache Management
    private func getCachedTenant(id: String) -> RMTenant? {
        guard let cached = tenantCache[id],
              Date().timeIntervalSince(cached.timestamp) < cacheTimeout else {
            return nil
        }
        return cached.tenant
    }
    
    private func cacheTenant(_ tenant: RMTenant, id: String) {
        tenantCache[id] = (tenant, Date())
    }
    
    func clearCache() {
        tenantCache.removeAll()
        apiClient.clearCache()
    }
    
    // MARK: - Performance Helpers
    func prefetchTenants(tenantIDs: [String]) async {
        await withTaskGroup(of: Void.self) { group in
            for id in tenantIDs {
                group.addTask { [weak self] in
                    _ = await self?.fetchSingleTenant(tenantID: id)
                }
            }
        }
    }
}
