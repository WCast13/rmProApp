//
//  RMLease.swift
//  rmProApp
//
//  Created by William Castellano on 8/9/24.
//

import Foundation
import SwiftData

@Model
final class RMLease : Codable, Identifiable, Hashable, Equatable {
    static func == (lhs: RMLease, rhs: RMLease) -> Bool {
        lhs.id == rhs.id
    }
    
    
    var id = UUID()
    var leaseID: Int?
    var tenantID: Int?
    var unitID: Int?
    var propertyID: Int?
    var isCommercial: Bool?
    var moveInDate: String?
    var moveOutDate: String?
    var expectedMoveOutDate: String?
    var noticeDate: String?
    var isMoveOutConfirmed: Bool?
    var arrivalDate: String?
    var departureDate: String?
    var sortOrder: Int?
    var createDate: String?
    var updateDate: String?
    var startDate: String?
    var endDate: String?
    var createUserID: Int?
    var updateUserID: Int?
    var tenant: RMTenant?
    var unit: RMUnit?
    var property: RMProperty?
    var propertyUnit: String?
    var unitProperty: String?
    
    
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
    
    init(
        id: UUID = UUID(),
        leaseID: Int? = nil,
        tenantID: Int? = nil,
        unitID: Int? = nil,
        propertyID: Int? = nil,
        isCommercial: Bool? = nil,
        moveInDate: String? = nil,
        moveOutDate: String? = nil,
        expectedMoveOutDate: String? = nil,
        noticeDate: String? = nil,
        isMoveOutConfirmed: Bool? = nil,
        arrivalDate: String? = nil,
        departureDate: String? = nil,
        sortOrder: Int? = nil,
        createDate: String? = nil,
        updateDate: String? = nil,
        startDate: String? = nil,
        endDate: String? = nil,
        createUserID: Int? = nil,
        updateUserID: Int? = nil,
        tenant: RMTenant? = nil,
        unit: RMUnit? = nil,
        property: RMProperty? = nil,
        propertyUnit: String? = nil,
        unitProperty: String? = nil
    ) {
        self.id = id
        self.leaseID = leaseID
        self.tenantID = tenantID
        self.unitID = unitID
        self.propertyID = propertyID
        self.isCommercial = isCommercial
        self.moveInDate = moveInDate
        self.moveOutDate = moveOutDate
        self.expectedMoveOutDate = expectedMoveOutDate
        self.noticeDate = noticeDate
        self.isMoveOutConfirmed = isMoveOutConfirmed
        self.arrivalDate = arrivalDate
        self.departureDate = departureDate
        self.sortOrder = sortOrder
        self.createDate = createDate
        self.updateDate = updateDate
        self.startDate = startDate
        self.endDate = endDate
        self.createUserID = createUserID
        self.updateUserID = updateUserID
        self.tenant = tenant
        self.unit = unit
        self.property = property
        self.propertyUnit = propertyUnit
        self.unitProperty = unitProperty
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.leaseID = try container.decodeIfPresent(Int.self, forKey: .leaseID)
        self.tenantID = try container.decodeIfPresent(Int.self, forKey: .tenantID)
        self.unitID = try container.decodeIfPresent(Int.self, forKey: .unitID)
        self.propertyID = try container.decodeIfPresent(Int.self, forKey: .propertyID)
        self.isCommercial = try container.decodeIfPresent(Bool.self, forKey: .isCommercial)
        self.moveInDate = try container.decodeIfPresent(String.self, forKey: .moveInDate)
        self.moveOutDate = try container.decodeIfPresent(String.self, forKey: .moveOutDate)
        self.expectedMoveOutDate = try container.decodeIfPresent(String.self, forKey: .expectedMoveOutDate)
        self.noticeDate = try container.decodeIfPresent(String.self, forKey: .noticeDate)
        self.isMoveOutConfirmed = try container.decodeIfPresent(Bool.self, forKey: .isMoveOutConfirmed)
        self.arrivalDate = try container.decodeIfPresent(String.self, forKey: .arrivalDate)
        self.departureDate = try container.decodeIfPresent(String.self, forKey: .departureDate)
        self.sortOrder = try container.decodeIfPresent(Int.self, forKey: .sortOrder)
        self.createDate = try container.decodeIfPresent(String.self, forKey: .createDate)
        self.updateDate = try container.decodeIfPresent(String.self, forKey: .updateDate)
        self.startDate = try container.decodeIfPresent(String.self, forKey: .startDate)
        self.endDate = try container.decodeIfPresent(String.self, forKey: .endDate)
        self.createUserID = try container.decodeIfPresent(Int.self, forKey: .createUserID)
        self.updateUserID = try container.decodeIfPresent(Int.self, forKey: .updateUserID)
        self.property = try container.decodeIfPresent(RMProperty.self, forKey: .property)
        self.tenant = try container.decodeIfPresent(RMTenant.self, forKey: .tenant)
        self.unit = try container.decodeIfPresent(RMUnit.self, forKey: .unit)
        self.propertyUnit = try container.decodeIfPresent(String.self, forKey: .propertyUnit)
        self.unitProperty = try container.decodeIfPresent(String.self, forKey: .unitProperty)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(leaseID, forKey: .leaseID)
        try container.encodeIfPresent(tenantID, forKey: .tenantID)
        try container.encodeIfPresent(unitID, forKey: .unitID)
        try container.encodeIfPresent(propertyID, forKey: .propertyID)
        try container.encodeIfPresent(isCommercial, forKey: .isCommercial)
        try container.encodeIfPresent(moveInDate, forKey: .moveInDate)
        try container.encodeIfPresent(moveOutDate, forKey: .moveOutDate)
        try container.encodeIfPresent(expectedMoveOutDate, forKey: .expectedMoveOutDate)
        try container.encodeIfPresent(noticeDate, forKey: .noticeDate)
        try container.encodeIfPresent(isMoveOutConfirmed, forKey: .isMoveOutConfirmed)
        try container.encodeIfPresent(arrivalDate, forKey: .arrivalDate)
        try container.encodeIfPresent(departureDate, forKey: .departureDate)
        try container.encodeIfPresent(sortOrder, forKey: .sortOrder)
        try container.encodeIfPresent(createDate, forKey: .createDate)
        try container.encodeIfPresent(updateDate, forKey: .updateDate)
        try container.encodeIfPresent(startDate, forKey: .startDate)
        try container.encodeIfPresent(endDate, forKey: .endDate)
        try container.encodeIfPresent(createUserID, forKey: .createUserID)
        try container.encodeIfPresent(updateUserID, forKey: .updateUserID)
        try container.encodeIfPresent(property, forKey: .property)
        try container.encodeIfPresent(tenant, forKey: .tenant)
        try container.encodeIfPresent(unit, forKey: .unit)
        try container.encodeIfPresent(propertyUnit, forKey: .propertyUnit)
        try container.encodeIfPresent(unitProperty, forKey: .unitProperty)
    }
}
