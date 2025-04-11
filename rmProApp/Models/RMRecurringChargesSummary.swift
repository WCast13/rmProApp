//
//  RMRecurringChargesSummary.swift
//  rmProApp
//
//  Created by William Castellano on 4/10/25.
//

import Foundation

// MARK: - RecurringChargeSummary
struct RMRecurringChargeSummary: Codable {
    let isException: Bool?
    let groupName: String?
    let entityTypeEnumSortOrder: Int?
    let tenantID: Int?
    let unitTypeID: Int?
    let propertyID: Int?
    let isInherited: Bool?
    let recurringChargeID: Int?
    let entityType: String?
    let entityKeyID: Int?
    let unitID: Int?
    let frequency: Int?
    let chargeTypeID: Int?
    let amount: Double?
    let originalAmount: Double?
    let amountPerSquareFoot: Int?
    let comment: String?
    let fromDate: String?
    let toDate: String?
    let isCalculated: Bool?
    let calculation: String?
    let camRecurringChargeID: Int?
    let sortOrder: Int?
    let createDate: String?
    let createUserID: Int?
    let updateDate: String?
    let updateUserID: Int?
    let chargeType: RMChargeType?

    enum CodingKeys: String, CodingKey {
        case isException = "IsException"
        case groupName = "GroupName"
        case entityTypeEnumSortOrder = "EntityTypeEnumSortOrder"
        case tenantID = "TenantID"
        case unitTypeID = "UnitTypeID"
        case propertyID = "PropertyID"
        case isInherited = "IsInherited"
        case recurringChargeID = "RecurringChargeID"
        case entityType = "EntityType"
        case entityKeyID = "EntityKeyID"
        case unitID = "UnitID"
        case frequency = "Frequency"
        case chargeTypeID = "ChargeTypeID"
        case amount = "Amount"
        case originalAmount = "OriginalAmount"
        case amountPerSquareFoot = "AmountPerSquareFoot"
        case comment = "Comment"
        case fromDate = "FromDate"
        case toDate = "ToDate"
        case isCalculated = "IsCalculated"
        case calculation = "Calculation"
        case camRecurringChargeID = "CamRecurringChargeID"
        case sortOrder = "SortOrder"
        case createDate = "CreateDate"
        case createUserID = "CreateUserID"
        case updateDate = "UpdateDate"
        case updateUserID = "UpdateUserID"
        case chargeType = "ChargeType"
    }
}
