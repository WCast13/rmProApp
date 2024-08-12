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
//    let billingName1: String
//    let billingName2: String
//    let managerName: String
//    let isActive: Bool?
//    let propertyType: String
//    let email: String
//    let taxID: String
//    let statementMethod: String
//    let comment: String
//    let isSystemDefaultAssignedUser: Bool?
//    let createDate: String
//    let updateDate: String
//    let createUserID: Int
//    let updateUserID: Int
//    let concurrencyID: Int
//    let isEpayEnabled: Bool?
//    let defaultBankID: Int
//    let lastDailyPost: String?
//    let vacantUnitIDs: String
//    let serviceManagerAssignedUserID: Int?
//    let isOverrideAssignedUserID: Bool?
//    let isLateChargeEnabled: Bool?
//    let lastMonthlyPost: String?
//    let postingDay: Int?
//    let logoFileID: Int?
//    let primaryOwnerID: Int?
//    let isAllocationOrderDisabled: Bool?
//    let aRAutomationUseSystemPreference: Bool?
    
    enum CodingKeys: String, CodingKey {
        case propertyID = "PropertyID"
        case name = "Name"
        case shortName = "ShortName"
//        case billingName1 = "BillingName1"
//        case billingName2 = "BillingName2"
//        case managerName = "ManagerName"
//        case isActive = "IsActive"
//        case propertyType = "PropertyType"
//        case email = "Email"
//        case taxID = "TaxID"
//        case statementMethod = "StatementMethod"
//        case comment = "Comment"
//        case isSystemDefaultAssignedUser = "IsSystemDefaultAssignedUser"
//        case createDate = "CreateDate"
//        case updateDate = "UpdateDate"
//        case createUserID = "CreateUserID"
//        case updateUserID = "UpdateUserID"
//        case concurrencyID = "ConcurrencyID"
//        case isEpayEnabled = "IsEpayEnabled"
//        case defaultBankID = "DefaultBankID"
//        case lastDailyPost = "LastDailyPost"
//        case vacantUnitIDs = "VacantUnitIDs"
//        case serviceManagerAssignedUserID = "ServiceManagerAssignedUserID"
//        case isOverrideAssignedUserID = "IsOverrideAssignedUserID"
//        case isLateChargeEnabled = "IsLateChargeEnabled"
//        case lastMonthlyPost = "LastMonthlyPost"
//        case postingDay = "PostingDay"
//        case logoFileID = "LogoFileID"
//        case primaryOwnerID = "PrimaryOwnerID"
//        case isAllocationOrderDisabled = "IsAllocationOrderDisabled"
//        case aRAutomationUseSystemPreference = "ARAutomationUseSystemPreference"
    }
}
