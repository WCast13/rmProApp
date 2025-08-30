//
//  RMUnit.swift
//  rmProApp
//
//  Created by William Castellano on 8/8/24.
//

import Foundation

struct RMUnit: Codable, Identifiable, Equatable, Hashable {
   
    let uuid = UUID()
    var id: UUID { uuid }
    
    let unitID: Int?
    let propertyID: Int?
    let name: String?
    let unitTypeID: Int?
    let colorID: Int?
    let isVacant: Bool?
    let comment: String?
    
    let addresses: [RMAddress]?
    let leases: [RMLease]?
    let userDefinedValues: [RMUserDefinedValue]?
    let currentOccupancyStatus: RMOccupancyStatus?
    let currentOccupants: [RMTenant]?
    let primaryAddress: RMAddress?
    let unitType: RMUnitType?
    
    enum CodingKeys: String, CodingKey {
        
        case unitID = "UnitID"
        case propertyID = "PropertyID"
        case unitTypeID = "UnitTypeID"
        case name = "Name"
        case colorID = "ColorID"
        case isVacant = "IsVacant"
        case comment = "Comment"
        
        case userDefinedValues = "UserDefinedValues"
        case addresses = "Addresses"
        case leases = "Leases"
        case currentOccupants = "CurrentOccupants"
        case currentOccupancyStatus = "CurrentOccupancyStatus"
        case primaryAddress = "PrimaryAddress"  // Mapping for PrimaryAddress
        case unitType = "UnitType"
    }
    
    //Equatable Conformence
    static func == (lhs: RMUnit, rhs: RMUnit) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}
