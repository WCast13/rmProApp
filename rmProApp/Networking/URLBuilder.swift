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
    
    let baseURL = "https://trieq.api.rentmanager.com/"
    
    // MARK: Create URL Function
    
    func createURL(endpoint: APIEndpoint, filters: [(key: FilterField, comparison: FilterTest, value: String)]? = nil, embeds: [Embed]? = nil, orderingOptions: [OrderingOptions]? = nil, fields: [Field]? = nil, pageSize: Int? = nil, pageNumber: Int? = nil) -> URL? {
        
        var urlComponents = URLComponents(string: baseURL + endpoint.rawValue)
        var queryItems = [URLQueryItem]()
        
        if let filters = filters {
            let filtersString = filters.map { "\($0.key),\($0.comparison),\($0.value)" }.joined(separator: ";")
            queryItems.append(URLQueryItem(name: "filters", value: filtersString))
        }
        
        if let embeds = embeds {
            let embedsString = embeds.map { $0.rawValue }.joined(separator: ",")
            queryItems.append(URLQueryItem(name: "embeds", value: embedsString))
        }
        
        if let orderingOptions = orderingOptions {
            let optionsString = orderingOptions.map { $0.rawValue }.joined(separator: ",")
            queryItems.append(URLQueryItem(name: "orderingOptions", value: optionsString))
        }
        
        if let fields = fields {
            let fieldsString = fields.map { $0.rawValue}.joined(separator: ",")
            queryItems.append(URLQueryItem(name: "fields", value: fieldsString))
        }
        
        if let pageSize = pageSize {
            queryItems.append(URLQueryItem(name: "PageSize", value: "\(pageSize)"))
        }
        
        if let pageNumber = pageNumber {
            queryItems.append(URLQueryItem(name: "PageNumber", value: "\(pageNumber)"))
        }
        
        urlComponents?.queryItems = queryItems
        
        return urlComponents?.url
    }
}

// TODO: ENUMS- ADD MORE CASES
enum APIEndpoint: String {
    case banks = "Banks"
    case bills = "Bills"
    case chargeTypes = "Charge Types"
    case charges = "Charges"
    case checks = "Checks"
    case contact = "Contact"
    case emails = "Emails"
    case history = "History"
    case journals = "Journals"
    case lease = "Lease"
    case loans = "Loans"
    case notes = "Notes"
    case owners = "Owners"
    case payments = "Payments"
    case properties = "Properties"
    case prospects = "Prospects"
    case reconciliations = "Reconciliations"
    case recurringBills = "Recurring Bills"
    case recurringCharges = "Recurring Charges"
    case screenings = "Screenings"
    case tenants = "Tenants"
    case units = "Units"
    case vendors = "Vendors"
}

enum FilterField: String {
    case contactIsActive = "Tenant.Property.IsActive"
    case unitIsActive = "Property.IsActive"
    // Add other filters as needed
}

enum FilterTest: String {
    case equal = "eq"
    case notEqual = "ne"
    case startsWith = "sw"
    case endsWith = "ew"
    case contains = "ct"
    case lessThan = "lt"
    case greaterThan = "gt"
    case between = "bt"
}

enum Embed: String {
    case addresses = "Addresses"
    case contactType = "ContactType"
    case phoneNumbers = "PhoneNumbers"
    // Add other embeds as needed
}

enum Field: String {
    case contactID = "ContactID"
    case firstName = "FirstName"
    case lastName = "LastName"
    case email = "Email"
    // Add other fields as needed
}

enum OrderingOptions: String {
    case unitID = "UnitID"
    
}
