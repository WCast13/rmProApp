//
//  GetTenantDetailRequest.swift
//  rmProApp
//

import Foundation

struct GetTenantDetailRequest: RMRequest {
    typealias Response = RMTenant

    let tenantID: String
    let embeds: [TenantEmbeds]
    let fields: [TenantFields]

    init(tenantID: String, embeds: [TenantEmbeds] = [], fields: [TenantFields] = []) {
        self.tenantID = tenantID
        self.embeds = embeds
        self.fields = fields
    }

    var path: String { "Tenants/\(tenantID)" }

    var queryItems: [URLQueryItem] {
        [
            RMQuery.embeds(embeds),
            RMQuery.fields(fields)
        ].compactMap { $0 }
    }
}
