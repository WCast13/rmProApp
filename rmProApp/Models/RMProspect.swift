//
//  RMProspect.swift
//  rmProApp
//
//  Created by William Castellano on 8/7/24.
//

import Foundation

struct RMProspect: Codable {
    
    let prospectID: Int
    let prospectDisplayID: Int
    let propertyID: Int
    let name: String
    let firstName: String
    let lastName: String
    let webMessage: String
    let colorID: Int
    let tenantColorID: Int
    let prospectColorID: Int
    let comment: String
    let overrideReason: String
    let createDate: String
    let createUserID: Int
    let updateDate: String
    let updateUserID: Int
    let prospectStatus: String
    let prospectLostReasonDescription: String
    let peopleCount: Int
    let moveInDate: String
    let lastStatusChangedDate: String
    let firstContact: String
    let lastContact: String
    let lastHistoryItem: String
    let contact: RMContact
    
}
