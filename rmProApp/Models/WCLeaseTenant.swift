//
//  RMLeaseTenant.swift
//  rmProApp
//
//  Created by William Castellano on 4/17/25.
//

import Foundation

// TODO: Fix The Coding Keys
import Foundation

struct WCLeaseTenant: Identifiable, Codable, Equatable, Hashable {
    static func == (lhs: WCLeaseTenant, rhs: WCLeaseTenant) -> Bool {
        lhs.id == rhs.id
    }
    
    let id = UUID()
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
    var transactions: [WCTransaction]?
        
//        let openReceivables: [JSONAny]? //RMCharge?
//        let loans: [RMLoan]?
//        let vehicles: [RMVehicle]?
//        let evictions: [RMEvictions]?
    
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

