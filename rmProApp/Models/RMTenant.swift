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
    
    let tenantID: Int?
    let tenantDisplayID: Int?
    let name: String?
    let firstName: String?
    let lastName: String?
    let webMessage: String?
    let isCompany: Bool?
    let colorID: Int?
    let checkPayeeName: String?
    let statementMethod: String?
    let comment: String?
    let rentDueDay: Int?
    let rentPeriod: String?
    let doNotChargeLateFees: Bool?
    let doNotPrintStatements: Bool?
    let doNotAcceptChecks: Bool?
    let doNotAcceptPayments: Bool?
    let doNotAllowTWAPayments: Bool?
    let doNotSendARAutomationNotifications: Bool?
    let isProspect: Bool?
    let accountGroupID: Int?
    let totalCalls: Int?
    let failedCalls: Int?
    let isAccountGroupMaster: Bool?
    let totalVisits: Int?
    let totalEmails: Int?
    let firstContact: String?
    let lastContact: String?
    let propertyID: Int?
    let postingStartDate: String?
    let defaultTaxTypeID: Int?
    let overrideScreeningDecision: Bool?
    let overrideReason: String?
    let overrideCreateDate: String?
    let overrideCreateUserID: Int?
    let overrideUpdateDate: String?
    let overrideUpdateUserID: Int?
    let isShowCommentBanner: Bool?
    let createDate: String?
    let createUserID: Int?
    let updateDate: String?
    let updateUserID: Int?
    let flexibleRentStatus: String?
    let flexibleRentInternalStatus: String?
    let screeningStatus: String?
    let securityDepositHeld: Int?
    let balance: Decimal?
    let openBalance: Decimal?
    let status: String?
    let lastNameFirstName: String?
    let contacts: [RMContact]?
    
    enum CodingKeys: String, CodingKey {
        case tenantID = "TenantID"
        case tenantDisplayID = "TenantDisplayID"
        case name = "Name"
        case firstName = "FirstName"
        case lastName = "LastName"
        case webMessage = "WebMessage"
        case isCompany = "IsCompany"
        case colorID = "ColorID"
        case checkPayeeName = "CheckPayeeName"
        case statementMethod = "StatementMethod"
        case comment = "Comment"
        case rentDueDay = "RentDueDay"
        case rentPeriod = "RentPeriod"
        case doNotChargeLateFees = "DoNotChargeLateFees"
        case doNotPrintStatements = "DoNotPrintStatements"
        case doNotAcceptChecks = "DoNotAcceptChecks"
        case doNotAcceptPayments = "DoNotAcceptPayments"
        case doNotAllowTWAPayments = "DoNotAllowTWAPayments"
        case doNotSendARAutomationNotifications = "DoNotSendARAutomationNotifications"
        case isProspect = "IsProspect"
        case accountGroupID = "AccountGroupID"
        case totalCalls = "TotalCalls"
        case failedCalls = "FailedCalls"
        case isAccountGroupMaster = "IsAccountGroupMaster"
        case totalVisits = "TotalVisits"
        case totalEmails = "TotalEmails"
        case firstContact = "FirstContact"
        case lastContact = "LastContact"
        case propertyID = "PropertyID"
        case postingStartDate = "PostingStartDate"
        case defaultTaxTypeID = "DefaultTaxTypeID"
        case overrideScreeningDecision = "OverrideScreeningDecision"
        case overrideReason = "OverrideReason"
        case overrideCreateDate = "OverrideCreateDate"
        case overrideCreateUserID = "OverrideCreateUserID"
        case overrideUpdateDate = "OverrideUpdateDate"
        case overrideUpdateUserID = "OverrideUpdateUserID"
        case isShowCommentBanner = "IsShowCommentBanner"
        case createDate = "CreateDate"
        case createUserID = "CreateUserID"
        case updateDate = "UpdateDate"
        case updateUserID = "UpdateUserID"
        case flexibleRentStatus = "FlexibleRentStatus"
        case flexibleRentInternalStatus = "FlexibleRentInternalStatus"
        case screeningStatus = "ScreeningStatus"
        case securityDepositHeld = "SecurityDepositHeld"
        case balance = "Balance"
        case openBalance = "OpenBalance"
        case status = "Status"
        case lastNameFirstName = "LastNameFirstName"
        case contacts = "Contacts"
    }
}
