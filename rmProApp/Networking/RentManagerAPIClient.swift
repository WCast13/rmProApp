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

    // MARK: API CAll- Request Function
    
    func request<T: Decodable>(endpoint: APIEndpoint? = nil, responseType: T.Type, filters: [(FilterField, FilterTest, String)]? = nil, embeds: [Embed]? = nil, orderingOptions: [OrderingOptions]? = nil, fields: [Field]? = nil, pageSize: Int? = nil, pageNumber: Int? = nil, urlString: String? = nil) async -> T? {
        
        guard let currentKey = TokenManager.shared.token else {
            print("Token is nil")
            return nil
        }
        
        let headers = [
            "X-RM12Api-ApiToken": currentKey, "Content-Type": "application/json"
        ]
        
        // Determine the URL based on whether urlString is provided
        let url: URL?
        
        if let urlString = urlString {
            url = URL(string: urlString)
        } else {
            url = URLBuilder.shared.createURL(
                endpoint: endpoint!,
                filters: filters,
                embeds: embeds,
                orderingOptions: orderingOptions,
                fields: fields,
                pageSize: pageSize,
                pageNumber: pageNumber
            )
        }
        
        // Check if the URL is valid
        guard url != nil else {
            print("Invalid URL")
            return nil
        }
        
        var request = URLRequest(url: url!, timeoutInterval: Double.infinity)
        request.allHTTPHeaderFields = headers
        request.httpMethod = "GET"
        
        print(request.allHTTPHeaderFields!)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse  {
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
    
    // MARK: Site Type Change- Fire Protection Group to Regular Rent
    
    func fpgToRegularRent(unit: RMUnit) async {
        
        guard let url = URL(string: "https://trieq.api.rentmanager.com/Units/?filters=PropertyID,eq,3&embeds=UnitType,UserDefinedValues&fields=Name,PropertyID,UnitType,UserDefinedValues,UnitID,UnitTypeID") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        request.addValue("\(TokenManager.shared.token ?? "")", forHTTPHeaderField: "X-RM12Api-ApiToken")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = "POST"
        
        do {
            let body: [String: Any] = [
                "UnitID": unit.UnitID ?? 0,
                "PropertyID": 3,
                "UnitTypeID": 3
            ]
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("Error encoding httpBody: \(error.localizedDescription)")
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Status Code: \(httpResponse.statusCode)")
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response: \(responseString)")
            }
        } catch {
            print("Request failed with error: \(error.localizedDescription)")
        }
    }
    
    // MARK: API CAll- Request Function
   /*
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
    */
    
    
    
    
    
}


enum URLStringEndPoints: String {

    case contactAllData = "https://trieq.api.rentmanager.com/Contacts?embeds=Addresses,ContactType,PhoneNumbers,PhoneNumbers.PhoneNumberType,Tenant,Tenant.Leases,Tenant.Leases.Unit&filters=Tenant.Property.IsActive,eq,true&fields=Addresses,AnnualIncome,ApplicantType,ContactID,ContactType,CreateDate,DateOfBirth,Email,FirstName,IsActive,IsPrimary,IsShowOnBill,LastName,ParentID,PhoneNumbers,Tenant,UpdateDate,UserDefinedValues,Vehicle"
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
