//
//  APIEndpointsFilter.swift
//  rmProApp
//
//  Created by William Castellano on 4/9/25.
//

import Foundation

// MARK: ENUMS- ADD MORE CASES
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
    case userDefinedFields = "UserDefinedFields"
    case vendors = "Vendors"
}

// MARK: - Filter Structure
struct RMFilter {
    let key: String
    let operation: String
    let value: String
    
    var queryString: String {
        "\(key),\(operation),\(value)"
    }
}
