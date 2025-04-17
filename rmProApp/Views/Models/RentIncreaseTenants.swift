//
//  MailingTenant.swift
//  rmProApp
//
//  Created by William Castellano on 4/14/25.
//

import Foundation

struct RentIncreaseTenant: Codable, Identifiable {
    var id = UUID()
    
    var unitName: String?
    var street: String?
    var boxNumber: String?
    var city: String?
    var state: String?
    var postalCode: String?
    
    var contacts: [RMContact] = []
    
}
