//
//  TenantDataManager.swift
//  rmProApp
//
//  Created by William Castellano on 4/11/25.
//

import Foundation

@Observable
@MainActor
class TenantDataManager {
    var allTenants: [RMTenant] = []
    var allUnitTenants: [WCLeaseTenant] = []
    var rentIncreaseTenants: [WCRentIncreaseTenant] = []

    // Short-lived guard against duplicate session-level fetches. Delta sync
    // lives in TenantRepository; this just prevents a second tap on the
    // home screen from kicking off another top-level fetch mid-flight.
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

        // Hydrated tenants (base + leases + contacts + addresses + loans + UDFs)
        // come from TenantRepository. Units load in parallel via UnitRepository.
        async let hydrated = TenantRepository.shared.syncFull(forceRefresh: forceRefresh)
        async let _ = RMDataManager.shared.loadUnits()
        allTenants = await hydrated

        buildRentIncreaseTenants()
        lastFetchTime = Date()

        print("🚀 Total fetch time: \(Date().timeIntervalSince(startTime)) seconds")
    }

    // MARK: Generate Rent Increase Tenants for Mailing Labels

    func buildRentIncreaseTenants() {
        var rentIncrease: [WCRentIncreaseTenant] = []
        var leaseTenants: [WCLeaseTenant] = []

        for tenant in allTenants {
            guard let leases = tenant.leases else { continue }
            let activeLeases = leases.filter { $0.moveOutDate == nil }
            if activeLeases.isEmpty { continue }

            for lease in activeLeases {
                guard let unit = lease.unit, let address = unit.addresses?.first else { continue }
                if lease.unit?.unitType?.name == "Loan" { continue }

                var entry = WCRentIncreaseTenant()
                entry.unitName = unit.name ?? "No Unit Name"
                entry.city = address.city ?? "No City"
                entry.state = address.state ?? "No State"
                entry.postalCode = address.postalCode ?? "No Zip"

                // Haven stores addresses as "<street>\r\n<box>"; Pembroke is single-line.
                // Breaking this split silently puts the box number mid-address on labels.
                if tenant.propertyID == 3, let streetParts = address.street?.components(separatedBy: "\r\n") {
                    entry.street = streetParts.first ?? "No Street"
                    entry.boxNumber = streetParts.last ?? "No Box"
                } else {
                    entry.street = address.street ?? "No Street"
                    entry.boxNumber = ""
                }

                entry.contacts = tenant.contacts?.filter { $0.isShowOnBill == true } ?? []
                rentIncrease.append(entry)

                leaseTenants.append(makeLeaseTenants(tenant: tenant, lease: lease))
            }
        }

        self.rentIncreaseTenants = rentIncrease
        self.allUnitTenants = leaseTenants
    }

    func makeLeaseTenants(tenant: RMTenant, lease: RMLease) -> WCLeaseTenant {
        WCLeaseTenant(
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
            lease: lease,
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
            unit: lease.unit,
            updateDate: tenant.updateDate,
            updateUserID: tenant.updateUserID,
            webMessage: tenant.webMessage,
            primaryContact: tenant.primaryContact
        )
    }
}
