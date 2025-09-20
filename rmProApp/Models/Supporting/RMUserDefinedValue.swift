//
//  RMUserDefinedValue.swift
//  rmProApp
//
//  Created by William Castellano on 8/9/24.
//

import Foundation
import SwiftData

@Model
class RMUserDefinedValue: Codable, Identifiable, Hashable {
    @Attribute(.unique) var id: UUID
    var userDefinedValueID: Int?
    var userDefinedFieldID: Int?
    var parentID: Int?
    var name: String?
    var value: String?
    var dateValue: String?
    var updateDate: String?
    var fieldType: String?
    var updateUserID: Int?
    var createUserID: Int?
    var lastSyncDate: Date?
    var parentType: String?

    init(userDefinedValueID: Int? = nil, userDefinedFieldID: Int? = nil, parentID: Int? = nil,
         name: String? = nil, value: String? = nil, dateValue: String? = nil,
         updateDate: String? = nil, fieldType: String? = nil, updateUserID: Int? = nil,
         createUserID: Int? = nil) {
        self.id = UUID()
        self.userDefinedValueID = userDefinedValueID
        self.userDefinedFieldID = userDefinedFieldID
        self.parentID = parentID
        self.name = name
        self.value = value
        self.dateValue = dateValue
        self.updateDate = updateDate
        self.fieldType = fieldType
        self.updateUserID = updateUserID
        self.createUserID = createUserID
        self.lastSyncDate = Date()
        self.parentType = parentType
    }

    // MARK: - Codable Implementation
    enum CodingKeys: String, CodingKey {
        case userDefinedValueID = "UserDefinedValueID"
        case userDefinedFieldID = "UserDefinedFieldID"
        case parentID = "ParentID"
        case name = "Name"
        case value = "Value"
        case dateValue = "DateValue"
        case updateDate = "UpdateDate"
        case fieldType = "FieldType"
        case updateUserID = "UpdateUserID"
        case createUserID = "CreateUserID"
        case parentType = "ParentType"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.userDefinedValueID = try container.decodeIfPresent(Int.self, forKey: .userDefinedValueID)
        self.userDefinedFieldID = try container.decodeIfPresent(Int.self, forKey: .userDefinedFieldID)
        self.parentID = try container.decodeIfPresent(Int.self, forKey: .parentID)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.value = try container.decodeIfPresent(String.self, forKey: .value)
        self.dateValue = try container.decodeIfPresent(String.self, forKey: .dateValue)
        self.updateDate = try container.decodeIfPresent(String.self, forKey: .updateDate)
        self.fieldType = try container.decodeIfPresent(String.self, forKey: .fieldType)
        self.updateUserID = try container.decodeIfPresent(Int.self, forKey: .updateUserID)
        self.createUserID = try container.decodeIfPresent(Int.self, forKey: .createUserID)
        self.lastSyncDate = Date()
        self.parentType = try container.decodeIfPresent(String.self, forKey: .parentType)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(userDefinedValueID, forKey: .userDefinedValueID)
        try container.encodeIfPresent(userDefinedFieldID, forKey: .userDefinedFieldID)
        try container.encodeIfPresent(parentID, forKey: .parentID)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(value, forKey: .value)
        try container.encodeIfPresent(dateValue, forKey: .dateValue)
        try container.encodeIfPresent(updateDate, forKey: .updateDate)
        try container.encodeIfPresent(fieldType, forKey: .fieldType)
        try container.encodeIfPresent(updateUserID, forKey: .updateUserID)
        try container.encodeIfPresent(createUserID, forKey: .createUserID)
        try container.encodeIfPresent(parentType, forKey: .parentType)
    }

    // MARK: - Hashable Implementation
    static func == (lhs: RMUserDefinedValue, rhs: RMUserDefinedValue) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
