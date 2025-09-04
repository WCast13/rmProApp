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
    func fetchTenants() async {
        
        await allTenants = fetchTenantBase()
        await fetchSection(for: allTenants, embeds: TenantEmbeds.udfEmbeds, fields: TenantFields.udfFields, section: .userDefinedValues)
        
        await fetchSection(for: allTenants, embeds: TenantEmbeds.leaseEmbeds, fields: TenantFields.leaseFields, section: .leases)
        await fetchSection(for: allTenants, embeds: TenantEmbeds.contactsEmbeds, fields: TenantFields.contactFields, section: .contacts)
        await fetchSection(for: allTenants, embeds: TenantEmbeds.addressEmbeds, fields: TenantFields.addressFields, section: .addresses)
        await fetchSection(for: allTenants, embeds: TenantEmbeds.loanEmbeds, fields: TenantFields.loanFields, section: .loans)
        
        
        await UnitDataManager.shared.loadUnitsWithBasicData()
        buildRentIncreaseTenants()
    }
    
    private func fetchTenantBase() async -> [RMTenant] {
        let filters = [
            RMFilter(key: "Status", operation: "ne", value: "Past")
        ]
        
        guard let url = URLBuilder.shared.buildURL(endpoint: .tenants, filters: filters) else {
            return []
        }
        
        let (result, _) = await timeAPICall("Base fetch for tenants: ") {
            await RentManagerAPIClient.shared.request(url: url, responseType: [RMTenant].self) ?? []
        }
        
        return result
    }
    
    private func fetchSection(for tenants: [RMTenant], embeds: [TenantEmbeds], fields: [TenantFields], section: TenantDataSection) async {
        
        let embedsString = embeds.map(\.rawValue).joined(separator: ",")
        let fieldsString = fields.map(\.rawValue).joined(separator: ",")
        
        let filters = [
            RMFilter(key: "Status", operation: "ne", value: "Past")
        ]
        
        guard let url = URLBuilder.shared.buildURL(endpoint: .tenants, embeds: embedsString, fields: fieldsString, filters: filters) else {
            print("❌ Failed to build section URL")
            return
        }
        
        let tenantData: [RMTenant] = await RentManagerAPIClient.shared.request(url: url, responseType: [RMTenant].self) ?? []
        
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
    
    // MARK: Get Single Tenant- Details
    func fetchSingleTenant(tenantID: String) async -> RMTenant! {
        let fullEmbedsString = TenantEmbeds.fullEmbeds.map { $0.rawValue }.joined(separator: ",")
        let fullFieldsString = TenantFields.fullFields.map { $0.rawValue }.joined(separator: ",")
        
        let singleTenantUrl = URLBuilder.shared.buildURL(endpoint: .tenants, embeds: fullEmbedsString, fields: fullFieldsString, id: tenantID)
        
        if let url = singleTenantUrl {
            
            singleTenant = await RentManagerAPIClient.shared.request(url: url, responseType: RMTenant.self)
            
        }
        return singleTenant
    }
    
    func fetchSingleTenantTransactions(tenantID: String) async -> RMTenant? {
        let transactionsEmbeds: [TenantEmbeds] = [.charges, .charges_ChargeType, .payments, .paymentReversals]
        let transactionsFields: [TenantFields] = [.charges, .payments, .paymentReversals]
        
        let transactionEmbedsString = transactionsEmbeds.map { $0.rawValue }.joined(separator: ",")
        let transactionFieldsString = transactionsFields.map { $0.rawValue }.joined(separator: ",")
        
        let transactionURL: URL? = URLBuilder.shared.buildURL(endpoint: .tenants, embeds: transactionEmbedsString, fields: transactionFieldsString, id: tenantID)
        
        let transactions = await RentManagerAPIClient.shared.request(url: transactionURL!, responseType: RMTenant.self)
        return transactions
    }
    
    func fetchAddresses(tenant: WCLeaseTenant) async -> [RMAddress] {
        let addressEmbeds: [TenantEmbeds] = [.addresses, .addresses_AddressType]
        let addressFields: [TenantFields] = [.addresses]
        
        let addressEmbedsString = addressEmbeds.map { $0.rawValue }.joined(separator: ",")
        let addressFieldsString = addressFields.map { $0.rawValue }.joined(separator: ",")
        
        let addressURL: URL? = URLBuilder.shared.buildURL(endpoint: .tenants, embeds: addressEmbedsString, fields: addressFieldsString, id: String(tenant.tenantID ?? 0))
        
        let tenantAddresses = await RentManagerAPIClient.shared.request(url: addressURL!, responseType: RMTenant.self)
        
        return tenantAddresses?.addresses ?? [RMAddress]()
    }
    
    func fetchContacts(tenant: WCLeaseTenant) async -> [RMContact] {
        let contactEmbeds: [TenantEmbeds] = [.contacts]
        let contactFields: [TenantFields] = [.contacts]
        
        let contactEmbedsString = contactEmbeds.map { $0.rawValue }.joined(separator: ",")
        let contactFieldsString = contactFields.map { $0.rawValue }.joined(separator: ",")
        
        let contactURL: URL? = URLBuilder.shared.buildURL(endpoint: .tenants, embeds: contactEmbedsString, fields: contactFieldsString, id: "\(tenant.tenantID ?? 0)")
        let contacts = await RentManagerAPIClient.shared.request(url: contactURL!, responseType: RMTenant.self)
        
        print(contacts?.contacts?.count ?? 0)
        return contacts?.contacts ?? [RMContact]()
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
                
                let tenantToAdd: WCLeaseTenant = makeLeaseTenants(tenant: tenant, lease: lease)
                
                allUnitTenants.append(tenantToAdd)
            }
        }
        
        self.rentIncreaseTenants = rentIncreaseTenants
    }
    
    
    /* ARCHIVED:
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
     */
    
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
    
    // MARK: - Fire Protection Group membership (UDF 59)
    /// Updates the tenant's Fire Protection Group membership by posting a UserDefinedValue with UserDefinedFieldID 59.
    /// - Parameters:
    ///   - tenantID: The tenant's ID.
    ///   - isMember: Pass true to add to the group, false to remove.
    /// - Returns: Bool indicating success.
    func updateFireProtectionGroup(tenantID: Int, isMember: Bool) {
        
        let parameters = "{\"TenantID\": \(tenantID),\"PropertyID\": 3,\"UserDefinedValues\": [{\"UserDefinedValueID\": 8947,\"UserDefinedFieldID\": 64,\"Name\": \"HEI- Fire Protection Approved 2026\",\"Value\": \"Yes\"}]}"
        let postData = parameters.data(using: .utf8)

        var request = URLRequest(url: URL(string: "https://trieq.api.rentmanager.com/Tenants/?embeds=Balance%2CLeases%2CLeases.Unit%2CLeases.Unit.UnitType%2CUserDefinedValues&fields=Balance%2CFirstName%2CLastName%2CLeases%2CName%2CPropertyID%2CStatus%2CTenantDisplayID%2CTenantID%2CUserDefinedValues")!,timeoutInterval: Double.infinity)
        request.addValue("\(TokenManager.shared.token!)", forHTTPHeaderField: "X-RM12Api-ApiToken")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        request.httpBody = postData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
            return
          }
          print(String(data: data, encoding: .utf8)!)
        }

        task.resume()
    }
}

