//
//  RMCharge.swift
//  rmProApp
//
//  Created by William Castellano on 11/1/24.
//

import Foundation

// MARK: - Charge
struct RMCharge: Codable, Identifiable {
    
    var uuid = UUID()
    var chargeID: Int?
    var id: Int?
    var accountID: Int?
    var jobID: Int?
    var accountType: String?
    var reference: String?
    var comment: String?
    var amount: Int?
    var transactionDate: String?
    var createDate: String?
    var createUserID: Int?
    var updateDate: String?
    var updateUserID: Int?
    var transactionType: String?
    var propertyID: Int?
    var unitID: Int?
    var chargeTypeID: Int?
    var amountAllocated: Int?
    var isFullyAllocated: Bool?
    var isSecurityDepositPriorToGLStartDate: Bool?
    var accrualDebitID: Int?
    var accrualCreditID: Int?
    var tenantBillID: Int?
    var tenantCheckID: Int?

    enum CodingKeys: String, CodingKey {
        case chargeID = "ChargeID"
        case id = "ID"
        case accountID = "AccountID"
        case jobID = "JobID"
        case accountType = "AccountType"
        case reference = "Reference"
        case comment = "Comment"
        case amount = "Amount"
        case transactionDate = "TransactionDate"
        case createDate = "CreateDate"
        case createUserID = "CreateUserID"
        case updateDate = "UpdateDate"
        case updateUserID = "UpdateUserID"
        case transactionType = "TransactionType"
        case propertyID = "PropertyID"
        case unitID = "UnitID"
        case chargeTypeID = "ChargeTypeID"
        case amountAllocated = "AmountAllocated"
        case isFullyAllocated = "IsFullyAllocated"
        case isSecurityDepositPriorToGLStartDate = "IsSecurityDepositPriorToGLStartDate"
        case accrualDebitID = "AccrualDebitID"
        case accrualCreditID = "AccrualCreditID"
        case tenantBillID = "TenantBillID"
        case tenantCheckID = "TenantCheckID"
    }
}
