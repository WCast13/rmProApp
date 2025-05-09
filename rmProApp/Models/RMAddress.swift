//
//  RMAddress.swift
//  rmProApp
//
//  Created by William Castellano on 8/9/24.
//

import Foundation

struct RMAddress: Codable, Identifiable, Hashable {
    static func == (lhs: RMAddress, rhs: RMAddress) -> Bool {
        lhs.id == rhs.id
    }
    
    var id = UUID()
    var addressID: Int?
    var addressTypeID: Int?
    var address: String?
    var street: String?
    var city: String?
    var state: String?
    var postalCode: String?
    var isPrimary: Bool?
    var isBilling: Bool?
    var parentID: Int?
    var parentType: String?
//    let addressType: RMAddressType?
    
    enum CodingKeys: String, CodingKey {
        case addressID = "AddressID"
        case addressTypeID = "AddressTypeID"
        case address = "Address"
        case street = "Street"
        case city = "City"
        case state = "State"
        case postalCode = "PostalCode"
        case isPrimary = "IsPrimary"
        case isBilling = "IsBilling"
        case parentID = "ParentID"
        case parentType = "ParentType"
//        case addressType = "AddressType"
    }
}

struct RMAddressType: Codable {
    let addressTypeID: Int?
    let name: String?
    let description: String?
    let sortOrder: Int?
    let parentType: String?
    
    enum CodingKeys: String, CodingKey {
        case addressTypeID = "AddressTypeID"
        case name = "Name"
        case description = "Description"
        case sortOrder = "SortOrder"
        case parentType = "ParentType"
    }
}
