//
//  RMPhoneNumber.swift
//  rmProApp
//
//  Created by William Castellano on 12/23/24.
//

import Foundation

struct RMPhoneNumber: Codable {
    var phoneNumberID: Int?
    var phoneNumberTypeID: Int?
    var phoneNumber: String?
    var phoneNumberExtension: String?
    var strippedPhoneNumber: String?
    var isPrimary: Bool?
    var isTextReady: Bool?
    var isOptOut: Bool?
    var parentID: Int?
    var parentType: String?
//    var phoneNumberType: PhoneNumberType?

    enum CodingKeys: String, CodingKey {
        case phoneNumberID = "PhoneNumberID"
        case phoneNumberTypeID = "PhoneNumberTypeID"
        case phoneNumber = "PhoneNumber"
        case phoneNumberExtension = "Extension"
        case strippedPhoneNumber = "StrippedPhoneNumber"
        case isPrimary = "IsPrimary"
        case isTextReady = "IsTextReady"
        case isOptOut = "IsOptOut"
        case parentID = "ParentID"
        case parentType = "ParentType"
//        case phoneNumberType = "PhoneNumberType"
    }
}
