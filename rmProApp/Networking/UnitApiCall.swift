//
//  UnitApiCall.swift
//  rmProApp
//
//  Created by William Castellano on 8/9/24.
//

import Foundation
import SwiftUI

func getUnitData() async throws {
    
    @StateObject var apiKeyManager = APIKeyManager()
    
    print(apiKeyManager.apiKey ?? "Not loading in Unit Call")
    
    let currentAPIkey = apiKeyManager.loadAPIKey()
    
    print(currentAPIkey ?? "After Loading Call" )
    
    let parameters = "{\"Username\": \"w.castellano\",\n\"Password\": \"Trilogy123\"\n}"
    let postData = parameters.data(using: .utf8)

    var request = URLRequest(url: URL(string: "https://trieq.api.rentmanager.com/Units?embeds=Addresses%2CCurrentOccupancyStatus%2CCurrentOccupants%2CLeases%2CPrimaryAddress%2CPrimaryAddress.AddressType%2CUserDefinedValues&filters=SquareFootage%2Ceq%2C44%3BProperty.IsActive%2Ceq%2Ctrue&fields=Addresses%2CCurrentOccupancyStatus%2CCurrentOccupants%2CIsVacant%2CLeases%2CName%2CPrimaryAddress%2CPropertyID%2CUnitID%2CUserDefinedValues")!,timeoutInterval: Double.infinity)
    
    request.addValue("API KEY FROM APP STORAGE", forHTTPHeaderField: "X-RM12Api-ApiToken")
    
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    request.httpMethod = "GET"
    request.httpBody = postData

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      guard let data = data else {
        print(String(describing: error))
        return
      }
      print(String(data: data, encoding: .utf8)!)
    }

    task.resume()

}




