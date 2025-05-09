//
//  RMContact.swift
//  rmProApp
//
//  Created by William Castellano on 8/7/24.
//

import Foundation

struct RMContact: Codable, Identifiable, Hashable, Equatable {
    
    static func == (lhs: RMContact, rhs: RMContact) -> Bool {
        lhs.contactID == rhs.contactID
    }
    
    let id = UUID()
    
    let contactID: Int?
    let firstName: String?
    let lastName: String?
    let middleName: String?
    let isActive: Bool?
    let isPrimary: Bool?
    let contactTypeID: Int?
    let dateOfBirth: String?
    let federalTaxID: String?
    let comment: String?
    let email: String?
    let license: String?
    let vehicle: String?
    let imageID: Int?
    let isShowOnBill: Bool?
    let employer: String?
    let applicantType: String?
    let createDate: String?
    let createUserID: Int?
    let updateDate: String?
    let annualIncome: Double?
    let updateUserID: Int?
    let parentID: Int?
    let parentType: String?
    let phoneNumbers: [RMPhoneNumber]
    
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
}

/*
 
 Field Options:
 Addresses,AnnualIncome,ApplicantType,Comment,ContactID,ContactType,ContactTypeID,CreateDate,CreateUserID,DateOfBirth,Email,Employer,EncryptedFederalTaxID,FederalTaxID,FirstName,Image,ImageID,InListItemMode,IsActive,IsPrimary,IsShowOnBill,LastName,License,MaskSSN,MetaTag,MiddleName,Owner,OwnerProspect,ParentID,ParentType,PhoneNumbers,Prospect,Tenant,UpdateDate,UpdateUserID,UserDefinedValues,Vehicle,Vendor
 
 Embed Options:
 Addresses,AnnualIncome,ApplicantType,Comment,ContactID,ContactType,ContactTypeID,CreateDate,CreateUserID,DateOfBirth,Email,Employer,EncryptedFederalTaxID,FederalTaxID,FirstName,Image,ImageID,InListItemMode,IsActive,IsPrimary,IsShowOnBill,LastName,License,MaskSSN,MetaTag,MiddleName,Owner,OwnerProspect,ParentID,ParentType,PhoneNumbers,Prospect,Tenant,UpdateDate,UpdateUserID,UserDefinedValues,Vehicle,Vendor
 
 Best Endpoint: /Contacts?embeds=Addresses,ContactType,PhoneNumbers,PhoneNumbers.PhoneNumberType,Tenant,Tenant.Leases,Tenant.Leases.Unit&filters=Tenant.PropertyID,eq,1%2C3%2C8%2C12&fields=Addresses,AnnualIncome,ApplicantType,ContactID,ContactType,CreateDate,DateOfBirth,Email,FirstName,IsActive,IsPrimary,IsShowOnBill,LastName,ParentID,PhoneNumbers,Tenant,UpdateDate,UserDefinedValues,Vehicle
 
 
 
 */
