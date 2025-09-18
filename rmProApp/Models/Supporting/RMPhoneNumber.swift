//
//  RMPhoneNumber.swift
//  rmProApp
//
//  Created by William Castellano on 12/23/24.
//

import Foundation
import SwiftData

@Model
final class RMPhoneNumber: Codable, Identifiable, Hashable, Equatable {
    static func == (lhs: RMPhoneNumber, rhs: RMPhoneNumber) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id = UUID()
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
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.phoneNumberID = try container.decodeIfPresent(Int.self, forKey: .phoneNumberID)
        self.phoneNumberTypeID = try container.decodeIfPresent(Int.self, forKey: .phoneNumberTypeID)
        self.phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
        self.phoneNumberExtension = try container.decodeIfPresent(String.self, forKey: .phoneNumberExtension)
        self.strippedPhoneNumber = try container.decodeIfPresent(String.self, forKey: .strippedPhoneNumber)
        self.isPrimary = try container.decodeIfPresent(Bool.self, forKey: .isPrimary)
        self.isTextReady = try container.decodeIfPresent(Bool.self, forKey: .isTextReady)
        self.isOptOut = try container.decodeIfPresent(Bool.self, forKey: .isOptOut)
        self.parentID = try container.decodeIfPresent(Int.self, forKey: .parentID)
        self.parentType = try container.decodeIfPresent(String.self, forKey: .parentType)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(phoneNumberID, forKey: .phoneNumberID)
        try container.encodeIfPresent(phoneNumberTypeID, forKey: .phoneNumberTypeID)
        try container.encodeIfPresent(phoneNumber, forKey: .phoneNumber)
        try container.encodeIfPresent(phoneNumberExtension, forKey: .phoneNumberExtension)
        try container.encodeIfPresent(strippedPhoneNumber, forKey: .strippedPhoneNumber)
        try container.encodeIfPresent(isPrimary, forKey: .isPrimary)
        try container.encodeIfPresent(isTextReady, forKey: .isTextReady)
        try container.encodeIfPresent(isOptOut, forKey: .isOptOut)
        try container.encodeIfPresent(parentID, forKey: .parentID)
        try container.encodeIfPresent(parentType, forKey: .parentType)
    }
}
