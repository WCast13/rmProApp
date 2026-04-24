//
//  RMUnit.swift
//  rmProApp
//
//  Created by William Castellano on 8/8/24.
//

import Foundation
import SwiftData

@Model
final class RMUnit: Codable, Identifiable, Hashable, Equatable {

    @Attribute(.unique) var id: String = ""

    var unitID: Int?
    var propertyID: Int?
    var name: String?
    var unitTypeID: Int?
    var colorID: Int?
    var isVacant: Bool?
    var comment: String?
    var updateDate: String?

    var addresses: [RMAddress]?
    var leases: [RMLease]?
    var userDefinedValues: [RMUserDefinedValue]?
    var currentOccupancyStatus: RMOccupancyStatus?
    var currentOccupants: [RMTenant]?
    var primaryAddress: RMAddress?
    var unitType: RMUnitType?

    enum CodingKeys: String, CodingKey {
        case unitID = "UnitID"
        case propertyID = "PropertyID"
        case unitTypeID = "UnitTypeID"
        case name = "Name"
        case colorID = "ColorID"
        case isVacant = "IsVacant"
        case comment = "Comment"
        case updateDate = "UpdateDate"

        case userDefinedValues = "UserDefinedValues"
        case addresses = "Addresses"
        case leases = "Leases"
        case currentOccupants = "CurrentOccupants"
        case currentOccupancyStatus = "CurrentOccupancyStatus"
        case primaryAddress = "PrimaryAddress"
        case unitType = "UnitType"
    }

    init() {}

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.unitID = try container.decodeIfPresent(Int.self, forKey: .unitID)
        self.propertyID = try container.decodeIfPresent(Int.self, forKey: .propertyID)
        self.unitTypeID = try container.decodeIfPresent(Int.self, forKey: .unitTypeID)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.colorID = try container.decodeIfPresent(Int.self, forKey: .colorID)
        self.isVacant = try container.decodeIfPresent(Bool.self, forKey: .isVacant)
        self.comment = try container.decodeIfPresent(String.self, forKey: .comment)
        self.updateDate = try container.decodeIfPresent(String.self, forKey: .updateDate)
        self.userDefinedValues = try container.decodeIfPresent([RMUserDefinedValue].self, forKey: .userDefinedValues)
        self.addresses = try container.decodeIfPresent([RMAddress].self, forKey: .addresses)
        self.leases = try container.decodeIfPresent([RMLease].self, forKey: .leases)
        self.currentOccupants = try container.decodeIfPresent([RMTenant].self, forKey: .currentOccupants)
        self.currentOccupancyStatus = try container.decodeIfPresent(RMOccupancyStatus.self, forKey: .currentOccupancyStatus)
        self.primaryAddress = try container.decodeIfPresent(RMAddress.self, forKey: .primaryAddress)
        self.unitType = try container.decodeIfPresent(RMUnitType.self, forKey: .unitType)
        self.id = "unit-\(self.unitID ?? -1)"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(unitID, forKey: .unitID)
        try container.encodeIfPresent(propertyID, forKey: .propertyID)
        try container.encodeIfPresent(unitTypeID, forKey: .unitTypeID)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(colorID, forKey: .colorID)
        try container.encodeIfPresent(isVacant, forKey: .isVacant)
        try container.encodeIfPresent(comment, forKey: .comment)
        try container.encodeIfPresent(updateDate, forKey: .updateDate)
        try container.encodeIfPresent(userDefinedValues, forKey: .userDefinedValues)
        try container.encodeIfPresent(addresses, forKey: .addresses)
        try container.encodeIfPresent(leases, forKey: .leases)
        try container.encodeIfPresent(currentOccupants, forKey: .currentOccupants)
        try container.encodeIfPresent(currentOccupancyStatus, forKey: .currentOccupancyStatus)
        try container.encodeIfPresent(primaryAddress, forKey: .primaryAddress)
        try container.encodeIfPresent(unitType, forKey: .unitType)
    }

    static func == (lhs: RMUnit, rhs: RMUnit) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
