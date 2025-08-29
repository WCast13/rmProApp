//
//  RMContact.swift
//  rmProApp
//
//  Created by William Castellano on 8/7/24.
//

import Foundation
import SwiftData

@Model
final class RMContact: Codable, Identifiable, Hashable, Equatable {
    
    static func == (lhs: RMContact, rhs: RMContact) -> Bool {
        lhs.contactID == rhs.contactID
    }
    
    var id = UUID()
    
    var contactID: Int?
    var firstName: String?
    var lastName: String?
    var middleName: String?
    var isActive: Bool?
    var isPrimary: Bool?
    var contactTypeID: Int?
    var dateOfBirth: String?
    var federalTaxID: String?
    var comment: String?
    var email: String?
    var license: String?
    var vehicle: String?
    var imageID: Int?
    var isShowOnBill: Bool?
    var employer: String?
    var applicantType: String?
    var createDate: String?
    var createUserID: Int?
    var updateDate: String?
    var annualIncome: Double?
    var updateUserID: Int?
    var parentID: Int?
    var parentType: String?
    var phoneNumbers: [RMPhoneNumber] = []
    
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
        case phoneNumbers = "PhoneNumbers"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.contactID = try container.decodeIfPresent(Int.self, forKey: .contactID)
        self.firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        self.lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        self.middleName = try container.decodeIfPresent(String.self, forKey: .middleName)
        self.isActive = try container.decodeIfPresent(Bool.self, forKey: .isActive)
        self.isPrimary = try container.decodeIfPresent(Bool.self, forKey: .isPrimary)
        self.contactTypeID = try container.decodeIfPresent(Int.self, forKey: .contactTypeID)
        self.dateOfBirth = try container.decodeIfPresent(String.self, forKey: .dateOfBirth)
        self.federalTaxID = try container.decodeIfPresent(String.self, forKey: .federalTaxID)
        self.comment = try container.decodeIfPresent(String.self, forKey: .comment)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.license = try container.decodeIfPresent(String.self, forKey: .license)
        self.vehicle = try container.decodeIfPresent(String.self, forKey: .vehicle)
        self.imageID = try container.decodeIfPresent(Int.self, forKey: .imageID)
        self.isShowOnBill = try container.decodeIfPresent(Bool.self, forKey: .isShowOnBill)
        self.employer = try container.decodeIfPresent(String.self, forKey: .employer)
        self.applicantType = try container.decodeIfPresent(String.self, forKey: .applicantType)
        self.createDate = try container.decodeIfPresent(String.self, forKey: .createDate)
        self.createUserID = try container.decodeIfPresent(Int.self, forKey: .createUserID)
        self.updateDate = try container.decodeIfPresent(String.self, forKey: .updateDate)
        self.annualIncome = try container.decodeIfPresent(Double.self, forKey: .annualIncome)
        self.updateUserID = try container.decodeIfPresent(Int.self, forKey: .updateUserID)
        self.parentID = try container.decodeIfPresent(Int.self, forKey: .parentID)
        self.parentType = try container.decodeIfPresent(String.self, forKey: .parentType)
        self.phoneNumbers = try container.decodeIfPresent([RMPhoneNumber].self, forKey: .phoneNumbers) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(contactID, forKey: .contactID)
        try container.encodeIfPresent(firstName, forKey: .firstName)
        try container.encodeIfPresent(lastName, forKey: .lastName)
        try container.encodeIfPresent(middleName, forKey: .middleName)
        try container.encodeIfPresent(isActive, forKey: .isActive)
        try container.encodeIfPresent(isPrimary, forKey: .isPrimary)
        try container.encodeIfPresent(contactTypeID, forKey: .contactTypeID)
        try container.encodeIfPresent(dateOfBirth, forKey: .dateOfBirth)
        try container.encodeIfPresent(federalTaxID, forKey: .federalTaxID)
        try container.encodeIfPresent(comment, forKey: .comment)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(license, forKey: .license)
        try container.encodeIfPresent(vehicle, forKey: .vehicle)
        try container.encodeIfPresent(imageID, forKey: .imageID)
        try container.encodeIfPresent(isShowOnBill, forKey: .isShowOnBill)
        try container.encodeIfPresent(employer, forKey: .employer)
        try container.encodeIfPresent(applicantType, forKey: .applicantType)
        try container.encodeIfPresent(createDate, forKey: .createDate)
        try container.encodeIfPresent(createUserID, forKey: .createUserID)
        try container.encodeIfPresent(updateDate, forKey: .updateDate)
        try container.encodeIfPresent(annualIncome, forKey: .annualIncome)
        try container.encodeIfPresent(updateUserID, forKey: .updateUserID)
        try container.encodeIfPresent(parentID, forKey: .parentID)
        try container.encodeIfPresent(parentType, forKey: .parentType)
        try container.encode(phoneNumbers, forKey: .phoneNumbers)
    }
}

/*
 
 Field Options:
 Addresses,AnnualIncome,ApplicantType,Comment,ContactID,ContactType,ContactTypeID,CreateDate,CreateUserID,DateOfBirth,Email,Employer,EncryptedFederalTaxID,FederalTaxID,FirstName,Image,ImageID,InListItemMode,IsActive,IsPrimary,IsShowOnBill,LastName,License,MaskSSN,MetaTag,MiddleName,Owner,OwnerProspect,ParentID,ParentType,PhoneNumbers,Prospect,Tenant,UpdateDate,UpdateUserID,UserDefinedValues,Vehicle,Vendor
 
 Embed Options:
 Addresses,AnnualIncome,ApplicantType,Comment,ContactID,ContactType,ContactTypeID,CreateDate,CreateUserID,DateOfBirth,Email,Employer,EncryptedFederalTaxID,FederalTaxID,FirstName,Image,ImageID,InListItemMode,IsActive,IsPrimary,IsShowOnBill,LastName,License,MaskSSN,MetaTag,MiddleName,Owner,OwnerProspect,ParentID,ParentType,PhoneNumbers,Prospect,Tenant,UpdateDate,UpdateUserID,UserDefinedValues,Vehicle,Vendor
 
 Best Endpoint: /Contacts?embeds=Addresses,ContactType,PhoneNumbers,PhoneNumbers.PhoneNumberType,Tenant,Tenant.Leases,Tenant.Leases.Unit&filters=Tenant.PropertyID,eq,1%2C3%2C8%2C12&fields=Addresses,AnnualIncome,ApplicantType,ContactID,ContactType,CreateDate,DateOfBirth,Email,FirstName,IsActive,IsPrimary,IsShowOnBill,LastName,ParentID,PhoneNumbers,Tenant,UpdateDate,UserDefinedValues,Vehicle
 
 
 
 */
