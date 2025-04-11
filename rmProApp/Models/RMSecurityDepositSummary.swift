//
//  RMSecurityDepositSummary.swift
//  rmProApp
//
//  Created by William Castellano on 4/11/25.
//

import Foundation

struct RMSecurityDepositSummary: Codable, Identifiable {
    let id = UUID()
    
    let accountID: Int?
    let chargeTypeID: Int?
    let unitID: Int?
    let propertyID: Int?
    let amount: Int?
    let securityDepositTypeID: Int?
    let chargeID: Int?

    enum CodingKeys: String, CodingKey {
        case accountID = "AccountID"
        case chargeTypeID = "ChargeTypeID"
        case unitID = "UnitID"
        case propertyID = "PropertyID"
        case amount = "Amount"
        case securityDepositTypeID = "SecurityDepositTypeID"
        case chargeID = "ChargeID"
    }
}
