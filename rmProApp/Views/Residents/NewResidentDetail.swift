//
//  ResidentDetailView.swift
//  rmProApp
//
//  Created by William Castellano on 4/3/25.
//  Redesigned by Grok on 6/4/25.
//

import SwiftUI
import Foundation

struct NewResidentDetailView: View {
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var tenantDataManager: TenantDataManager
    @State var tenant: WCLeaseTenant
    @State private var isLoadingTransactions = false
    
    // Loan form state variables
    @State private var showLoanForm = false
    @State private var loanName = "Test Name"
    @State private var originalPrincipal = 137488.23
    @State private var downPayment = 130000.00
    @State private var term = 300
    @State private var paymentAmount = 458.30
    @State private var interestRate = 6.045
    @State private var closeDate = Date()
    @State private var loanDate = Date()
    @State private var paymentStartDate = Date()
    
    var body: some View {
        ScrollView {
            
            Button("Create GVH Unit") {
                showLoanForm = true
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
        .sheet(isPresented: $showLoanForm) {
            LoanFormSheet(
                unitName: $loanName,
                originalPrincipal: $originalPrincipal,
                downPayment: $downPayment,
                term: $term,
                paymentAmount: $paymentAmount,
                interestRate: $interestRate,
                closeDate: $closeDate,
                loanDate: $loanDate,
                paymentStartDate: $paymentStartDate,
                onSubmit: { Task {
                    try await createLoan()
                }
                } // Call create loan function
            )
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
    
    func createLoan() async throws -> CreatedLoanResponse {
        // Create Site and await the result before using unitID
        let newUnit: CreatedUnitResponse? = try? await cNewUnit(name: "_XXX Test - Loan\(Int.random(in: 1...305))")
        
        /*
         {
                    "TenantID": 838,
                    "UnitID": 1346,
                    // "PropertyID": 12,
                    "MoveInDate": "1941-12-06T00:00:00",
                    "ActiveLeaseRenewal": {}
        }
         */
       
        
        
        // TODO: CREATE LEASE
        
        // Auto Update
//        let reference = "\(Int.random(in: 1000...3500))" // Need last loan reference number and increase by 1- SwiftData
//        // Doesnt Change
//        let accountID: Int = tenant.accountGroupMasterTenantID ?? 0
//        let unitID = newUnit?.unitID ?? 0
        
        // Ask in Form
//        let originalPrincipal: Double = originalPrincipal
//        let downPayment: Double = downPayment
//        let term: Int = term
//        let paymentAmount: Double = paymentAmount
//        let interestRate: Double = interestRate
        
        // Format Date - From Picker Input
        // If you need a short user-facing string:
        let closeDateShort = closeDate.formatted(date: .numeric, time: .omitted)
        let loanDateShort = loanDate.formatted(date: .numeric, time: .omitted)
        let paymentStartDateShort = paymentStartDate.formatted(date: .numeric, time: .omitted)
        
        // If you need API-friendly ISO-like strings with zeroed time (e.g., 2025-10-24T00:00:00)
        //        let isoDateOnly = Date.FormatStyle().year().month().day().format
        //        let closeDateString = "\(isoDateOnly(closeDate))T00:00:00"
        //        let loanDateString = "\(isoDateOnly(loanDate))T00:00:00"
        //        let paymentStartDateString = "\(isoDateOnly(paymentStartDate))T00:00:00"
        
        // Debug prints (remove if not needed)
        print("Close (short): \(closeDateShort)")
        print("Loan (short): \(loanDateShort)")
        print("Payment Start (short): \(paymentStartDateShort)")
        
        let loanRate = LoanRate(
            paymentAmount: paymentAmount,
            paymentNumber: 1,
            interestRate: interestRate
        )
        
        let requestBody = CreateLoanRequest(
            reference: "\(Int.random(in: 1000...3500))",
            propertyID: 8,
            accountID: tenant.accountGroupMasterTenantID ?? 0,
            originalPrincipal: originalPrincipal,
            downPayment: downPayment,
            closeDate: closeDateShort,
            loanDate: loanDateShort,
            paymentStartDate: paymentStartDateShort,
            paymentDay: 15,
            startingPaymentNumber: 0,
            term: term,
            interestMethod: "Straight",
            unitID: newUnit?.unitID ?? 0,
            principalChargeTypeID: 16,
            interestChargeTypeID: 38,
            prepayChargeTypeID: 16,
            loanRates: [ loanRate ]
        )
        
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let jsonData = try encoder.encode(requestBody)
        
        // Debug: Print JSON
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print("Request JSON: \(jsonString)")
        }
        
        // Configure request
        let urlString = "https://trieq.api.rentmanager.com/Loans"
        
        guard let url = URL(string: urlString) else {
            throw LoanCreationError.invalidURL
        }
        
        let apiKey = TokenManager.shared.token ?? ""
        
        var request = URLRequest(url: url, timeoutInterval: 30.0)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "X-RM12Api-ApiToken")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Perform request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        print("Response: \(String(decoding: data, as: UTF8.self))")
        
        // Validate HTTP response
        guard let httpResponse = response as? HTTPURLResponse else { fatalError("Invalid response") }
        
        // Decode response
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let createdLoan = try? decoder.decode(CreatedLoanResponse.self, from: data)
        
        print("Created Loan: \(createdLoan!)")
        
        return createdLoan!
        
        
        
    }
    
    func cNewUnit(name: String = "Test - Loan\(Int.random(in: 1...305))") async throws -> CreatedUnitResponse {
        
        guard let url = URL(string: "https://trieq.api.rentmanager.com/Units") else {
            print("invariant: invalid URL")
            throw UnitCreationError.invalidURL
        }

              let body: [String: Any] = [
                  "PropertyID": 8,
                  "Name": "_T- Loan \(Int.random(in: 1...305))",
                  "UnitTypeID": 6
              ]

            let result = await RentManagerAPIClient.shared.postRequest(url: url, body: body)

              guard result.success, let data = result.data else {
                  throw UnitCreationError.httpError(statusCode: result.statusCode)
              }

              let decoder = JSONDecoder()
              let createdUnit = try decoder.decode(CreatedUnitResponse.self, from: data)

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

// MARK: - Loan Creation Models
//struct CreateLoanRequest: Codable {
//    let reference: String
//    let propertyID: Int
//    let accountID: Int
//    let originalPrincipal: Double
//    let downPayment: Double
//    let closeDate: String
//    let loanDate: String
//    let paymentStartDate: String
//    let paymentDay: Int
//    let startingPaymentNumber: Int
//    let term: Int
//    let interestMethod: String
//    let unitID: Int
//    let principalChargeTypeID: Int
//    let interestChargeTypeID: Int
//    let prepayChargeTypeID: Int
//    let loanRates: [LoanRate]
//
//    enum CodingKeys: String, CodingKey {
//        case reference = "Reference"
//        case propertyID = "PropertyID"
//        case accountID = "AccountID"
//        case originalPrincipal = "OriginalPrincipal"
//        case downPayment = "DownPayment"
//        case closeDate = "CloseDate"
//        case loanDate = "LoanDate"
//        case paymentStartDate = "PaymentStartDate"
//        case paymentDay = "PaymentDay"
//        case startingPaymentNumber = "StartingPaymentNumber"
//        case term = "Term"
//        case interestMethod = "InterestMethod"
//        case unitID = "UnitID"
//        case principalChargeTypeID = "PrincipalChargeTypeID"
//        case interestChargeTypeID = "InterestChargeTypeID"
//        case prepayChargeTypeID = "PrepayChargeTypeID"
//        case loanRates = "LoanRates"
//    }
//}

struct LoanRate: Codable {
    let paymentAmount: Double
    let paymentNumber: Int
    let interestRate: Double
    
    enum CodingKeys: String, CodingKey {
        case paymentAmount = "PaymentAmount"
        case paymentNumber = "PaymentNumber"
        case interestRate = "InterestRate"
    }
}

struct CreatedLoanResponse: Codable {
    let loanID: Int?
    let reference: String?
    let propertyID: Int?
    let accountID: Int?
    let unitID: Int?
    let originalPrincipal: Double?
    let downPayment: Double?
    let term: Int?
    let status: String?
    
    enum CodingKeys: String, CodingKey {
        case loanID = "LoanID"
        case reference = "Reference"
        case propertyID = "PropertyID"
        case accountID = "AccountID"
        case unitID = "UnitID"
        case originalPrincipal = "OriginalPrincipal"
        case downPayment = "DownPayment"
        case term = "Term"
        case status = "Status"
    }
}





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



// MARK: - Loan Creation Models
struct CreateLoanRequest: Codable {
    let reference: String
    let propertyID: Int
    let accountID: Int
    let originalPrincipal: Double
    let downPayment: Double
    let closeDate: String
    let loanDate: String
    let paymentStartDate: String
    let paymentDay: Int
    let startingPaymentNumber: Int
    let term: Int
    let interestMethod: String
    let unitID: Int
    let principalChargeTypeID: Int
    let interestChargeTypeID: Int
    let prepayChargeTypeID: Int
    let loanRates: [LoanRate]
    
    enum CodingKeys: String, CodingKey {
        case reference = "Reference"
        case propertyID = "PropertyID"
        case accountID = "AccountID"
        case originalPrincipal = "OriginalPrincipal"
        case downPayment = "DownPayment"
        case closeDate = "CloseDate"
        case loanDate = "LoanDate"
        case paymentStartDate = "PaymentStartDate"
        case paymentDay = "PaymentDay"
        case startingPaymentNumber = "StartingPaymentNumber"
        case term = "Term"
        case interestMethod = "InterestMethod"
        case unitID = "UnitID"
        case principalChargeTypeID = "PrincipalChargeTypeID"
        case interestChargeTypeID = "InterestChargeTypeID"
        case prepayChargeTypeID = "PrepayChargeTypeID"
        case loanRates = "LoanRates"
    }
}



enum LoanCreationError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL for loan creation"
        case .invalidResponse:
            return "Invalid response from loan server"
        case .httpError(let statusCode):
            return "Loan creation HTTP error with status code: \(statusCode)"
        }
    }
}


