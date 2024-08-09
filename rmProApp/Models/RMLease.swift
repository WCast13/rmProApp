//
//  RMLease.swift
//  rmProApp
//
//  Created by William Castellano on 8/9/24.
//

import Foundation

struct RMLease : Codable {
    let leaseID: Int
    let tenantID: Int
    let unitID: Int
    let propertyID: Int
    let isCommercial: Bool
    let moveInDate: String
    let moveOutDate: String?
    let expectedMoveOutDate: Date
    let noticeDate: Date
    let isMoveOutConfirmed: Bool
    let arrivalDate: String
    let departureDate: String
    let isExcludeFromMasterPolicy: Bool
    let sortOrder: Int
    let createDate: String
    let updateDate: String
    let startDate: String
    let endDate: String
    let createUserID: Int
    let updateUserID: Int
    let tenant: RMTennant
    let propertyUnit: String
    let unitProperty: String
}
