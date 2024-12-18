//
//  RMUnit.swift
//  rmProApp
//
//  Created by William Castellano on 8/8/24.
//

import Foundation

struct RMUnit: Codable, Identifiable {
    
    let uuid = UUID()
    var id: UUID { uuid }
    
    let UnitID: Int?
    let propertyID: Int?
    let name: String?
    let UnitTypeID: Int?
    let colorID: Int?
    let isVacant: Bool?
    
    let addresses: [RMAddress]?
    let leases: [RMLease]?
    let userDefinedValues: [RMUserDefinedValue]?
    let currentOccupancyStatus: RMOccupancyStatus?
    let currentOccupants: [RMTenant]?
    let primaryAddress: RMAddress?  // Added for PrimaryAddress
    let unitType: RMUnitType?       // Added for UnitType
    
    enum CodingKeys: String, CodingKey {
        
        case UnitID = "UnitID"
        case propertyID = "PropertyID"
        case UnitTypeID = "UnitTypeID"
        case name = "Name"
        case colorID = "ColorID"
        case isVacant = "IsVacant"
        
        case userDefinedValues = "UserDefinedValues"
        case addresses = "Addresses"
        case leases = "Leases"
        case currentOccupants = "CurrentOccupants"
        case currentOccupancyStatus = "CurrentOccupancyStatus"
        case primaryAddress = "PrimaryAddress"  // Mapping for PrimaryAddress
        case unitType = "UnitType"
    }
}
