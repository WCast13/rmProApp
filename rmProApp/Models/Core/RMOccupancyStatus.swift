//
//  RMOccupancyStatus.swift
//  rmProApp
//
//  Created by William Castellano on 8/9/24.
//

import Foundation

struct RMOccupancyStatus : Codable {
    let unitID: Int?
    let tenantID: Int?
    let prospectID: Int?
    let unitStatusID: Int?
    let occupancyType: String?
    let startDate: String?
    let endDate: String?
    let expectedMoveOutDate: String?
    let noticeDate: String?
    
    enum CodingKeys: String, CodingKey {
        case unitID = "UnitID"
        case tenantID = "TenantID"
        case prospectID = "ProspectID"
        case unitStatusID = "UnitStatusID"
        case occupancyType = "OccupancyType"
        case startDate = "StartDate"
        case endDate = "EndDate"
        case expectedMoveOutDate = "ExpectedMoveOutDate"
        case noticeDate = "NoticeDate"
    }
}
