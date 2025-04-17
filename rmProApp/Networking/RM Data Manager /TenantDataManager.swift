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
    
    // TODO: Dashboard Filters
    @Published var tenantsInDeliquency: [RMTenant]?
    @Published var tenantsInEviction: [RMTenant]? // TODO: Need RMEviction
    @Published var tenantPaymentReturns: [RMTenant]? // TODO: Might Not Need
    @Published var rentIncreaseTenants: [RentIncreaseTenant] = []
    
    static let shared = TenantDataManager()
    
    private init() {}
    
    // MARK: Temporary Timing Function
    // Temporary Function- time api calls
    private func timeAPICall<T>(_ label: String, _ operation: () async -> T) async -> (result: T, duration: TimeInterval) {
        let startTime = Date()
        let result = await operation()
        let duration = Date().timeIntervalSince(startTime)
        print("\(label): \(duration) seconds")
        return (result, duration)
    }
    
    
    // MARK: Tenant Embeds/Fields
    private let simpleEmbeds: [TenantEmbedOption] = [
        .addresses, .addresses_AddressType, .balance, .color, .contacts, .contacts_Addresses, .contacts_ContactType, .contacts_PhoneNumbers, .contacts_PhoneNumbers_PhoneNumberType, .contacts_UserDefinedValues, .evictions, .evictions_EvictionOutcome, .evictions_EvictionWorkflowStage, .leases, .leases_Unit, .leases_Unit_UnitType, .leases_Unit_Addresses, .loans, .openBalance, .openPrepays, .openReceivables, .openReceivables_ChargeType, .paymentReversals ,.primaryContact, .primaryContact_PhoneNumbers, .primaryContact_PhoneNumbers_PhoneNumberType,  .recurringChargeSummaries, .recurringChargeSummaries_ChargeType, .securityDepositHeld, .securityDepositSummaries, .userDefinedValues, .vehicles
    ]
    
    private let simpleFields: [TenantFieldOption] = [
        .addresses, .balance, .colorID, .comment, .contacts, .evictionID, .evictions, .firstName, .lastName, .leases, .loans, .name, .openBalance, .openReceivables, .paymentReversals, .primaryContact, .propertyID,  .recurringChargeSummaries, .securityDepositHeld, .securityDepositSummaries, .status, .tenantDisplayID, .tenantID, .updateDate, .updateUserID, .userDefinedValues, .vehicles
    ]
    
    private let fullEmbeds: [TenantEmbedOption] = [
        .addresses, .addresses_AddressType, .balance, .charges, .color, .contacts, .contacts_Addresses, .contacts_ContactType, .contacts_PhoneNumbers, .contacts_PhoneNumbers_PhoneNumberType, .contacts_UserDefinedValues, .evictions, .evictions_EvictionOutcome, .evictions_EvictionWorkflowStage, .history, .leases, .leases_Property, .leases_Unit, .leases_Unit_Property, .leases_Unit_Addresses, .leases_Unit_UnitType, .loans, .openBalance, .openPrepays, .openReceivables, .openReceivables_ChargeType, .payments, .paymentReversals, .primaryContact, .primaryContact_PhoneNumbers, .primaryContact_PhoneNumbers_PhoneNumberType,  .recurringChargeSummaries, .recurringChargeSummaries_ChargeType, .securityDepositHeld, .securityDepositSummaries, .tenantBills, .tenantChecks, .userDefinedValues, .vehicles
    ]
    
    private let fullFields: [TenantFieldOption] = [
        .addresses, .balance, .charges, .colorID, .comment, .contacts, .evictionID, .evictions, .firstName, .history, .historyEviction, .historyEvictionNotes, .lastName, .leases, .loans, .name, .openBalance, .openReceivables, .payments, .paymentReversals, .primaryContact, .propertyID,  .recurringChargeSummaries, .securityDepositHeld, .securityDepositSummaries, .status, .tenantDisplayID, .tenantID, .updateDate, .updateUserID, .userDefinedValues, .vehicles
    ]
    
    // MARK: Fetch Tenants- Haven/Pembroke
    func fetchTenants() async {
        
        let simpleEmbedsString = simpleEmbeds.map { $0.rawValue }.joined(separator: ",")
        let simpleFieldsString = simpleFields.map { $0.rawValue }.joined(separator: ",")
        
        let filtersHaven = [
            RMFilter(key: "PropertyID", operation: "eq", value: "3"),
            RMFilter(key: "Status", operation: "ne", value: "Past")
        ]
        let filtersPembroke = [
            RMFilter(key: "PropertyID", operation: "eq", value: "12"),
            RMFilter(key: "Status", operation: "ne", value: "Past")
        ]
        
        let pageSize = 20000
        
        let havenUrl = URLBuilder.shared.buildURL(endpoint: .tenants, embeds: simpleEmbedsString, fields: simpleFieldsString, filters: filtersHaven, pageSize: pageSize)
        let pembrokeUrl = URLBuilder.shared.buildURL(endpoint: .tenants, embeds: simpleEmbedsString, fields: simpleFieldsString, filters: filtersPembroke, pageSize: pageSize)
        
        if let havenUrl = havenUrl, let pembrokeUrl = pembrokeUrl {
            let (havenResult, havenDuration) = await timeAPICall("Haven tenants fetch") {
                await RentManagerAPIClient.shared.request(url: havenUrl, responseType: [RMTenant].self) ?? []
            }
            
            let (pembrokeResult, pembrokeDuration) = await timeAPICall("Pembroke tenants fetch") {
                await RentManagerAPIClient.shared.request(url: pembrokeUrl, responseType: [RMTenant].self) ?? []
            }
            
            havenTenants = havenResult
            pembrokeTenants = pembrokeResult
            
            print("Haven tenants count: \(havenTenants.count), took \(String(format: "%.3f", havenDuration)) seconds")
            print("Pembroke tenants count: \(pembrokeTenants.count), took \(String(format: "%.3f", pembrokeDuration)) seconds")
        }
        
        await UnitDataManager.shared.loadUnitsWithBasicData()
        buildFilteredResidents()
    }
    
    // MARK: Get Single Tenant- Details
    func fetchSingleTenant(tenantID: String) async -> RMTenant! {
        let fullEmbedsString = fullEmbeds.map { $0.rawValue }.joined(separator: ",")
        let fullFieldsString = fullFields.map { $0.rawValue }.joined(separator: ",")
        
        let singleTenantUrl = URLBuilder.shared.buildURL(endpoint: .tenants, embeds: fullEmbedsString, fields: fullFieldsString, id: tenantID)
        
        if let url = singleTenantUrl {
            singleTenant = await RentManagerAPIClient.shared.request(url: url, responseType: RMTenant.self)
        }
        return singleTenant
    }
    
    // MARK: Generate Rent Increase Tenants for Mailing Labels
    func buildRentIncreaseTenants() -> [RentIncreaseTenant] {
        var rentIncreaseTenants: [RentIncreaseTenant] = []
        
        for tenant in allTenants {
            guard let leases = tenant.leases else { continue }
            
            let activeLeases = leases.filter { $0.moveOutDate == nil }
            if activeLeases.isEmpty { continue }
            
            for lease in activeLeases {
                guard let unit = lease.unit, let address = unit.addresses?.first else { continue }
                
                var rentIncreaseTenant = RentIncreaseTenant()
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
//                unitCount += 1
            }
        }
        
        self.rentIncreaseTenants = rentIncreaseTenants
//        print("Total Rent Increase Tenants: \(unitCount)")
        return rentIncreaseTenants
    }
    
    
    // MARK: Builds Resident Filters for Dashboard
    func buildFilteredResidents() {
        allTenants = havenTenants + pembrokeTenants
        print(("All Tenants Count: \(allTenants.count)"))
        
        tenantsInDeliquency = allTenants.filter { $0.balance ?? 0 > 0.0 }
        print("Tenants in Deliquency Count: \(tenantsInDeliquency?.count ?? 0)")
        
        rentIncreaseTenants = buildRentIncreaseTenants()
    }
}


/*
 // For Mail Labels
 var unitCount = 0
 for tenant in allTenants {
 if tenant.leases?.count ?? 0 > 1 {
 for lease in tenant.leases ?? [] {
 if lease.moveOutDate == nil && lease.unit?.unitType?.name != "Loan" {
 
 print("\(tenant.name ?? "No Name") - \(tenant.tenantID ?? 0)")
 
 if tenant.propertyID == 3 {
 print((lease.unit?.addresses?.first?.street ?? "").components(separatedBy: "\r\n").first ?? "")
 print((lease.unit?.addresses?.first?.street ?? "").components(separatedBy: "\r\n").last ?? "")
 } else {
 print(lease.unit?.addresses?.first?.street ?? "")
 }
 print(lease.unit?.addresses?.first?.city ?? "")
 print(lease.unit?.addresses?.first?.state ?? "")
 print(lease.unit?.addresses?.first?.postalCode ?? "")
 
 print("\n")
 unitCount += 1
 print("Unit Count: \(unitCount)")
 
 }
 }
 } else {
 unitCount += 1
 }
 }
 print(("Unit Count: \(unitCount)"))
 */

