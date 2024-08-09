//
//  AuthenticateRM.swift
//  rmProApp
//
//  Created by William Castellano on 8/7/24.
//

import Foundation
import SwiftUI

func fetchAPIkey() {
    @AppStorage("apiKey") var apiKey: String = ""
    
    let parameters = "{\"Username\": \"w.castellano\",\n\"Password\": \"Trilogy123\"\n}"
    let postData = parameters.data(using: .utf8)
    
    var request = URLRequest(url: URL(string: "https://trieq.api.rentmanager.com/Authentication/AuthorizeUser/")!,timeoutInterval: Double.infinity)
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    request.httpMethod = "POST"
    request.httpBody = postData
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data else {
            print(String(describing: error))
            return
        }
        print(String(data: data, encoding: .utf8)!)
        let newAPIString = String(data: data, encoding: .utf8)!
        apiKey = newAPIString
    }
    
    task.resume()
}
