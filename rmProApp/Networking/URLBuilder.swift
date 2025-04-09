//
//  URLBuilder.swift
//  rmProApp
//
//  Created by William Castellano on 8/14/24.
//

import Foundation

class URLBuilder {

    static let shared = URLBuilder()
    private init() {}
    
    // MARK: Create URL Function
    func buildURL(endpoint: APIEndpoint, embeds: String? = nil, fields: String? = nil, filters: [RMFilter]? = nil, pageSize: Int? = nil) -> URL? {
        
        let baseURL = "https://trieq.api.rentmanager.com/"
        var urlComponents = URLComponents(string: baseURL + endpoint.rawValue)!
        var queryItems: [URLQueryItem] = []
        
        if let embeds = embeds {
            queryItems.append(URLQueryItem(name: "embeds", value: embeds))
        }
        
        if let fields = fields {
            queryItems.append(URLQueryItem(name: "fields", value: fields))
        }
        
        if let filters = filters {
            let filterString = filters.map { "\($0.key),\($0.operation),\($0.value)" }.joined(separator: ";")
            queryItems.append(URLQueryItem(name: "filters", value: filterString))
        }
        
        if let pageSize = pageSize {
            queryItems.append(URLQueryItem(name: "pageSize", value: String(pageSize)))
        }
        
        urlComponents.queryItems = queryItems
        
        return urlComponents.url
    }
 }
