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
    
    // TODO: Dashboard Filters
    @Published var tenantsInDeliquency: [RMTenant]?
    @Published var tenantsInEviction: [RMTenant]? // TODO: Need RMEviction
    @Published var tenantPaymentReturns: [RMTenant]? // TODO: Might Not Need
    @Published var rentIncreaseTenants: [WCRentIncreaseTenant] = []
    
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
        .addresses, .addresses_AddressType, .balance, .color, .contacts, .contacts_PhoneNumbers, .contacts_PhoneNumbers_PhoneNumberType, .evictions, .evictions_EvictionOutcome, .evictions_EvictionWorkflowStage, .leases, .leases_Unit, .leases_Unit_UnitType, .leases_Unit_Addresses, .loans, .openBalance, .openPrepays, .openReceivables, .openReceivables_ChargeType, .paymentReversals ,  .recurringChargeSummaries, .securityDepositHeld, .securityDepositSummaries, .userDefinedValues, .vehicles
    ]
    
    private let simpleFields: [TenantFieldOption] = [
        .addresses, .balance, .colorID, .comment, .contacts, .evictionID, .evictions, .firstName, .lastName, .leases, .loans, .name, .openBalance, .openReceivables, .paymentReversals, .propertyID,  .recurringChargeSummaries, .securityDepositHeld, .securityDepositSummaries, .status, .tenantDisplayID, .tenantID, .updateDate, .updateUserID, .userDefinedValues, .vehicles
    ]
    
    private let fullEmbeds: [TenantEmbedOption] = [
        .addresses, .addresses_AddressType, .balance, .charges, .color, .contacts, .contacts_Addresses, .contacts_ContactType, .contacts_PhoneNumbers, .contacts_PhoneNumbers_PhoneNumberType, .contacts_UserDefinedValues, .evictions, .evictions_EvictionOutcome, .evictions_EvictionWorkflowStage, .history, .leases, .leases_Property, .leases_Unit, .leases_Unit_Property, .leases_Unit_Addresses, .leases_Unit_UnitType, .loans, .openBalance, .openPrepays, .openReceivables, .openReceivables_ChargeType, .payments, .paymentReversals, .primaryContact, .primaryContact_PhoneNumbers, .primaryContact_PhoneNumbers_PhoneNumberType,  .recurringChargeSummaries, .recurringChargeSummaries_ChargeType, .securityDepositHeld, .securityDepositSummaries, .tenantBills, .tenantChecks, .userDefinedValues, .vehicles
    ]
    
    private let fullFields: [TenantFieldOption] = [
        .addresses, .balance, .charges, .colorID, .comment, .contacts, .evictionID, .evictions, .firstName, .history, .historyEviction, .historyEvictionNotes, .lastName, .leases, .loans, .name, .openBalance, .openReceivables, .payments, .paymentReversals, .primaryContact, .propertyID,  .recurringChargeSummaries, .securityDepositHeld, .securityDepositSummaries, .status, .tenantDisplayID, .tenantID, .updateDate, .updateUserID, .userDefinedValues, .vehicles
    ]
    
    private let transactionsEmbeds: [TenantEmbedOption] = [.charges, .charges_ChargeType, .payments, .paymentReversals]
    private let transactionsFields: [TenantFieldOption] = [.charges, .payments, .paymentReversals]
    
    private let addressEmbeds: [TenantEmbedOption] = [.addresses, .addresses_AddressType]
    private let addressFields: [TenantFieldOption] = [.addresses]
    
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
    
    func fetchSingleTenantTransactions(tenantID: String) async -> RMTenant? {
        let transactionsEmbeds: [TenantEmbedOption] = [.charges, .charges_ChargeType, .payments, .paymentReversals]
        let transactionsFields: [TenantFieldOption] = [.charges, .payments, .paymentReversals]
        
        let transactionEmbedsString = transactionsEmbeds.map { $0.rawValue }.joined(separator: ",")
        let transactionFieldsString = transactionsFields.map { $0.rawValue }.joined(separator: ",")
        
        let transactionURL: URL? = URLBuilder.shared.buildURL(endpoint: .tenants, embeds: transactionEmbedsString, fields: transactionFieldsString, id: tenantID)
        
        let transactions = await RentManagerAPIClient.shared.request(url: transactionURL!, responseType: RMTenant.self)
        return transactions
    }
    
    func fetchAddresses(tenantID: String) async -> RMTenant? {
        let addressEmbeds: [TenantEmbedOption] = [.addresses, .addresses_AddressType]
        let addressFields: [TenantFieldOption] = [.addresses]
        
        let addressEmbedsString = addressEmbeds.map { $0.rawValue }.joined(separator: ",")
        let addressFieldsString = addressFields.map { $0.rawValue }.joined(separator: ",")
        
        let addressURL: URL? = URLBuilder.shared.buildURL(endpoint: .tenants, embeds: addressEmbedsString, fields: addressFieldsString, id: tenantID)
        
        let tenantAddresses = await RentManagerAPIClient.shared.request(url: addressURL!, responseType: RMTenant.self)
        
        return tenantAddresses
    }

    // MARK: Combines Haven and Pembroke Residents
    func buildFilteredResidents() {
        allTenants = havenTenants + pembrokeTenants
        print(("All Tenants Count: \(allTenants.count)"))

        rentIncreaseTenants = buildRentIncreaseTenants()
        
    }
    
    // MARK: Generate Rent Increase Tenants for Mailing Labels
    // TODO: Need to Add Vacant Units to List
    func buildRentIncreaseTenants() -> [WCRentIncreaseTenant] {
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
//        print("Total Rent Increase Tenants: \(unitCount)")
        return rentIncreaseTenants
    }
    
    func buildTranasactions(tenantID: Int) async {
        let tenant = pembrokeTenants.filter { $0.tenantID == tenantID }.first
        print("Start Build Transactions")
        print("***************************************")
        print(tenant?.tenantDisplayID ?? 0)
        print(tenant?.name ?? "")
        let charges = tenant?.charges ?? []
        let payments = tenant?.payments ?? []
        let paymentReversals = tenant?.paymentReversals ?? []
        
        let charge = charges.first
        print(charge?.amount ?? 0.0)
        print(charge?.amountAllocated ?? 0.0)
        print(charge?.accountType ?? "")
        print(charge?.comment ?? "")
        print(charge?.transactionDate ?? Date())
        print(charge?.isFullyAllocated ?? false)
        print(charge?.chargeTypeID ?? 0)
        
        let payment = payments.first
        print(payment?.amount ?? 0.0)
        print(payment?.accountType ?? "")
        print(payment?.amountAllocated ?? 0.0)
        print(payment?.comment ?? "")
        print(payment?.isFullyAllocated ?? false)
        print(payment?.reversalDate ?? Date())
        print(payment?.reversalType ?? "")
        print(payment?.transactionDate ?? Date())
        print(payment?.transactionType ?? "")
        
        print(charges.count)
        print(payments.count)
        print(paymentReversals.count)
        
    }
}

func makeLeaseTenants(tenant: RMTenant, lease: RMLease) -> WCLeaseTenant {
    let leaseTenant = WCLeaseTenant(
        accountGroupID: tenant.accountGroupID,
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

