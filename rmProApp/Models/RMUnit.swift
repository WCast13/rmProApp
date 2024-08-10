//
//  RMUnit.swift
//  rmProApp
//
//  Created by William Castellano on 8/8/24.
//

import Foundation

struct RMUnit: Codable {
    
    let unitID: Int
    let propertyID: Int
    let name: String
    let colorID: Int
    let isVacant: Bool
    
    let addresses: [RMAddress]
    let leases: [RMLease]
    let userDefinedValues: [RMUserDefinedValue]
    let currentOccupancyStatus: RMOccupancyStatus
    let currentOccupants: [RMTennant]
    
    enum CodingKeys: String, CodingKey {
        
        case unitID = "UnitID"
        case propertyID = "PropertyID"
        case name = "Name"
        case colorID = "ColorID"
        case userDefinedValues = "UserDefinedValues"
        case addresses = "Addresses"
        case leases = "Leases"
        case currentOccupants = "CurrentOccupants"
        case currentOccupancyStatus = "CurrentOccupancyStatus"
        case isVacant = "IsVacant"
    }
}
