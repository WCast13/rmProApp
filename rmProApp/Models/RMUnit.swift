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
}
