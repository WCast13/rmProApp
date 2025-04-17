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
    let chargeID: Int?
    let id: Int?
    let accountID: Int?
    let jobID: Int?
    let accountType: String?
    let reference: String?
    let comment: String?
    let amount: Double?
    let transactionDate: String?
    let createDate: String?
    let createUserID: Int?
    let updateDate: String?
    let updateUserID: Int?
    let transactionType: String?
    let propertyID: Int?
    let unitID: Int?
    let chargeTypeID: Int?
    let amountAllocated: Double?
    let isFullyAllocated: Bool?
    let isSecurityDepositPriorToGLStartDate: Bool?
    let accrualDebitID: Int?
    let accrualCreditID: Int?
    let tenantBillID: Int?
    let tenantCheckID: Int?

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
