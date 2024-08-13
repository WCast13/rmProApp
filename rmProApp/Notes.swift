//
//  Notes.swift
//  rmProApp
//
//  Created by William Castellano on 8/8/24.
//

import Foundation

// MARK: From ChatGPT- Intergration of RentManager API Client Class
// TODO: Rebuild NetworkManager to be more robust/specific

class RentManagerAPIClient {
    static let shared = RentManagerAPIClient()
    
    private init() {}
    
    private let baseURL = "https://trieq.api.rentmanager.com/"
    
    // MARK: Create URL Function
    
    private func createURL(endpoint: String, filters: [Filter : String]? = nil, embeds: [Embed]? = nil, orderingOptions: [Options]? = nil, fields: [Field]? = nil) -> URL? {
        
        var urlComponets = URLComponents(string: baseURL + endpoint)
        
        var queryItems = [URLQueryItem]()
        
        if let filters = filters {
            let filtersString = filters.map { "\($0.key.rawValue) = \($0.value)" }.joined(separator: ",")
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
            let fieldsString = fields.map { $0.rawValue }.joined(separator: ",")
            queryItems.append(URLQueryItem(name: "fields", value: fieldsString))
        }
        
        urlComponets?.queryItems = queryItems
        
        return urlComponets?.url
    }
    
    // MARK: API CAll- Request Function
    
    func request<T: Decodable>(endpoint: String, responseType: T.Type, filters: [Filter : String]? = nil, embeds: [Embed]? = nil, orderingOptions: [Options]? = nil, fields: [Field]? = nil) async -> T? {
        
        guard let currentKey = TokenManager.shared.token else {
            print("Token is nil")
            return nil
        }
        
        let headers = [
            "X-RM12Api-ApiToken": currentKey, "Content-Type": "application/json"
        ]
        
        guard let url = createURL(endpoint: endpoint, filters: filters, embeds: embeds, orderingOptions: orderingOptions, fields: fields) else {
            print("Invalid URL")
            return nil
        }
        
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        request.allHTTPHeaderFields = headers
        request.httpMethod = "GET"
        
        print(request.allHTTPHeaderFields!)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let decodedData = try JSONDecoder().decode(responseType, from: data)
                return decodedData
            } else {
                print("Failed to fetch data: \(response)")
                return nil
            }
        } catch {
            print("Failed to decode JSON: \(error)")
            return nil
        }
    }
}

// TODO: ENUMS- ADD MORE CASES
enum Filter: String {
    case contactIsActive = "Tenant.Property.IsActive"
    case unitIsActive = "Property.IsActive"
    // Add other filters as needed
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

enum Options: String {
    case unitID = "UnitID"
}



























































// MARK: API Endpoint Notes

/*
 Sites API call- Active Sites
 
 /Units?filters=Property.IsActive,eq,true
 
 /Units?embeds=Addresses,CreateUser,CurrentOccupancyStatus,CurrentOccupants,History,History.HistoryAttachments,HistoryNotes,HistorySystemNotes,Property&filters=Property.IsActive,eq,true&fields=Name
 
 /Units?embeds=Addresses,Leases,Leases.LeaseRenewals,Leases.Tenant,Leases.Tenant.SecurityDepositHeld&filters=Property.IsActive,eq,true&fields=Addresses,Leases
 
 /Units?embeds=Addresses,Leases,Leases.LeaseRenewals,Leases.Tenant,Leases.Tenant.SecurityDepositHeld&filters=Property.IsActive,eq,true&fields=Addresses,Leases,Name
 
 /Units?embeds=Addresses,CurrentOccupancyStatus,CurrentOccupants,Leases,PrimaryAddress,UserDefinedValues&filters=Property.IsActive,eq,true;SquareFootage,eq,44&fields=Addresses,CurrentOccupancyStatus,CurrentOccupants,IsVacant,Leases,Name,PropertyID,UnitID,UserDefinedValues
 
 /Units?embeds=Addresses,CurrentOccupancyStatus,CurrentOccupants,Leases,PrimaryAddress,PrimaryAddress.AddressType,UserDefinedValues&filters=Property.IsActive,eq,true&fields=Addresses,CurrentOccupancyStatus,CurrentOccupants,IsVacant,Leases,Name,PrimaryAddress,PropertyID,UnitID,UserDefinedValues
 
 GET Contacts?filters={filters}&embeds={embeds}&orderingOptions={orderingOptions}&fields={fields}
 
 /Contacts?embeds=Addresses,ContactType,PhoneNumbers,PhoneNumbers.PhoneNumberType,Tenant,Tenant.Addresses,Tenant.Leases,Tenant.Leases.Property,Tenant.Leases.Unit,Tenant.Leases.Unit.Property,Tenant.Property,UserDefinedValues&filters=Tenant.Property.IsActive,eq,true&fields=Addresses,AnnualIncome,ApplicantType,ContactID,ContactType,ContactTypeID,CreateDate,CreateUserID,DateOfBirth,Email,FirstName,IsActive,IsPrimary,IsShowOnBill,LastName,MiddleName,PhoneNumbers,Tenant,UpdateDate,UserDefinedValues,Vehicle
 
 /Contacts/342?embeds=Addresses,ContactType,PhoneNumbers,PhoneNumbers.PhoneNumberType,Tenant,Tenant.Addresses,Tenant.Leases,Tenant.Leases.Property,Tenant.Leases.Unit,Tenant.Leases.Unit.Property,Tenant.Property,UserDefinedValues&filters=Tenant.Property.IsActive,eq,true&fields=Addresses,AnnualIncome,ApplicantType,ContactID,ContactType,ContactTypeID,CreateDate,CreateUserID,DateOfBirth,Email,FirstName,IsActive,IsPrimary,IsShowOnBill,LastName,MiddleName,PhoneNumbers,Tenant,UpdateDate,UserDefinedValues,Vehicle
 */
