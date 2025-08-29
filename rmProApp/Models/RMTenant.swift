//
//  RMTenant.swift
//  rmProApp
//
//  Created by William Castellano on 8/9/24.
//

// TODO: Fix The Coding Keys
import Foundation
import SwiftData

@Model
final class RMTenant: Codable, Identifiable, Hashable {
    
    var id = UUID()
    var accountGroupID: Int?
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
    var leases: [RMLease]?
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
    var addresses: [RMAddress]?
    var primaryContact: RMContact?
        
//        let openReceivables: [JSONAny]? //RMCharge?
//        let vehicles: [RMVehicle]?
//        let evictions: [RMEvictions]?
    
    enum CodingKeys: String, CodingKey {
        case accountGroupID = "AccountGroupID"
        case balance = "Balance"
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
        case leases = "Leases"
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
        case addresses = "Addresses"
        case primaryContact = "PrimaryContact"
        
        
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.accountGroupID = try container.decodeIfPresent(Int.self, forKey: .accountGroupID)
        self.balance = try container.decodeIfPresent(Decimal.self, forKey: .balance)
        self.charges = try container.decodeIfPresent([RMCharge].self, forKey: .charges)
        self.chargeTypes = try container.decodeIfPresent([RMChargeType].self, forKey: .chargeTypes)
        self.checkPayeeName = try container.decodeIfPresent(String.self, forKey: .checkPayeeName)
        self.colorID = try container.decodeIfPresent(Int.self, forKey: .colorID)
        self.comment = try container.decodeIfPresent(String.self, forKey: .comment)
        self.contacts = try container.decodeIfPresent([RMContact].self, forKey: .contacts)
        self.createDate = try container.decodeIfPresent(String.self, forKey: .createDate)
        self.createUserID = try container.decodeIfPresent(Int.self, forKey: .createUserID)
        self.defaultTaxTypeID = try container.decodeIfPresent(Int.self, forKey: .defaultTaxTypeID)
        self.doNotAcceptChecks = try container.decodeIfPresent(Bool.self, forKey: .doNotAcceptChecks)
        self.doNotAcceptPayments = try container.decodeIfPresent(Bool.self, forKey: .doNotAcceptPayments)
        self.doNotAllowTWAPayments = try container.decodeIfPresent(Bool.self, forKey: .doNotAllowTWAPayments)
        self.doNotChargeLateFees = try container.decodeIfPresent(Bool.self, forKey: .doNotChargeLateFees)
        self.doNotPrintStatements = try container.decodeIfPresent(Bool.self, forKey: .doNotPrintStatements)
        self.doNotSendARAutomationNotifications = try container.decodeIfPresent(Bool.self, forKey: .doNotSendARAutomationNotifications)
        self.evictionID = try container.decodeIfPresent(Int.self, forKey: .evictionID)
        self.failedCalls = try container.decodeIfPresent(Int.self, forKey: .failedCalls)
        self.firstContact = try container.decodeIfPresent(String.self, forKey: .firstContact)
        self.firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        self.flexibleRentInternalStatus = try container.decodeIfPresent(String.self, forKey: .flexibleRentInternalStatus)
        self.flexibleRentStatus = try container.decodeIfPresent(String.self, forKey: .flexibleRentStatus)
        self.isAccountGroupMaster = try container.decodeIfPresent(Bool.self, forKey: .isAccountGroupMaster)
        self.isCompany = try container.decodeIfPresent(Bool.self, forKey: .isCompany)
        self.isProspect = try container.decodeIfPresent(Bool.self, forKey: .isProspect)
        self.isShowCommentBanner = try container.decodeIfPresent(Bool.self, forKey: .isShowCommentBanner)
        self.lastContact = try container.decodeIfPresent(String.self, forKey: .lastContact)
        self.lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        self.lastNameFirstName = try container.decodeIfPresent(String.self, forKey: .lastNameFirstName)
        self.leases = try container.decodeIfPresent([RMLease].self, forKey: .leases)
        self.loans = try container.decodeIfPresent([RMLoan].self, forKey: .loans)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.openBalance = try container.decodeIfPresent(Decimal.self, forKey: .openBalance)
        self.overrideCreateDate = try container.decodeIfPresent(String.self, forKey: .overrideCreateDate)
        self.overrideCreateUserID = try container.decodeIfPresent(Int.self, forKey: .overrideCreateUserID)
        self.overrideReason = try container.decodeIfPresent(String.self, forKey: .overrideReason)
        self.overrideScreeningDecision = try container.decodeIfPresent(Bool.self, forKey: .overrideScreeningDecision)
        self.overrideUpdateDate = try container.decodeIfPresent(String.self, forKey: .overrideUpdateDate)
        self.overrideUpdateUserID = try container.decodeIfPresent(Int.self, forKey: .overrideUpdateUserID)
        self.payments = try container.decodeIfPresent([RMPayment].self, forKey: .payments)
        self.paymentReversals = try container.decodeIfPresent([RMPaymentReversal].self, forKey: .paymentReversals)
        self.postingStartDate = try container.decodeIfPresent(String.self, forKey: .postingStartDate)
        self.propertyID = try container.decodeIfPresent(Int.self, forKey: .propertyID)
        self.recurringChargeSummaries = try container.decodeIfPresent([RMRecurringChargeSummary].self, forKey: .recurringChargeSummaries)
        self.rentDueDay = try container.decodeIfPresent(Int.self, forKey: .rentDueDay)
        self.rentPeriod = try container.decodeIfPresent(String.self, forKey: .rentPeriod)
        self.screeningStatus = try container.decodeIfPresent(String.self, forKey: .screeningStatus)
        self.securityDepositHeld = try container.decodeIfPresent(Int.self, forKey: .securityDepositHeld)
        self.securityDepositSummaries = try container.decodeIfPresent([RMSecurityDepositSummary].self, forKey: .securityDepositSummaries)
        self.statementMethod = try container.decodeIfPresent(String.self, forKey: .statementMethod)
        self.status = try container.decodeIfPresent(String.self, forKey: .status)
        self.tenantDisplayID = try container.decodeIfPresent(Int.self, forKey: .tenantDisplayID)
        self.tenantID = try container.decodeIfPresent(Int.self, forKey: .tenantID)
        self.totalCalls = try container.decodeIfPresent(Int.self, forKey: .totalCalls)
        self.totalEmails = try container.decodeIfPresent(Int.self, forKey: .totalEmails)
        self.totalVisits = try container.decodeIfPresent(Int.self, forKey: .totalVisits)
        self.udfs = try container.decodeIfPresent([RMUserDefinedValue].self, forKey: .udfs)
        self.unit = try container.decodeIfPresent(RMUnit.self, forKey: .unit)
        self.updateDate = try container.decodeIfPresent(String.self, forKey: .updateDate)
        self.updateUserID = try container.decodeIfPresent(Int.self, forKey: .updateUserID)
        self.webMessage = try container.decodeIfPresent(String.self, forKey: .webMessage)
        self.addresses = try container.decodeIfPresent([RMAddress].self, forKey: .addresses)
        self.primaryContact = try container.decodeIfPresent(RMContact.self, forKey: .primaryContact)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(accountGroupID, forKey: .accountGroupID)
        try container.encodeIfPresent(balance, forKey: .balance)
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
        try container.encodeIfPresent(leases, forKey: .leases)
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
        try container.encodeIfPresent(addresses, forKey: .addresses)
        try container.encodeIfPresent(primaryContact, forKey: .primaryContact)
        try container.encodeIfPresent(chargeTypes, forKey: .chargeTypes)
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
