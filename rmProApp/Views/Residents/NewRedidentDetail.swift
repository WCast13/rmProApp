//
//  ResidentDetailView.swift
//  rmProApp
//
//  Created by William Castellano on 4/3/25.
//  Redesigned by Grok on 6/4/25.
//

import SwiftUI

struct NewResidentDetailView: View {
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var tenantDataManager: TenantDataManager
    @State var tenant: WCLeaseTenant
    @State private var isLoadingTransactions = false
    
    var body: some View {
        ScrollView {
            
            Button("Create GVH Unit") {
                Task {
                    try? await createNewUnit(name: "Test Unit - GVH")
                }
            }
            
            
            VStack(spacing: 20) {
                // Header with Quick Actions
                HeaderView(tenant: tenant)
                
                // Information Section
                InformationCard(tenant: tenant)
                
                // Addresses Section
                AddressesCard(tenant: tenant)
                
                // Contact Details Section
                ContactsCard(contacts: tenant.contacts ?? [])
                
                // Lease Details Section
                LeaseCard(leases: tenant.allLeases ?? [], recurringCharges: tenant.allLeases?.first?.unit?.unitType?.recurringCharges ?? [])
                
                // Transactions Section
                TransactionsCard(transactions: tenant.transactions ?? [], isLoading: isLoadingTransactions)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Resident Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                isLoadingTransactions = true
                await processTenantTransactions()
                isLoadingTransactions = false
            }
        }
    }
    
    func processTenantTransactions() async {
        let transactionData = await tenantDataManager.fetchSingleTenantTransactions(tenantID: String(tenant.tenantID ?? 0))
        
        if let charges = transactionData?.charges, !charges.isEmpty,
           let payments = transactionData?.payments, !payments.isEmpty,
           let paymentReversals = transactionData?.paymentReversals {
            tenant.charges = charges
            tenant.payments = payments
            tenant.paymentReversals = paymentReversals
            tenant.transactions = await TenantTransactionsManager.shared.processTransactions(tenant: tenant)
        }
    }
    
    func createLoan() async {
        // Create Site
        var newUnit: CreatedUnitResponse? = nil
        
        Task {
            newUnit = try? await createNewUnit(name: "_XXX Test - Loan\(Int.random(in: 1...305))")
        }
        
        // Auto Update
        let reference = "10203" // Need last loan reference number and increase by 1- SwiftData
        
        // Doesnt Change
        let propertyID: Int = 8 // Always the same
        let accountID: Int = tenant.accountGroupMasterTenantID ?? 0
        let paymentDay: Int = 15
        let startingPaymentNumber: Int = 0
        let interestMethod: String = "Straight"
        let principalChargeTypeID: Int = 16
        let interestChargeTypeID: Int = 38
        let prepayChargeTypeID: Int = 16
        let paymentNumber: Int = 1
        let unitID = newUnit?.unitID ?? 0
        
        
        // Ask in Form
        let originalPrincipal: Double = 137488.23
        let downPayment: Double = 130000.00
        let term: Int = 300
        let paymentAmount: Double = 458.30
        let interestRate: Double = 6.045
        

        // Format Date - From Picker Input
        let closeDate: Date = Calendar.current.date(byAdding: .year, value: -100, to: Date())!
        let loanDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
        let paymentStartDate: Date = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
        
        
        
        
        
        
        
        /*
         {
             "Reference": "10203", // Create
             "PropertyID": 8,
             "AccountID": 2671, // Lookup from Tenant
             "OriginalPrincipal": 137488.23,
             "DownPayment": 130000.00,
             "CloseDate": "1234-01-10T00:00:00",
             "LoanDate": "1934-01-10T00:00:00",
             "PaymentStartDate": "2024-02-15T00:00:00",
             "PaymentDay": 15,
             "StartingPaymentNumber": 0,
             "Term": 300,
             "InterestMethod": "Straight",
             "UnitID": 1337,
             "PrincipalChargeTypeID": 16,
             "InterestChargeTypeID": 38,
             "PrepayChargeTypeID": 16,
                 "LoanRates": [
                 {
                     "PaymentAmount": 928.33,
                     "PaymentNumber": 1,
                     "InterestRate": 6.5000
                 }
             ]
         }
         */
        
        
    }

    func createNewUnit(name: String = "Test - Loan\(Int.random(in: 1...305))") async throws -> CreatedUnitResponse {
        // Create request payload using the struct
        let requestBody = CreateUnitRequest(
            propertyID: 8,
            name: "_T- Loan \(Int.random(in: 1...305))",
            unitTypeID: 6
        )

        // Encode to JSON properly
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(requestBody)

        // Configure request
        guard let url = URL(string: "https://trieq.api.rentmanager.com/Units") else {
            print("invariant: invalid URL")
            throw UnitCreationError.invalidURL
        }

        let apiKey = TokenManager.shared.token ?? ""
        print("API: Key: \(apiKey)")

        var request = URLRequest(url: url, timeoutInterval: 30.0)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "X-RM12Api-ApiToken")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        // Perform request
        let (data, response) = try await URLSession.shared.data(for: request)

        print("Response: \(String(decoding: data, as: UTF8.self))")

        // Decode response
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let createdUnit = try decoder.decode(CreatedUnitResponse.self, from: data)

        print("Created Unit: \(createdUnit)")

        return createdUnit
    }
}

// MARK: - Unit Creation Models
struct CreateUnitRequest: Codable {
    let propertyID: Int
    let name: String
    let unitTypeID: Int

    enum CodingKeys: String, CodingKey {
        case propertyID = "PropertyID"
        case name = "Name"
        case unitTypeID = "UnitTypeID"
    }
}

struct CreatedUnitResponse: Codable {
    let unitID: Int?
    let name: String?
    let propertyID: Int?
    let unitTypeID: Int?

    enum CodingKeys: String, CodingKey {
        case unitID = "UnitID"
        case name = "Name"
        case propertyID = "PropertyID"
        case unitTypeID = "UnitTypeID"
    }
}

enum UnitCreationError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "HTTP error with status code: \(statusCode)"
        }
    }
}
