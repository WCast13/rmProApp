//
//  RMTenant.swift
//  rmProApp
//
//  Created by William Castellano on 8/9/24.
//

// TODO: Fix The Coding Keys
import Foundation

struct RMTenant: Codable, Identifiable {
    
    let uuid = UUID()
    var id: UUID { uuid }
    
    let accountGroupID: Int?
    let balance: Decimal?
    let charges: [RMCharge]?
    let chargeTypes: [RMChargeType]?
    let checkPayeeName: String?
    let colorID: Int?
    let comment: String?
    let contacts: [RMContact]?
    let createDate: String?
    let createUserID: Int?
    let defaultTaxTypeID: Int?
    let doNotAcceptChecks: Bool?
    let doNotAcceptPayments: Bool?
    let doNotAllowTWAPayments: Bool?
    let doNotChargeLateFees: Bool?
    let doNotPrintStatements: Bool?
    let doNotSendARAutomationNotifications: Bool?
    let failedCalls: Int?
    let firstContact: String?
    let firstName: String?
    let flexibleRentInternalStatus: String?
    let flexibleRentStatus: String?
    let isAccountGroupMaster: Bool?
    let isCompany: Bool?
    let isProspect: Bool?
    let isShowCommentBanner: Bool?
    let lastContact: String?
    let lastName: String?
    let lastNameFirstName: String?
    let name: String?
    let openBalance: Decimal?
    let overrideCreateDate: String?
    let overrideCreateUserID: Int?
    let overrideReason: String?
    let overrideScreeningDecision: Bool?
    let overrideUpdateDate: String?
    let overrideUpdateUserID: Int?
    let payments: [RMPayment]?
    let paymentReversals: [RMPaymentReversal]?
    let postingStartDate: String?
    let propertyID: Int?
    let recurringChargeSummaries: [RMRecurringChargeSummary]?
    let rentDueDay: Int?
    let rentPeriod: String?
    let screeningStatus: String?
    let securityDepositHeld: Int?
    let securityDepositSummaries: [RMSecurityDepositSummary]?
    let statementMethod: String?
    let status: String?
    let tenantDisplayID: Int?
    let tenantID: Int?
    let totalCalls: Int?
    let totalEmails: Int?
    let totalVisits: Int?
    let udfs: [RMUserDefinedValue]?
    let updateDate: String?
    let updateUserID: Int?
    let webMessage: String?
    
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
        case lastContact = "LastContact"
        case lastName = "LastName"
        case lastNameFirstName = "LastNameFirstName"
        case name = "Name"
        case openBalance = "OpenBalance"
        case overrideCreateDate = "OverrideCreateDate"
        case overrideCreateUserID = "OverrideCreateUserID"
        case overrideReason = "OverrideReason"
        case overrideScreeningDecision = "OverrideScreeningDecision"
        case overrideUpdateDate = "OverrideUpdateDate"
        case overrideUpdateUserID = "OverrideUpdateUserID"
        case payments = "Payments"
        
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
        case updateDate = "UpdateDate"
        case updateUserID = "UpdateUserID"
        case webMessage = "WebMessage"
        
        case paymentReversals = "PaymentReversals"
        case recurringChargeSummaries = "RecurringChargeSummaries"
        case securityDepositSummaries = "SecurityDepositSummaries"
        case chargeTypes = "ChargeTypes"
        
    }
}

/*
 
 let recurringCharges: [JSONAny]?
 let openReceivables: [JSONAny]?
 let recurringChargeSummaries: [RecurringChargeSummary]?
 let securityDepositSummaries: [SecurityDepositSummary]?
 let loans: [JSONAny]?
 let vehicles: [JSONAny]?
 let evictions: [JSONAny]?
 let historyEvictionNotes: [JSONAny]?
 let historyEviction: [JSONAny]?
 
 
 */

