//
//  TenantDataManager.swift
//  rmProApp
//
//  Created by William Castellano on 4/11/25.
//

import Foundation

@MainActor
class TenantDataManager: ObservableObject {
    @Published var havenTenants: [RMTenant] = []
    @Published var pembrokeTenants: [RMTenant] = []
    @Published var singleTenant: RMTenant?
    
    static let shared = TenantDataManager()
    
    private init() {}
    
    // MARK: Tenant Embeds/Fields
    private let simpleEmbeds: [TenantEmbedOption] = [
            .addresses, .addresses_AddressType, .balance, .color, .contacts,
            .contacts_Addresses, .contacts_ContactType, .contacts_PhoneNumbers,
            .contacts_PhoneNumbers_PhoneNumberType, .contacts_UserDefinedValues,
            .evictions, .evictions_EvictionOutcome, .evictions_EvictionWorkflowStage,
            .leases, .leases_Unit, .leases_Unit_UnitType, .loans, .openBalance,
            .openPrepays, .openReceivables, .openReceivables_ChargeType,
            .primaryContact, .primaryContact_PhoneNumbers,
            .primaryContact_PhoneNumbers_PhoneNumberType, .recurringCharges,
            .recurringChargeSummaries, .recurringChargeSummaries_ChargeType,
            .securityDepositHeld, .securityDepositSummaries, .userDefinedValues,
            .vehicles
        ]
        
        private let simpleFields: [TenantFieldOption] = [
            .addresses, .balance, .colorID, .comment, .contacts, .evictionID,
            .evictions, .firstName, .lastName, .leases, .loans, .name,
            .openBalance, .openReceivables, .primaryContact, .propertyID,
            .recurringCharges, .recurringChargeSummaries, .securityDepositHeld,
            .securityDepositSummaries, .status, .tenantDisplayID, .tenantID,
            .updateDate, .updateUserID, .userDefinedValues, .vehicles
        ]
        
        private let fullEmbeds: [TenantEmbedOption] = [
            .addresses, .addresses_AddressType, .balance, .charges, .color,
            .contacts, .contacts_Addresses, .contacts_ContactType,
            .contacts_PhoneNumbers, .contacts_PhoneNumbers_PhoneNumberType,
            .contacts_UserDefinedValues, .evictions, .evictions_EvictionOutcome,
            .evictions_EvictionWorkflowStage, .history, .leases, .leases_Property,
            .leases_Unit, .leases_Unit_Property, .leases_Unit_UnitType, .loans,
            .openBalance, .openPrepays, .openReceivables, .openReceivables_ChargeType,
            .payments, .paymentReversals, .primaryContact,
            .primaryContact_PhoneNumbers, .primaryContact_PhoneNumbers_PhoneNumberType,
            .recurringCharges, .recurringChargeSummaries,
            .recurringChargeSummaries_ChargeType, .securityDepositHeld,
            .securityDepositSummaries, .tenantBills, .tenantChecks,
            .userDefinedValues, .vehicles
        ]
        
        private let fullFields: [TenantFieldOption] = [
            .addresses, .balance, .charges, .colorID, .comment, .contacts,
            .evictionID, .evictions, .firstName, .history, .historyEviction,
            .historyEvictionNotes, .lastName, .leases, .loans, .name,
            .openBalance, .openReceivables, .payments, .paymentReversals,
            .primaryContact, .propertyID, .recurringCharges,
            .recurringChargeSummaries, .securityDepositHeld,
            .securityDepositSummaries, .status, .tenantDisplayID, .tenantID,
            .updateDate, .updateUserID, .userDefinedValues, .vehicles
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
            havenTenants = await RentManagerAPIClient.shared.request(url: havenUrl, responseType: [RMTenant].self) ?? []
            pembrokeTenants = await RentManagerAPIClient.shared.request(url: pembrokeUrl, responseType: [RMTenant].self) ?? []
        }
    }
    
    // MARK: Get Single Tenant- Details
    func fetchSingleTenant(tenantID: String) async {
        let fullEmbedsString = fullEmbeds.map { $0.rawValue }.joined(separator: ",")
        let fullFieldsString = fullFields.map { $0.rawValue }.joined(separator: ",")
        
        let singleTenantUrl = URLBuilder.shared.buildURL(endpoint: .tenants, embeds: fullEmbedsString, fields: fullFieldsString, id: tenantID)
        
        if let url = singleTenantUrl {
            singleTenant = await RentManagerAPIClient.shared.request(url: url, responseType: RMTenant.self)
        }
    }
}





















// MARK: Tenant Embeds/Fields for future modification
/*
 let embeds: [TenantEmbedOption] = [
     .addresses,
     .addresses_AddressType,
     .balance,
     .charges,
     .color,
     .contacts,
     .contacts_Addresses,
     .contacts_ContactType,
     .contacts_PhoneNumbers,
     .contacts_PhoneNumbers_PhoneNumberType,
     .contacts_UserDefinedValues,
     .evictions,
     .evictions_EvictionOutcome,
     .evictions_EvictionWorkflowStage,
     .history,
     .leases,
     .leases_Property,
     .leases_Unit,
     .leases_Unit_Property,
     .leases_Unit_UnitType,
     .loans,
     .openBalance,
     .openPrepays,
     .openReceivables,
     .openReceivables_ChargeType,
     .payments,
     .paymentReversals,
     .primaryContact,
     .primaryContact_PhoneNumbers,
     .primaryContact_PhoneNumbers_PhoneNumberType,
     .recurringCharges,
     .recurringChargeSummaries,
     .recurringChargeSummaries_ChargeType,
     .securityDepositHeld,
     .securityDepositSummaries,
     .tenantBills,
     .tenantChecks,
     .userDefinedValues,
     .vehicles
 ]
 let fields: [TenantFieldOption] = [
     .addresses,
     .balance,
     .charges,
     .colorID,
     .comment,
     .contacts,
     .evictionID,
     .evictions,
     .firstName,
     .history,
     .historyEviction,
     .historyEvictionNotes,
     .lastName,
     .leases,
     .loans,
     .name,
     .openBalance,
     .openReceivables,
     .payments,
     .paymentReversals,
     .primaryContact,
     .propertyID,
     .recurringCharges,
     .recurringChargeSummaries,
     .securityDepositHeld,
     .securityDepositSummaries,
     .status,
     .tenantDisplayID,
     .tenantID,
     .updateDate,
     .updateUserID,
     .userDefinedValues,
     .vehicles
 ]
 */


