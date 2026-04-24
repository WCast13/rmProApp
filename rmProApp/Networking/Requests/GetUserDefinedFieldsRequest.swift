//
//  GetUserDefinedFieldsRequest.swift
//  rmProApp
//

import Foundation

struct GetUserDefinedFieldsRequest: RMRequest {
    typealias Response = [RMUserDefinedValue]

    var path: String { "UserDefinedFields" }
    var queryItems: [URLQueryItem] { [] }
}
