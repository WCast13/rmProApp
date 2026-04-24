//
//  GetUnitsRequest.swift
//  rmProApp
//

import Foundation

struct GetUnitsRequest: RMRequest {
    typealias Response = [RMUnit]

    let embeds: [UnitEmbedOption]
    let fields: [UnitFieldOption]
    let filters: [RMFilter]
    let pageSize: Int?

    init(
        embeds: [UnitEmbedOption] = [],
        fields: [UnitFieldOption] = [],
        filters: [RMFilter] = [RMFilter(key: "Property.IsActive", operation: "eq", value: "true")],
        pageSize: Int? = nil
    ) {
        self.embeds = embeds
        self.fields = fields
        self.filters = filters
        self.pageSize = pageSize
    }

    var path: String { "Units" }

    var queryItems: [URLQueryItem] {
        [
            RMQuery.embeds(embeds),
            RMQuery.fields(fields),
            RMQuery.filters(filters),
            RMQuery.pageSize(pageSize)
        ].compactMap { $0 }
    }
}
