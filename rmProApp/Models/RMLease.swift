//
//  RMLease.swift
//  rmProApp
//
//  Created by William Castellano on 8/9/24.
//

import Foundation

struct RMLease : Codable {
    let leaseID: Int?
    let tenantID: Int?
    let unitID: Int?
    let propertyID: Int?
    let isCommercial: Bool?
    let moveInDate: String?
    let moveOutDate: String?
    let expectedMoveOutDate: Date?
    let noticeDate: Date?
    let isMoveOutConfirmed: Bool?
    let arrivalDate: String?
    let departureDate: String?
    let isExcludeFromMasterPolicy: Bool?
    let sortOrder: Int?
    let createDate: String?
    let updateDate: String?
    let startDate: String?
    let endDate: String?
    let createUserID: Int?
    let updateUserID: Int?
    let tenant: RMTenant?
    let propertyUnit: String?
    let unitProperty: String?
    
    enum CodingKeys: String, CodingKey {
            case leaseID = "LeaseID"
            case tenantID = "TenantID"
            case unitID = "UnitID"
            case propertyID = "PropertyID"
            case isCommercial = "IsCommercial"
            case moveInDate = "MoveInDate"
            case moveOutDate = "MoveOutDate"
            case expectedMoveOutDate = "ExpectedMoveOutDate"
            case noticeDate = "NoticeDate"
            case isMoveOutConfirmed = "IsMoveOutConfirmed"
            case arrivalDate = "ArrivalDate"
            case departureDate = "DepartureDate"
            case isExcludeFromMasterPolicy = "IsExcludeFromMasterPolicy"
            case sortOrder = "SortOrder"
            case createDate = "CreateDate"
            case updateDate = "UpdateDate"
            case startDate = "StartDate"
            case endDate = "EndDate"
            case createUserID = "CreateUserID"
            case updateUserID = "UpdateUserID"
            case tenant = "Tenant"
            case propertyUnit = "PropertyUnit"
            case unitProperty = "UnitProperty"
        }
}
