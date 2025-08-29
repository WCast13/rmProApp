//
//  RMAddress.swift
//  rmProApp
//
//  Created by William Castellano on 8/9/24.
//

import Foundation
import SwiftData

struct RMAddress: Codable, Identifiable {
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
    
    // MARK: - Initializer
    init(id: UUID = UUID(), addressID: Int? = nil, addressTypeID: Int? = nil, address: String? = nil, street: String? = nil, city: String? = nil, state: String? = nil, postalCode: String? = nil, isPrimary: Bool? = nil, isBilling: Bool? = nil, parentID: Int? = nil, parentType: String? = nil) {
        self.id = id
        self.addressID = addressID
        self.addressTypeID = addressTypeID
        self.address = address
        self.street = street
        self.city = city
        self.state = state
        self.postalCode = postalCode
        self.isPrimary = isPrimary
        self.isBilling = isBilling
        self.parentID = parentID
        self.parentType = parentType
    }

    // MARK: - Codable
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let addressID = try container.decodeIfPresent(Int.self, forKey: .addressID)
        let addressTypeID = try container.decodeIfPresent(Int.self, forKey: .addressTypeID)
        let address = try container.decodeIfPresent(String.self, forKey: .address)
        let street = try container.decodeIfPresent(String.self, forKey: .street)
        let city = try container.decodeIfPresent(String.self, forKey: .city)
        let state = try container.decodeIfPresent(String.self, forKey: .state)
        let postalCode = try container.decodeIfPresent(String.self, forKey: .postalCode)
        let isPrimary = try container.decodeIfPresent(Bool.self, forKey: .isPrimary)
        let isBilling = try container.decodeIfPresent(Bool.self, forKey: .isBilling)
        let parentID = try container.decodeIfPresent(Int.self, forKey: .parentID)
        let parentType = try container.decodeIfPresent(String.self, forKey: .parentType)
        // id is not encoded/decoded, keep default
        self.init(addressID: addressID, addressTypeID: addressTypeID, address: address, street: street, city: city, state: state, postalCode: postalCode, isPrimary: isPrimary, isBilling: isBilling, parentID: parentID, parentType: parentType)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(addressID, forKey: .addressID)
        try container.encodeIfPresent(addressTypeID, forKey: .addressTypeID)
        try container.encodeIfPresent(address, forKey: .address)
        try container.encodeIfPresent(street, forKey: .street)
        try container.encodeIfPresent(city, forKey: .city)
        try container.encodeIfPresent(state, forKey: .state)
        try container.encodeIfPresent(postalCode, forKey: .postalCode)
        try container.encodeIfPresent(isPrimary, forKey: .isPrimary)
        try container.encodeIfPresent(isBilling, forKey: .isBilling)
        try container.encodeIfPresent(parentID, forKey: .parentID)
        try container.encodeIfPresent(parentType, forKey: .parentType)
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

