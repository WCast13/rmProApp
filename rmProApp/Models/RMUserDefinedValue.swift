//
//  RMUserDefinedValue.swift
//  rmProApp
//
//  Created by William Castellano on 8/9/24.
//

import Foundation

struct RMUserDefinedValue : Codable {
    let userDefinedValueID: Int
    let userDefinedFieldID: Int
    let parentID: Int
    let name: String
    let value: String
    let dateValue: String
    let updateDate: String
    let fieldType: String
    let updateUserID: Int
    let createUserID: Int
}
