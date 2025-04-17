//
//  RMProperty.swift
//  rmProApp
//
//  Created by William Castellano on 8/8/24.
//

import Foundation

struct RMProperty: Codable {
    let propertyID: Int?
    let name: String?
    let shortName: String?
    let billingName1: String?
    let billingName2: String?
    let managerName: String?
    let isActive: Bool?
    let propertyType: String?
    let email: String?
    let taxID: String?
    let comment: String?
    let createDate: String?
    let updateDate: String?
    let createUserID: Int?
    let updateUserID: Int?
    let concurrencyID: Int?
    let colorID: Int?
    let isLateChargeEnabled: Bool?
    let isEpayEnabled: Bool?
    let defaultBankID: Int?
    let postingDay: Int?
    let lastMonthlyPost: String?
    let lastDailyPost: String?
    let evictionWorkflowID: Int?
    let unitCount: Int?
    let occupiedUnitCount: Int?
    let vacantUnitCount: Int?
    let lastUnitCountPost: String?
    let vacantUnitIDs: String?
    
    enum CodingKeys: String, CodingKey {
        case propertyID = "PropertyID"
        case name = "Name"
        case shortName = "ShortName"
        case billingName1 = "BillingName1"
        case billingName2 = "BillingName2"
        case managerName = "ManagerName"
        case isActive = "IsActive"
        case propertyType = "PropertyType"
        case email = "Email"
        case taxID = "TaxID"
        case comment = "Comment"
        case createDate = "CreateDate"
        case updateDate = "UpdateDate"
        case createUserID = "CreateUserID"
        case updateUserID = "UpdateUserID"
        case concurrencyID = "ConcurrencyID"
        case isEpayEnabled = "IsEpayEnabled"
        case defaultBankID = "DefaultBankID"
        case lastDailyPost = "LastDailyPost"
        case vacantUnitIDs = "VacantUnitIDs"
        case isLateChargeEnabled = "IsLateChargeEnabled"
        case lastMonthlyPost = "LastMonthlyPost"
        case postingDay = "PostingDay"
        case evictionWorkflowID = "EvictionWorkflowID"
        case unitCount = "UnitCount"
        case occupiedUnitCount = "OccupiedUnitCount"
        case vacantUnitCount = "VacantUnitCount"
        case lastUnitCountPost = "LastUnitCountPost"
        case colorID = "ColorID"
    }
}
