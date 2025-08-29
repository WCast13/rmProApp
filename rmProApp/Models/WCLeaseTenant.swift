//
//  RMLeaseTenant.swift
//  rmProApp
//
//  Created by William Castellano on 4/17/25.
//

import Foundation
import SwiftData

@Model
final class WCLeaseTenant: Identifiable, Codable, Equatable, Hashable {
    static func == (lhs: WCLeaseTenant, rhs: WCLeaseTenant) -> Bool {
        lhs.id == rhs.id
    }
    
    init(
        id: UUID = UUID(),
        accountGroupID: Int? = nil,
        addresses: [RMAddress]? = nil,
        allLeases: [RMLease]? = nil,
        balance: Decimal? = nil,
        charges: [RMCharge]? = nil,
        chargeTypes: [RMChargeType]? = nil,
        checkPayeeName: String? = nil,
        colorID: Int? = nil,
        comment: String? = nil,
        contacts: [RMContact]? = nil,
        createDate: String? = nil,
        createUserID: Int? = nil,
        defaultTaxTypeID: Int? = nil,
        doNotAcceptChecks: Bool? = nil,
        doNotAcceptPayments: Bool? = nil,
        doNotAllowTWAPayments: Bool? = nil,
        doNotChargeLateFees: Bool? = nil,
        doNotPrintStatements: Bool? = nil,
        doNotSendARAutomationNotifications: Bool? = nil,
        evictionID: Int? = nil,
        failedCalls: Int? = nil,
        firstContact: String? = nil,
        firstName: String? = nil,
        flexibleRentInternalStatus: String? = nil,
        flexibleRentStatus: String? = nil,
        isAccountGroupMaster: Bool? = nil,
        isCompany: Bool? = nil,
        isProspect: Bool? = nil,
        isShowCommentBanner: Bool? = nil,
        lastContact: String? = nil,
        lastName: String? = nil,
        lastNameFirstName: String? = nil,
        lease: RMLease? = nil,
        loans: [RMLoan]? = nil,
        name: String? = nil,
        openBalance: Decimal? = nil,
        overrideCreateDate: String? = nil,
        overrideCreateUserID: Int? = nil,
        overrideReason: String? = nil,
        overrideScreeningDecision: Bool? = nil,
        overrideUpdateDate: String? = nil,
        overrideUpdateUserID: Int? = nil,
        payments: [RMPayment]? = nil,
        paymentReversals: [RMPaymentReversal]? = nil,
        postingStartDate: String? = nil,
        propertyID: Int? = nil,
        recurringChargeSummaries: [RMRecurringChargeSummary]? = nil,
        rentDueDay: Int? = nil,
        rentPeriod: String? = nil,
        screeningStatus: String? = nil,
        securityDepositHeld: Int? = nil,
        securityDepositSummaries: [RMSecurityDepositSummary]? = nil,
        statementMethod: String? = nil,
        status: String? = nil,
        tenantDisplayID: Int? = nil,
        tenantID: Int? = nil,
        totalCalls: Int? = nil,
        totalEmails: Int? = nil,
        totalVisits: Int? = nil,
        udfs: [RMUserDefinedValue]? = nil,
        unit: RMUnit? = nil,
        updateDate: String? = nil,
        updateUserID: Int? = nil,
        webMessage: String? = nil,
        primaryContact: RMContact? = nil,
        transactions: [WCTransaction]? = nil
    ) {
        self.id = id
        self.accountGroupID = accountGroupID
        self.addresses = addresses
        self.allLeases = allLeases
        self.balance = balance
        self.charges = charges
        self.chargeTypes = chargeTypes
        self.checkPayeeName = checkPayeeName
        self.colorID = colorID
        self.comment = comment
        self.contacts = contacts
        self.createDate = createDate
        self.createUserID = createUserID
        self.defaultTaxTypeID = defaultTaxTypeID
        self.doNotAcceptChecks = doNotAcceptChecks
        self.doNotAcceptPayments = doNotAcceptPayments
        self.doNotAllowTWAPayments = doNotAllowTWAPayments
        self.doNotChargeLateFees = doNotChargeLateFees
        self.doNotPrintStatements = doNotPrintStatements
        self.doNotSendARAutomationNotifications = doNotSendARAutomationNotifications
        self.evictionID = evictionID
        self.failedCalls = failedCalls
        self.firstContact = firstContact
        self.firstName = firstName
        self.flexibleRentInternalStatus = flexibleRentInternalStatus
        self.flexibleRentStatus = flexibleRentStatus
        self.isAccountGroupMaster = isAccountGroupMaster
        self.isCompany = isCompany
        self.isProspect = isProspect
        self.isShowCommentBanner = isShowCommentBanner
        self.lastContact = lastContact
        self.lastName = lastName
        self.lastNameFirstName = lastNameFirstName
        self.lease = lease
        self.loans = loans
        self.name = name
        self.openBalance = openBalance
        self.overrideCreateDate = overrideCreateDate
        self.overrideCreateUserID = overrideCreateUserID
        self.overrideReason = overrideReason
        self.overrideScreeningDecision = overrideScreeningDecision
        self.overrideUpdateDate = overrideUpdateDate
        self.overrideUpdateUserID = overrideUpdateUserID
        self.payments = payments
        self.paymentReversals = paymentReversals
        self.postingStartDate = postingStartDate
        self.propertyID = propertyID
        self.recurringChargeSummaries = recurringChargeSummaries
        self.rentDueDay = rentDueDay
        self.rentPeriod = rentPeriod
        self.screeningStatus = screeningStatus
        self.securityDepositHeld = securityDepositHeld
        self.securityDepositSummaries = securityDepositSummaries
        self.statementMethod = statementMethod
        self.status = status
        self.tenantDisplayID = tenantDisplayID
        self.tenantID = tenantID
        self.totalCalls = totalCalls
        self.totalEmails = totalEmails
        self.totalVisits = totalVisits
        self.udfs = udfs
        self.unit = unit
        self.updateDate = updateDate
        self.updateUserID = updateUserID
        self.webMessage = webMessage
        self.primaryContact = primaryContact
        self.transactions = transactions
    }
    
    var id: UUID = UUID()
    var accountGroupID: Int?
    var addresses: [RMAddress]?
    var allLeases: [RMLease]?
    var balance: Decimal?
    var charges: [RMCharge]?
    var chargeTypes: [RMChargeType]?
    var checkPayeeName: String?
    var colorID: Int?
    var comment: String?
    var contacts: [RMContact]?
    var createDate: String?
    var createUserID: Int?
    var defaultTaxTypeID: Int?
    var doNotAcceptChecks: Bool?
    var doNotAcceptPayments: Bool?
    var doNotAllowTWAPayments: Bool?
    var doNotChargeLateFees: Bool?
    var doNotPrintStatements: Bool?
    var doNotSendARAutomationNotifications: Bool?
    var evictionID: Int?
    var failedCalls: Int?
    var firstContact: String?
    var firstName: String?
    var flexibleRentInternalStatus: String?
    var flexibleRentStatus: String?
    var isAccountGroupMaster: Bool?
    var isCompany: Bool?
    var isProspect: Bool?
    var isShowCommentBanner: Bool?
    var lastContact: String?
    var lastName: String?
    var lastNameFirstName: String?
    var lease: RMLease?
    var loans: [RMLoan]?
    var name: String?
    var openBalance: Decimal?
    var overrideCreateDate: String?
    var overrideCreateUserID: Int?
    var overrideReason: String?
    var overrideScreeningDecision: Bool?
    var overrideUpdateDate: String?
    var overrideUpdateUserID: Int?
    var payments: [RMPayment]?
    var paymentReversals: [RMPaymentReversal]?
    var postingStartDate: String?
    var propertyID: Int?
    var recurringChargeSummaries: [RMRecurringChargeSummary]?
    var rentDueDay: Int?
    var rentPeriod: String?
    var screeningStatus: String?
    var securityDepositHeld: Int?
    var securityDepositSummaries: [RMSecurityDepositSummary]?
    var statementMethod: String?
    var status: String?
    var tenantDisplayID: Int?
    var tenantID: Int?
    var totalCalls: Int?
    var totalEmails: Int?
    var totalVisits: Int?
    var udfs: [RMUserDefinedValue]?
    var unit: RMUnit?
    var updateDate: String?
    var updateUserID: Int?
    var webMessage: String?
    
    var primaryContact: RMContact?
    // NOTE: Not Codable. Skipped in encode/decode.
    var transactions: [WCTransaction]?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.accountGroupID = try? container.decode(Int.self, forKey: .accountGroupID)
        self.balance = try? container.decode(Decimal.self, forKey: .balance)
        self.addresses = try? container.decode([RMAddress].self, forKey: .addresses)
        self.allLeases = try? container.decode([RMLease].self, forKey: .allLeases)
        self.charges = try? container.decode([RMCharge].self, forKey: .charges)
        self.chargeTypes = try? container.decode([RMChargeType].self, forKey: .chargeTypes)
        self.checkPayeeName = try? container.decode(String.self, forKey: .checkPayeeName)
        self.colorID = try? container.decode(Int.self, forKey: .colorID)
        self.comment = try? container.decode(String.self, forKey: .comment)
        self.contacts = try? container.decode([RMContact].self, forKey: .contacts)
        self.createDate = try? container.decode(String.self, forKey: .createDate)
        self.createUserID = try? container.decode(Int.self, forKey: .createUserID)
        self.defaultTaxTypeID = try? container.decode(Int.self, forKey: .defaultTaxTypeID)
        self.doNotAcceptChecks = try? container.decode(Bool.self, forKey: .doNotAcceptChecks)
        self.doNotAcceptPayments = try? container.decode(Bool.self, forKey: .doNotAcceptPayments)
        self.doNotAllowTWAPayments = try? container.decode(Bool.self, forKey: .doNotAllowTWAPayments)
        self.doNotChargeLateFees = try? container.decode(Bool.self, forKey: .doNotChargeLateFees)
        self.doNotPrintStatements = try? container.decode(Bool.self, forKey: .doNotPrintStatements)
        self.doNotSendARAutomationNotifications = try? container.decode(Bool.self, forKey: .doNotSendARAutomationNotifications)
        self.evictionID = try? container.decode(Int.self, forKey: .evictionID)
        self.failedCalls = try? container.decode(Int.self, forKey: .failedCalls)
        self.firstContact = try? container.decode(String.self, forKey: .firstContact)
        self.firstName = try? container.decode(String.self, forKey: .firstName)
        self.flexibleRentInternalStatus = try? container.decode(String.self, forKey: .flexibleRentInternalStatus)
        self.flexibleRentStatus = try? container.decode(String.self, forKey: .flexibleRentStatus)
        self.isAccountGroupMaster = try? container.decode(Bool.self, forKey: .isAccountGroupMaster)
        self.isCompany = try? container.decode(Bool.self, forKey: .isCompany)
        self.isProspect = try? container.decode(Bool.self, forKey: .isProspect)
        self.isShowCommentBanner = try? container.decode(Bool.self, forKey: .isShowCommentBanner)
        self.lastContact = try? container.decode(String.self, forKey: .lastContact)
        self.lastName = try? container.decode(String.self, forKey: .lastName)
        self.lastNameFirstName = try? container.decode(String.self, forKey: .lastNameFirstName)
        self.lease = try? container.decode(RMLease.self, forKey: .lease)
        self.loans = try? container.decode([RMLoan].self, forKey: .loans)
        self.name = try? container.decode(String.self, forKey: .name)
        self.openBalance = try? container.decode(Decimal.self, forKey: .openBalance)
        self.overrideCreateDate = try? container.decode(String.self, forKey: .overrideCreateDate)
        self.overrideCreateUserID = try? container.decode(Int.self, forKey: .overrideCreateUserID)
        self.overrideReason = try? container.decode(String.self, forKey: .overrideReason)
        self.overrideScreeningDecision = try? container.decode(Bool.self, forKey: .overrideScreeningDecision)
        self.overrideUpdateDate = try? container.decode(String.self, forKey: .overrideUpdateDate)
        self.overrideUpdateUserID = try? container.decode(Int.self, forKey: .overrideUpdateUserID)
        self.payments = try? container.decode([RMPayment].self, forKey: .payments)
        self.paymentReversals = try? container.decode([RMPaymentReversal].self, forKey: .paymentReversals)
        self.postingStartDate = try? container.decode(String.self, forKey: .postingStartDate)
        self.propertyID = try? container.decode(Int.self, forKey: .propertyID)
        self.recurringChargeSummaries = try? container.decode([RMRecurringChargeSummary].self, forKey: .recurringChargeSummaries)
        self.rentDueDay = try? container.decode(Int.self, forKey: .rentDueDay)
        self.rentPeriod = try? container.decode(String.self, forKey: .rentPeriod)
        self.screeningStatus = try? container.decode(String.self, forKey: .screeningStatus)
        self.securityDepositHeld = try? container.decode(Int.self, forKey: .securityDepositHeld)
        self.securityDepositSummaries = try? container.decode([RMSecurityDepositSummary].self, forKey: .securityDepositSummaries)
        self.statementMethod = try? container.decode(String.self, forKey: .statementMethod)
        self.status = try? container.decode(String.self, forKey: .status)
        self.tenantDisplayID = try? container.decode(Int.self, forKey: .tenantDisplayID)
        self.tenantID = try? container.decode(Int.self, forKey: .tenantID)
        self.totalCalls = try? container.decode(Int.self, forKey: .totalCalls)
        self.totalEmails = try? container.decode(Int.self, forKey: .totalEmails)
        self.totalVisits = try? container.decode(Int.self, forKey: .totalVisits)
        self.udfs = try? container.decode([RMUserDefinedValue].self, forKey: .udfs)
        self.unit = try? container.decode(RMUnit.self, forKey: .unit)
        self.updateDate = try? container.decode(String.self, forKey: .updateDate)
        self.updateUserID = try? container.decode(Int.self, forKey: .updateUserID)
        self.webMessage = try? container.decode(String.self, forKey: .webMessage)
        self.primaryContact = try? container.decode(RMContact.self, forKey: .primaryContact)
        // Not Codable, skip
        self.transactions = nil
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(accountGroupID, forKey: .accountGroupID)
        try container.encodeIfPresent(balance, forKey: .balance)
        try container.encodeIfPresent(addresses, forKey: .addresses)
        try container.encodeIfPresent(allLeases, forKey: .allLeases)
        try container.encodeIfPresent(charges, forKey: .charges)
        try container.encodeIfPresent(chargeTypes, forKey: .chargeTypes)
        try container.encodeIfPresent(checkPayeeName, forKey: .checkPayeeName)
        try container.encodeIfPresent(colorID, forKey: .colorID)
        try container.encodeIfPresent(comment, forKey: .comment)
        try container.encodeIfPresent(contacts, forKey: .contacts)
        try container.encodeIfPresent(createDate, forKey: .createDate)
        try container.encodeIfPresent(createUserID, forKey: .createUserID)
        try container.encodeIfPresent(defaultTaxTypeID, forKey: .defaultTaxTypeID)
        try container.encodeIfPresent(doNotAcceptChecks, forKey: .doNotAcceptChecks)
        try container.encodeIfPresent(doNotAcceptPayments, forKey: .doNotAcceptPayments)
        try container.encodeIfPresent(doNotAllowTWAPayments, forKey: .doNotAllowTWAPayments)
        try container.encodeIfPresent(doNotChargeLateFees, forKey: .doNotChargeLateFees)
        try container.encodeIfPresent(doNotPrintStatements, forKey: .doNotPrintStatements)
        try container.encodeIfPresent(doNotSendARAutomationNotifications, forKey: .doNotSendARAutomationNotifications)
        try container.encodeIfPresent(evictionID, forKey: .evictionID)
        try container.encodeIfPresent(failedCalls, forKey: .failedCalls)
        try container.encodeIfPresent(firstContact, forKey: .firstContact)
        try container.encodeIfPresent(firstName, forKey: .firstName)
        try container.encodeIfPresent(flexibleRentInternalStatus, forKey: .flexibleRentInternalStatus)
        try container.encodeIfPresent(flexibleRentStatus, forKey: .flexibleRentStatus)
        try container.encodeIfPresent(isAccountGroupMaster, forKey: .isAccountGroupMaster)
        try container.encodeIfPresent(isCompany, forKey: .isCompany)
        try container.encodeIfPresent(isProspect, forKey: .isProspect)
        try container.encodeIfPresent(isShowCommentBanner, forKey: .isShowCommentBanner)
        try container.encodeIfPresent(lastContact, forKey: .lastContact)
        try container.encodeIfPresent(lastName, forKey: .lastName)
        try container.encodeIfPresent(lastNameFirstName, forKey: .lastNameFirstName)
        try container.encodeIfPresent(lease, forKey: .lease)
        try container.encodeIfPresent(loans, forKey: .loans)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(openBalance, forKey: .openBalance)
        try container.encodeIfPresent(overrideCreateDate, forKey: .overrideCreateDate)
        try container.encodeIfPresent(overrideCreateUserID, forKey: .overrideCreateUserID)
        try container.encodeIfPresent(overrideReason, forKey: .overrideReason)
        try container.encodeIfPresent(overrideScreeningDecision, forKey: .overrideScreeningDecision)
        try container.encodeIfPresent(overrideUpdateDate, forKey: .overrideUpdateDate)
        try container.encodeIfPresent(overrideUpdateUserID, forKey: .overrideUpdateUserID)
        try container.encodeIfPresent(payments, forKey: .payments)
        try container.encodeIfPresent(paymentReversals, forKey: .paymentReversals)
        try container.encodeIfPresent(postingStartDate, forKey: .postingStartDate)
        try container.encodeIfPresent(propertyID, forKey: .propertyID)
        try container.encodeIfPresent(recurringChargeSummaries, forKey: .recurringChargeSummaries)
        try container.encodeIfPresent(rentDueDay, forKey: .rentDueDay)
        try container.encodeIfPresent(rentPeriod, forKey: .rentPeriod)
        try container.encodeIfPresent(screeningStatus, forKey: .screeningStatus)
        try container.encodeIfPresent(securityDepositHeld, forKey: .securityDepositHeld)
        try container.encodeIfPresent(securityDepositSummaries, forKey: .securityDepositSummaries)
        try container.encodeIfPresent(statementMethod, forKey: .statementMethod)
        try container.encodeIfPresent(status, forKey: .status)
        try container.encodeIfPresent(tenantDisplayID, forKey: .tenantDisplayID)
        try container.encodeIfPresent(tenantID, forKey: .tenantID)
        try container.encodeIfPresent(totalCalls, forKey: .totalCalls)
        try container.encodeIfPresent(totalEmails, forKey: .totalEmails)
        try container.encodeIfPresent(totalVisits, forKey: .totalVisits)
        try container.encodeIfPresent(udfs, forKey: .udfs)
        try container.encodeIfPresent(unit, forKey: .unit)
        try container.encodeIfPresent(updateDate, forKey: .updateDate)
        try container.encodeIfPresent(updateUserID, forKey: .updateUserID)
        try container.encodeIfPresent(webMessage, forKey: .webMessage)
        try container.encodeIfPresent(primaryContact, forKey: .primaryContact)
        // Not Codable, skip transactions
    }
    
    enum CodingKeys: String, CodingKey {
        case accountGroupID = "AccountGroupID"
        case balance = "Balance"
        case addresses = "Addresses"
        case allLeases = "Leases"
        case charges = "Charges"
        case checkPayeeName = "CheckPayeeName"
        case colorID = "ColorID"
        case comment = "Comment"
        case contacts = "Contacts"
        case createDate = "CreateDate"
        case createUserID = "CreateUserID"
        case defaultTaxTypeID = "DefaultTaxTypeID"
        case doNotAcceptChecks = "DoNotAcceptChecks"
        case doNotAcceptPayments = "DoNotAcceptPayments"
        case doNotAllowTWAPayments = "DoNotAllowTWAPayments"
        case doNotChargeLateFees = "DoNotChargeLateFees"
        case doNotPrintStatements = "DoNotPrintStatements"
        case doNotSendARAutomationNotifications = "DoNotSendARAutomationNotifications"
        case failedCalls = "FailedCalls"
        case firstContact = "FirstContact"
        case firstName = "FirstName"
        case flexibleRentInternalStatus = "FlexibleRentInternalStatus"
        case flexibleRentStatus = "FlexibleRentStatus"
        case isAccountGroupMaster = "IsAccountGroupMaster"
        case isCompany = "IsCompany"
        case isProspect = "IsProspect"
        case isShowCommentBanner = "IsShowCommentBanner"
        case lease = "Lease"
        case lastContact = "LastContact"
        case lastName = "LastName"
        case lastNameFirstName = "LastNameFirstName"
        case loans = "Loans"
        case name = "Name"
        case openBalance = "OpenBalance"
        case overrideCreateDate = "OverrideCreateDate"
        case overrideCreateUserID = "OverrideCreateUserID"
        case overrideReason = "OverrideReason"
        case overrideScreeningDecision = "OverrideScreeningDecision"
        case overrideUpdateDate = "OverrideUpdateDate"
        case overrideUpdateUserID = "OverrideUpdateUserID"
        case payments = "Payments"
        case paymentReversals = "PaymentReversals"
        case postingStartDate = "PostingStartDate"
        case propertyID = "PropertyID"
        case rentDueDay = "RentDueDay"
        case rentPeriod = "RentPeriod"
        case screeningStatus = "ScreeningStatus"
        case securityDepositHeld = "SecurityDepositHeld"
        case statementMethod = "StatementMethod"
        case status = "Status"
        case tenantDisplayID = "TenantDisplayID"
        case tenantID = "TenantID"
        case totalCalls = "TotalCalls"
        case totalEmails = "TotalEmails"
        case totalVisits = "TotalVisits"
        
        case udfs = "UserDefinedValues"
        case unit = "Unit"
        case updateDate = "UpdateDate"
        case updateUserID = "UpdateUserID"
        case webMessage = "WebMessage"
        
        case recurringChargeSummaries = "RecurringChargeSummaries"
        case securityDepositSummaries = "SecurityDepositSummaries"
        case chargeTypes = "ChargeTypes"
        case evictionID = "EvictionID"
        case primaryContact = "PrimaryContact"
    }
}

/*
 FOR Resident Details:- Need to Add
 Open Recievables
 Loans
 Vehicles
 Evictions
 History
 
 NEEDS TO EDIT-
 Lease
 
 */
