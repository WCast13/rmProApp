//
//  RMAddress.swift
//  rmProApp
//
//  Created by William Castellano on 8/9/24.
//

import Foundation

struct RMAddress: Codable {
    let addressID: Int
    let addressTypeID: Int
    let address: String
    let street: String
    let city: String
    let state: String
    let postalCode: String
    let isPrimary: Bool
    let isBilling: Bool
    let parentID: Int
    let parentType: String
    let addressType: RMAddressType
}

struct RMAddressType: Codable {
    let addressTypeID: Int
    let name: String
    let description: String
    let sortOrder: Int
    let parentType: String
}
