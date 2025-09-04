//
//  Notes.swift
//  rmProApp
//
//  Created by William Castellano on 8/8/24.
//

import Foundation

// MARK: Rent Manager API Client

//@MainActor
class RentManagerAPIClient {
    static let shared = RentManagerAPIClient() // Singleton for RM Api Client
    private init() {}
    
    // MARK: API CAll- Request Function
    
    func request<T: Decodable>(url: URL, responseType: T.Type) async -> T? {
        
        guard let currentKey = await TokenManager.shared.token else {
            print("Token is nil")
            return nil
        }
        
        let headers = [
            "X-RM12Api-ApiToken": currentKey, "Content-Type": "application/json"
        ]
        
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        request.allHTTPHeaderFields = headers
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if response is HTTPURLResponse  {
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
    
    // MARK: Generic POST helper (JSON body, raw response)
    func post(url: URL, body: [String: Any]) async -> (success: Bool, data: Data?, statusCode: Int) {
        let token = await TokenManager.shared.token ?? ""
        
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        request.httpMethod = "POST"
        request.addValue(token, forHTTPHeaderField: "X-RM12Api-ApiToken")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            print(request.httpBody ?? "")
        } catch {
            print("❌ POST encode error: \(error.localizedDescription)")
            return (false, nil, -1)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                print("❌ Invalid POST response")
                return (false, data, -1)
            }
                let text = String(data: data, encoding: .utf8) ?? ""
                print("❌ POST failed [\(http.statusCode)]: \(text)")
            return (false, data, http.statusCode)
        } catch {
            print("❌ POST request error: \(error.localizedDescription)")
            return (false, nil, -1)
        }
    }
    
// MARK: Site Type Change- Fire Protection Group to Regular Rent
    
    func fpgToRegularRent(unit: RMUnit) async {
        
        guard let url = URL(string: "https://trieq.api.rentmanager.com/Units/?filters=PropertyID,eq,3&embeds=UnitType,UserDefinedValues&fields=Name,PropertyID,UnitType,UserDefinedValues,UnitID,UnitTypeID") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        request.addValue("\(await TokenManager.shared.token ?? "")", forHTTPHeaderField: "X-RM12Api-ApiToken")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = "POST"
        
        do {
            let body: [String: Any] = [
                "UnitID": unit.unitID ?? 0,
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
}

