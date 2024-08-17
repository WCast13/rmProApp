//
//  RMUnitType.swift
//  rmProApp
//
//  Created by William Castellano on 8/16/24.
//

import Foundation

struct RMUnitType: Codable {
    let unitTypeID: Int?
    let name: String?
    let comment: String?
    let bedrooms: Int?
    let bathrooms: Int?
    let inspectionTemplateID: Int?
    let isExcludeFromRentersInsurance: Bool?
    let createDate: String?
    let createUserID: Int?
    let updateDate: String?
    let updateUserID: Int?
    let isOtherRentableItem: Bool?
    let metaTag: String?
    
    enum CodingKeys: String, CodingKey {
        case unitTypeID = "UnitTypeID"
        case name = "Name"
        case comment = "Comment"
        case bedrooms = "Bedrooms"
        case bathrooms = "Bathrooms"
        case inspectionTemplateID = "InspectionTemplateID"
        case isExcludeFromRentersInsurance = "IsExcludeFromRentersInsurance"
        case createDate = "CreateDate"
        case createUserID = "CreateUserID"
        case updateDate = "UpdateDate"
        case updateUserID = "UpdateUserID"
        case isOtherRentableItem = "IsOtherRentableItem"
        case metaTag = "MetaTag"
    }
}
