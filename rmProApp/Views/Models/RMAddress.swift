//
//  RMAddress.swift
//  rmProApp
//
//  Created by William Castellano on 8/9/24.
//

import Foundation

struct RMAddress: Codable {
    let addressID: Int?
    let addressTypeID: Int?
    let address: String?
    let street: String?
    let city: String?
    let state: String?
    let postalCode: String?
    let isPrimary: Bool?
    let isBilling: Bool?
    let parentID: Int?
    let parentType: String?
    let addressType: RMAddressType?
    
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
        case addressType = "AddressType"
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
