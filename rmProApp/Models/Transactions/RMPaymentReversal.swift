//
//  RMPaymentReversal.swift
//  rmProApp
//
//  Created by William Castellano on 4/10/25.
//

import Foundation

// MARK: - PaymentReversal
struct RMPaymentReversal: Codable, Identifiable, Hashable {
    let id = UUID()
    let accountID: Int?
    let paymentID: Int?
    let reversalDate: String?
    let reversalType: String?
    let reversalReconcileID: Int?
    let reversalElectronicReconcileID: Int?
    let createDate: String?
    let createUserID: Int?
    let reversalReason: String?
    
    enum CodingKeys: String, CodingKey {
        case accountID = "AccountID"
        case paymentID = "PaymentID"
        case reversalDate = "ReversalDate"
        case reversalType = "ReversalType"
        case reversalReconcileID = "ReversalReconcileID"
        case reversalElectronicReconcileID = "ReversalElectronicReconcileID"
        case createDate = "CreateDate"
        case createUserID = "CreateUserID"
        case reversalReason = "ReversalReason"
    }
}
