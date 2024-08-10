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
    
    enum CodingKeys: String, CodingKey {
        case contactID = "ContactID"
        case firstName = "FirstName"
        case lastName = "LastName"
        case middleName = "MiddleName"
        case isActive = "IsActive"
        case isPrimary = "IsPrimary"
        case contactTypeID = "ContactTypeID"
        case dateOfBirth = "DateOfBirth"
        case federalTaxID = "FederalTaxID"
        case comment = "Comment"
        case email = "Email"
        case license = "License"
        case vehicle = "Vehicle"
        case imageID = "ImageID"
        case isShowOnBill = "IsShowOnBill"
        case employer = "Employer"
        case applicantType = "ApplicantType"
        case createDate = "CreateDate"
        case createUserID = "CreateUserID"
        case updateDate = "UpdateDate"
        case annualIncome = "AnnualIncome"
        case updateUserID = "UpdateUserID"
        case parentID = "ParentID"
        case parentType = "ParentType"
    }
}
