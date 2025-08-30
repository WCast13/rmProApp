//
//  RMProspect.swift
//  rmProApp
//
//  Created by William Castellano on 8/7/24.
//

import Foundation

struct RMProspect: Codable {
    
    let prospectID: Int?
    let prospectDisplayID: Int?
    let propertyID: Int?
    let name: String?
    let firstName: String?
    let lastName: String?
    let webMessage: String?
    let colorID: Int?
    let tenantColorID: Int?
    let prospectColorID: Int?
    let comment: String?
    let overrideReason: String?
    let createDate: String?
    let createUserID: Int?
    let updateDate: String?
    let updateUserID: Int?
    let prospectStatus: String?
    let prospectLostReasonDescription: String?
    let peopleCount: Int?
    let moveInDate: String?
    let lastStatusChangedDate: String?
    let firstContact: String?
    let lastContact: String?
    let lastHistoryItem: String?
    let contact: RMContact?
    
    enum CodingKeys: String, CodingKey {
        case prospectID = "ProspectID"
        case prospectDisplayID = "ProspectDisplayID"
        case propertyID = "PropertyID"
        case name = "Name"
        case firstName = "FirstName"
        case lastName = "LastName"
        case webMessage = "WebMessage"
        case colorID = "ColorID"
        case tenantColorID = "TenantColorID"
        case prospectColorID = "ProspectColorID"
        case comment = "Comment"
        case overrideReason = "OverrideReason"
        case createDate = "CreateDate"
        case createUserID = "CreateUserID"
        case updateDate = "UpdateDate"
        case updateUserID = "UpdateUserID"
        case prospectStatus = "ProspectStatus"
        case prospectLostReasonDescription = "ProspectLostReasonDescription"
        case peopleCount = "PeopleCount"
        case moveInDate = "MoveInDate"
        case lastStatusChangedDate = "LastStatusChangedDate"
        case firstContact = "FirstContact"
        case lastContact = "LastContact"
        case lastHistoryItem = "LastHistoryItem"
        case contact = "Contact"
    }
}
