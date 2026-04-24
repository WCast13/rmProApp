//
//  GetTenantsRequest.swift
//  rmProApp
//

import Foundation

struct GetTenantsRequest: RMRequest {
    typealias Response = [RMTenant]

    let embeds: [TenantEmbeds]
    let fields: [TenantFields]
    let filters: [RMFilter]
    let pageSize: Int?

    init(
        embeds: [TenantEmbeds] = [],
        fields: [TenantFields] = [],
        filters: [RMFilter] = [RMFilter(key: "Status", operation: "ne", value: "Past")],
        pageSize: Int? = nil
    ) {
        self.embeds = embeds
        self.fields = fields
        self.filters = filters
        self.pageSize = pageSize
    }

    var path: String { "Tenants" }

    var queryItems: [URLQueryItem] {
        [
            RMQuery.embeds(embeds),
            RMQuery.fields(fields),
            RMQuery.filters(filters),
            RMQuery.pageSize(pageSize)
        ].compactMap { $0 }
    }
}
