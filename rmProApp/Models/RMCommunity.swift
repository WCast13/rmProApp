//
//  RMCommunity.swift
//  rmProApp
//
//  Created by William Castellano on 8/8/24.
//

import Foundation

struct RMProperty: Codable {
    let propertyID: Int
    let name: String
    let shortName: String
    let billingName1: String
    let billingName2: String
    let managerName: String
    let isActive: Bool?
    let propertyType: String
    let email: String
    let taxID: String
    let statementMethod: String
    let comment: String
    let isSystemDefaultAssignedUser: Bool?
    let createDate: String
    let updateDate: String
    let createUserID: Int
    let updateUserID: Int
    let concurrencyID: Int
    let isEpayEnabled: Bool?
    let defaultBankID: Int
    let lastDailyPost: String?
    let vacantUnitIDs: String
    let serviceManagerAssignedUserID: Int?
    let isOverrideAssignedUserID: Bool?
    let isLateChargeEnabled: Bool?
    let lastMonthlyPost: String?
    let postingDay: Int?
    let logoFileID: Int?
    let primaryOwnerID: Int?
    let isAllocationOrderDisabled: Bool?
    let aRAutomationUseSystemPreference: Bool?
}
