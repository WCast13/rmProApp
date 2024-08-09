//
//  RMContact.swift
//  rmProApp
//
//  Created by William Castellano on 8/7/24.
//

import Foundation

struct RMContact: Codable {
    let contactID: Int
    let firstName: String
    let lastName: String
    let middleName: String
    let isActive: Bool
    let isPrimary: Bool?
    let contactTypeID: Int
    let dateOfBirth: String?
    let federalTaxID: String
    let comment: String
    let email: String
    let license: String
    let vehicle: String
    let imageID: Int
    let isShowOnBill: Bool?
    let employer: String
    let applicantType: String?
    let createDate: String
    let createUserID: Int
    let updateDate: String
    let annualIncome: Double
    let updateUserID: Int
    let parentID: Int
    let parentType: String
}
