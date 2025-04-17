//
//  RMPayment.swift
//  rmProApp
//
//  Created by William Castellano on 4/10/25.
//

import Foundation

struct RMPayment : Codable, Identifiable {
    let uuid = UUID()
    
    let paymentID: Int?
    let id: Int?
    let accountID: Int?
    let createDate: String?
    let createUserID: Int?
    let updateDate: String?
    let updateUserID: Int?
    let transactionType: String?
    let amountAllocated: Decimal?
    let isFullyAllocated: Bool?
    let isSecurityDepositPriorToGLStartDate: Bool?
    let receiptID: Int?
    let reversalDate: String?
    let reversalType: String?
    let reversalReconcileID: Int?
    let reversalElectronicReconcileID: Int?
    let isRestrictAutomaticAllocationsToUnit: Bool?
    let isRecordingCashReallocations: Bool?
    let isRecordingCashPreallocationsAsLiability: Bool?
    let isRecordingAccrualPrepayments: Bool?
    let prepayPropertyID: Int?
    let prepayUnitID: Int?
    let accountType: String?
    let reference: String?
    let comment: String?
    let amount: Decimal?
    let transactionDate: String?

    enum CodingKeys: String, CodingKey {
        case paymentID = "PaymentID"
        case id = "ID"
        case accountID = "AccountID"
        case createDate = "CreateDate"
        case createUserID = "CreateUserID"
        case updateDate = "UpdateDate"
        case updateUserID = "UpdateUserID"
        case transactionType = "TransactionType"
        case amountAllocated = "AmountAllocated"
        case isFullyAllocated = "IsFullyAllocated"
        case isSecurityDepositPriorToGLStartDate = "IsSecurityDepositPriorToGLStartDate"
        case receiptID = "ReceiptID"
        case reversalDate = "ReversalDate"
        case reversalType = "ReversalType"
        case reversalReconcileID = "ReversalReconcileID"
        case reversalElectronicReconcileID = "ReversalElectronicReconcileID"
        case isRestrictAutomaticAllocationsToUnit = "IsRestrictAutomaticAllocationsToUnit"
        case isRecordingCashReallocations = "IsRecordingCashReallocations"
        case isRecordingCashPreallocationsAsLiability = "IsRecordingCashPreallocationsAsLiability"
        case isRecordingAccrualPrepayments = "IsRecordingAccrualPrepayments"
        case prepayPropertyID = "PrepayPropertyID"
        case prepayUnitID = "PrepayUnitID"
        case accountType = "AccountType"
        case reference = "Reference"
        case comment = "Comment"
        case amount = "Amount"
        case transactionDate = "TransactionDate"
    }
}
