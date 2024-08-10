//
//  UnitApiCall.swift
//  rmProApp
//
//  Created by William Castellano on 8/9/24.
//

import Foundation
import Combine

class NetworkManager {
    private var tokenManager: TokenManager
    
    init(tokenManager: TokenManager) {
        self.tokenManager = tokenManager
    }
    
    func makeAuthenticatedRequest() {
        guard let token = tokenManager.token else {
            print("No Token Available")
            return
        }
        
        let parameters = "{\"Username\": \"w.castellano\",\n\"Password\": \"Trilogy123\"\n}"
        let postData = parameters.data(using: .utf8)
        
        var request = URLRequest(url: URL(string: "https://trieq.api.rentmanager.com/Units?embeds=Addresses%2CCurrentOccupancyStatus%2CCurrentOccupants%2CLeases%2CPrimaryAddress%2CPrimaryAddress.AddressType%2CUserDefinedValues&filters=SquareFootage%2Ceq%2C44%3BProperty.IsActive%2Ceq%2Ctrue&fields=Addresses%2CCurrentOccupancyStatus%2CCurrentOccupants%2CIsVacant%2CLeases%2CName%2CPrimaryAddress%2CPropertyID%2CUnitID%2CUserDefinedValues")!)
        request.httpMethod = "GET"
        request.addValue(token, forHTTPHeaderField: "X-RM12Api-ApiToken")
//        request.httpBody = postData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
//            guard let response = response as? HTTPURLResponse, response.statusCode > 200, response.statusCode < 300 else {
//                print("Invalid URL")
//            }
            
            do {
                let decoder = JSONDecoder()
//                decoder.keyDecodingStrategy = 
            }
            
            
            
            
            print("This is working")
        }
        task.resume()
    }
}



