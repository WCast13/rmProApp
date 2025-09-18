//
//  RMChargeType.swift
//  rmProApp
//
//  Created by William Castellano on 4/11/25.
//

import Foundation

// MARK: - ChargeType
struct RMChargeType: Codable, Identifiable, Hashable {
    let id = UUID()
    let chargeTypeID: Int?
    let name: String?
    let description: String?
    let glAccountID: Int?
    let defaultAmount: Int?
    let isProrated: Bool?
    let isCam: Bool?
    let isActive: Bool?
    let createDate: String?
    let createUserID: Int?
    let updateDate: String?
    let updateUserID: Int?
    let concurrencyID: Int?

    enum CodingKeys: String, CodingKey {
        case chargeTypeID = "ChargeTypeID"
        case name = "Name"
        case description = "Description"
        case glAccountID = "GLAccountID"
        case defaultAmount = "DefaultAmount"
        case isProrated = "IsProrated"
        case isCam = "IsCam"
        case isActive = "IsActive"
        case createDate = "CreateDate"
        case createUserID = "CreateUserID"
        case updateDate = "UpdateDate"
        case updateUserID = "UpdateUserID"
        case concurrencyID = "ConcurrencyID"
    }
}

