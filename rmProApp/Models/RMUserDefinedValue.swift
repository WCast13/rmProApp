//
//  RMUserDefinedValue.swift
//  rmProApp
//
//  Created by William Castellano on 8/9/24.
//

import Foundation

struct RMUserDefinedValue : Codable, Identifiable, Hashable {
    let id = UUID()
    let userDefinedValueID: Int?
    let userDefinedFieldID: Int?
    let parentID: Int?
    let name: String?
    let value: String?
    let dateValue: String?
    let updateDate: String?
    let fieldType: String?
    let updateUserID: Int?
    let createUserID: Int?
    
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
    }
}
