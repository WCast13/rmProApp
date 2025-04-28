//
//  WCRentIncreaseTenant.swift
//  rmProApp
//
//  Created by William Castellano on 4/21/25.
//

import Foundation

struct WCRentIncreaseTenant: Codable, Identifiable, Hashable {
    var id = UUID()
    
    var unitName: String?
    var street: String?
    var boxNumber: String?
    var city: String?
    var state: String?
    var postalCode: String?
    
    var contacts: [RMContact] = []
}
