//
//  RMRequest.swift
//  rmProApp
//

import Foundation

protocol RMRequest {
    associatedtype Response: Decodable

    var path: String { get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem] { get }
    var body: Data? { get }
}

extension RMRequest {
    var method: HTTPMethod { .get }
    var body: Data? { nil }
}

enum RMQuery {
    static func embeds<E: RawRepresentable>(_ values: [E]) -> URLQueryItem? where E.RawValue == String {
        guard !values.isEmpty else { return nil }
        return URLQueryItem(name: "embeds", value: values.map(\.rawValue).joined(separator: ","))
    }

    static func fields<F: RawRepresentable>(_ values: [F]) -> URLQueryItem? where F.RawValue == String {
        guard !values.isEmpty else { return nil }
        return URLQueryItem(name: "fields", value: values.map(\.rawValue).joined(separator: ","))
    }

    static func filters(_ values: [RMFilter]) -> URLQueryItem? {
        guard !values.isEmpty else { return nil }
        let serialized = values.map { "\($0.key),\($0.operation),\($0.value)" }.joined(separator: ";")
        return URLQueryItem(name: "filters", value: serialized)
    }

    static func pageSize(_ size: Int?) -> URLQueryItem? {
        guard let size else { return nil }
        return URLQueryItem(name: "pageSize", value: String(size))
    }
}
