//
//  RMLease.swift
//  rmProApp
//
//  Created by William Castellano on 8/9/24.
//

import Foundation

struct RMLease : Codable, Identifiable, Hashable, Equatable {
    static func == (lhs: RMLease, rhs: RMLease) -> Bool {
        lhs.id == rhs.id
    }
    
    
    let id = UUID()
    let leaseID: Int?
    let tenantID: Int?
    let unitID: Int?
    let propertyID: Int?
    let isCommercial: Bool?
    let moveInDate: String?
    let moveOutDate: String?
    let expectedMoveOutDate: String?
    let noticeDate: String?
    let isMoveOutConfirmed: Bool?
    let arrivalDate: String?
    let departureDate: String?
    let sortOrder: Int?
    let createDate: String?
    let updateDate: String?
    let startDate: String?
    let endDate: String?
    let createUserID: Int?
    let updateUserID: Int?
    let tenant: RMTenant?
    let unit: RMUnit?
    let property: RMProperty?
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
        case sortOrder = "SortOrder"
        case createDate = "CreateDate"
        case updateDate = "UpdateDate"
        case startDate = "StartDate"
        case endDate = "EndDate"
        case createUserID = "CreateUserID"
        case updateUserID = "UpdateUserID"
        case property = "Property"
        case tenant = "Tenant"
        case unit = "Unit"
        case propertyUnit = "PropertyUnit"
        case unitProperty = "UnitProperty"
    }
}
