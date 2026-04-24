//
//  GetUserDefinedFieldsRequest.swift
//  rmProApp
//

import Foundation

struct GetUserDefinedFieldsRequest: RMRequest {
    typealias Response = [RMUserDefinedValue]

    let filters: [RMFilter]

    init(filters: [RMFilter] = []) {
        self.filters = filters
    }

    var path: String { "UserDefinedFields" }

    var queryItems: [URLQueryItem] {
        [RMQuery.filters(filters)].compactMap { $0 }
    }
}
