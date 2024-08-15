//
//  RMUnit.swift
//  rmProApp
//
//  Created by William Castellano on 8/8/24.
//

import Foundation

struct RMUnit: Codable {
    
    let UnitID: Int?
    let propertyID: Int?
    let name: String?
    let colorID: Int?
    let isVacant: Bool?
    
    let addresses: [RMAddress]?
    let leases: [RMLease]?
    let userDefinedValues: [RMUserDefinedValue]?
    let currentOccupancyStatus: RMOccupancyStatus?
    let currentOccupants: [RMTenant]?
    
    enum CodingKeys: String, CodingKey {
        
        case UnitID = "UnitID"
        case propertyID = "PropertyID"
        case name = "Name"
        case colorID = "ColorID"
        case isVacant = "IsVacant"
        
        case userDefinedValues = "UserDefinedValues"
        case addresses = "Addresses"
        case leases = "Leases"
        case currentOccupants = "CurrentOccupants"
        case currentOccupancyStatus = "CurrentOccupancyStatus"
       
    }
}
