//
//  Notes.swift
//  rmProApp
//
//  Created by William Castellano on 8/8/24.
//

import Foundation

// MARK: Rent Manager API Client

class RentManagerAPIClient {
    static let shared = RentManagerAPIClient() // Singleton for RM Api Client
    private init() {}
    private let baseURL = "https://trieq.api.rentmanager.com/"
    
    // MARK: Create URL Function
    
    private func createURL(endpoint: APIEndpoint, filters: [(key: FilterField, comparison: FilterTest, value: String)]? = nil, embeds: [Embed]? = nil, orderingOptions: [OrderingOptions]? = nil, fields: [Field]? = nil, pageSize: Int? = nil, pageNumber: Int? = nil) -> URL? {
        
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
    
    // MARK: API CAll- Request Function
    
    func request<T: Decodable>(endpoint: APIEndpoint, responseType: T.Type, filters: [(FilterField, FilterTest, String)]? = nil, embeds: [Embed]? = nil, orderingOptions: [OrderingOptions]? = nil, fields: [Field]? = nil, pageSize: Int? = nil, pageNumber: Int? = nil) async -> T? {
        
        guard let currentKey = TokenManager.shared.token else {
            print("Token is nil")
            return nil
        }
        
        let headers = [
            "X-RM12Api-ApiToken": currentKey, "Content-Type": "application/json"
        ]
        
        guard let url = createURL(endpoint: endpoint, filters: filters, embeds: embeds, orderingOptions: orderingOptions, fields: fields, pageSize: pageSize, pageNumber: pageNumber) else {
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
    
    // MARK: API CAll- Request Function
    
    func requestString<T: Decodable>(urlString: String, responseType: T.Type) async -> T? {
        
        guard let currentKey = TokenManager.shared.token else {
            print("Token is nil")
            return nil
        }
        
        let headers = [
            "X-RM12Api-ApiToken": currentKey, "Content-Type": "application/json"
        ]
        
        guard let url = URL(string: urlString) else {
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






// Mark: ENDPOINT EXAMPLES

/*
 /Tenants?filters=Property.IsActive,eq,true;PropertyID,ne,1&orderingOptions=TenantName
 /Tenants/44?filters=Property.IsActive,eq,true;PropertyID,ne,1&orderingOptions=TenantName
 /Tenants/44?embeds=AccountStatements,Addresses,CashPayUser,Contacts.Addresses,Contacts.ContactType,Contacts.Image,Contacts.PhoneNumbers,IncomeVerifications,Leases.Property,Leases.Property.Addresses,Leases.LeaseRenewals.LeaseTerm,Leases.LeaseRenewals,Leases.RetailSales,Leases,Leases.Unit,Leases.Unit.Addresses,Leases.Unit.Property,Loans,Property,Prospect,RecurringCharges,RecurringChargeSummaries,Transactions&filters=Property.IsActive,eq,true;PropertyID,ne,1&orderingOptions=TenantName&fields=AccountType,Addresses,Appointments,Contacts,CreateUser,CreateUserID,History,Leases,Loans,Name,Property,PropertyID,RecurringCharges,TenantID
 
 /Contacts?filters=IsActive,eq,true;Tenant.Property.IsActive,eq,true
 
 /Contacts/44?embeds=Addresses,ContactType,PhoneNumbers,Prospect.Addresses,Prospect.Property,Tenant,Tenant.Addresses,Tenant.Leases,Tenant.Leases.Property,Tenant.Leases.Unit,Tenant.Leases.Unit.Property,Tenant.Property&filters=IsActive,eq,true;Tenant.Property.IsActive,eq,true&fields=Addresses,AnnualIncome,ApplicantType,ContactID,ContactType,CreateDate,CreateUserID,DateOfBirth,Email,FirstName,IsActive,IsPrimary,IsShowOnBill,LastName,License,MiddleName,PhoneNumbers,Tenant
 
 /Contacts?embeds=Addresses,ContactType,PhoneNumbers,Prospect.Addresses,Prospect.Property,Tenant,Tenant.Addresses,Tenant.Leases,Tenant.Leases.Property,Tenant.Leases.Unit,Tenant.Leases.Unit.Property,Tenant.Property&filters=IsActive,eq,true;Tenant.Property.IsActive,eq,true&fields=Addresses,AnnualIncome,ApplicantType,ContactID,ContactType,CreateDate,CreateUserID,DateOfBirth,Email,FirstName,IsActive,IsPrimary,IsShowOnBill,LastName,License,MiddleName,PhoneNumbers,Tenant&PageSize=2500&PageNumber=1
 
 /Units?embeds=Addresses,CurrentOccupancyStatus,CurrentOccupants,Leases,PrimaryAddress,UserDefinedValues&filters=Property.IsActive,eq,true;SquareFootage,eq,44&fields=Addresses,CurrentOccupancyStatus,CurrentOccupants,IsVacant,Leases,Name,PropertyID,UnitID,UserDefinedValues
 
 /Units?embeds=Addresses,CurrentOccupancyStatus,CurrentOccupants,Leases,PrimaryAddress,PrimaryAddress.AddressType,UserDefinedValues&filters=Property.IsActive,eq,true&fields=Addresses,CurrentOccupancyStatus,CurrentOccupants,IsVacant,Leases,Name,PrimaryAddress,PropertyID,UnitID,UserDefinedValues
 
 /Prospects?embeds=Addresses,Appointments,Balance,Bills,Charges,Contacts,Contacts.Addresses,Contacts.ContactType,Contacts.PhoneNumbers,Contacts.PhoneNumbers.PhoneNumberType,Contacts.UserDefinedValues,CreateUser,History,PaymentReversals,Payments,PrimaryContact,PrimaryContact.ContactType,PrimaryContact.PhoneNumbers,Property,Property.Addresses,Screenings,TenantColor,Transactions&filters=ProspectStatus,eq,Prospect&fields=Addresses,Amenities,ApplicationDate,Charges,CreateDate,CreateUser,CreateUserID,FirstName,LastName,Name,Payments,Property,PropertyID,ProspectStatus,TenantColor,TenantColorID,Transactions,UpdateUser,UpdateUserID,UserDefinedValues&PageSize=2500&PageNumber=1
 
 /Prospects/1784?embeds=Addresses,Appointments,Balance,Bills,Charges,Contacts,Contacts.Addresses,Contacts.ContactType,Contacts.PhoneNumbers,Contacts.PhoneNumbers.PhoneNumberType,Contacts.UserDefinedValues,CreateUser,History,PaymentReversals,Payments,PrimaryContact,PrimaryContact.ContactType,PrimaryContact.PhoneNumbers,Property,Property.Addresses,Screenings,TenantColor,Transactions&filters=ProspectStatus,eq,Prospect&fields=Addresses,Amenities,ApplicationDate,Charges,CreateDate,CreateUser,CreateUserID,FirstName,LastName,Name,Payments,Property,PropertyID,ProspectStatus,TenantColor,TenantColorID,Transactions,UpdateUser,UpdateUserID,UserDefinedValues&PageSize=2500&PageNumber=1
 */
