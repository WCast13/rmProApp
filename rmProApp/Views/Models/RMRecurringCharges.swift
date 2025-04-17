//
//  RMRecurringCharges.swift
//  rmProApp
//
//  Created by William Castellano on 4/11/25.
//

import Foundation

struct RMRecurringCharges: Codable, Identifiable {
    var id = UUID()

    let recurringChargeID: Int?
    let entityType: String?
    let entityKeyID: Int?
    let unitID: Int?
    let frequency: Int?
    let chargeTypeID: Int?
    let amount: Double?
    let originalAmount: Int?
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
    let tenantID: Int?
    let tenant: RMTenant?
    let linkedUnit: RMUnit?
    let unit: RMUnit?
    let unitTypeID: Int?
    let unitType: RMUnitType?
    let propertyID: Int?
    let property: RMProperty?
    
    enum CodingKeys: String, CodingKey {
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
        case tenantID = "TenantID"
        case tenant = "Tenant"
        case linkedUnit = "LinkedUnit"
        case unit = "Unit"
        case unitTypeID = "UnitTypeID"
        case unitType = "UnitType"
        case propertyID = "PropertyID"
        case property = "Property"
    }
}
