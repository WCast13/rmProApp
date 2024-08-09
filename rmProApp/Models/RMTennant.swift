//
//  RMTennant.swift
//  rmProApp
//
//  Created by William Castellano on 8/9/24.
//

import Foundation

struct RMTennant : Codable {
    let tenantID: Int
    let tenantDisplayID: Int
    let name: String
    let firstName: String
    let lastName: String
    let webMessage: String
    let isCompany: Bool
    let colorID: Int
    let checkPayeeName: String
    let statementMethod: String
    let comment: String
    let rentDueDay: Int
    let rentPeriod: String
    let doNotChargeLateFees: Bool
    let doNotPrintStatements: Bool
    let doNotAcceptChecks: Bool
    let doNotAcceptPayments: Bool
    let doNotAllowTWAPayments: Bool
    let doNotSendARAutomationNotifications: Bool
    let isProspect: Bool
    let accountGroupID: Int
    let totalCalls: Int
    let failedCalls: Int
    let isAccountGroupMaster: Bool
    let totalVisits: Int
    let totalEmails: Int
    let firstContact: String
    let lastContact: String
    let propertyID: Int
    let postingStartDate: String
    let defaultTaxTypeID: Int
    let overrideScreeningDecision: Bool
    let overrideReason: String
    let overrideCreateDate: String
    let overrideCreateUserID: Int
    let overrideUpdateDate: String
    let overrideUpdateUserID: Int
    let isShowCommentBanner: Bool
    let createDate: String
    let createUserID: Int
    let updateDate: String
    let updateUserID: Int
    let flexibleRentStatus: String
    let flexibleRentInternalStatus: String
    let screeningStatus: String
    let securityDepositHeld: Int
    let balance: Decimal
    let openBalance: Decimal
    let status: String
    let lastNameFirstName: String
}
