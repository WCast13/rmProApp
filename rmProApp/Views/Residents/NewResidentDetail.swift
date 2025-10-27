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
    @State private var loanName = ""
    @State private var originalPrincipal = 2000000.0
    @State private var downPayment = 100000.0
    @State private var term = 100
    @State private var paymentAmount = 10000.0
    @State private var interestRate = 10.0
    @State private var closeDate = Date()
    @State private var loanDate = Date()
    @State private var paymentStartDate = Date()
    
    @State private var newUnitID: Int = 0
    
    var body: some View {
        ScrollView {
            
            Button("Create New Loan") {
                Task {
                    let createdUnit = try? await createNewUnit(name: "\(tenant.unit?.name ?? "New Unit")- Loan")
                    newUnitID = createdUnit?.unitID ?? 0
                    print("✅ Unit created with ID: \(newUnitID)")
                }
                
                Task {
                    try? await addLeaseForLoan(unitID: newUnitID)
                    print("✅ Lease created successfully")
                    
                }
                
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
                }
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
    
    func createLoan() async throws {
//        // STEP 1: Create Unit and await completion
//        print("📦 Step 1: Creating unit...")
//        let newUnit = try await createNewUnit(name: "_XXX Test - Loan\(Int.random(in: 1...305))")
//        print("✅ Unit created with ID: \(newUnit.unitID ?? 0)")
//        
//        guard let unitID = newUnit.unitID else {
//            throw UnitCreationError.invalidResponse
//        }
//        
//        // STEP 2: Create Lease using the unit ID and await completion
//        print("📄 Step 2: Creating lease for unit \(unitID)...")
//        try await addLeaseForLoan(unitID: unitID)
//        print("✅ Lease created successfully")
//        
        // STEP 3: Create Loan using the unit ID
        print("💰 Step 3: Creating loan...")
        
        let closeDateShort = closeDate.formatted(date: .numeric, time: .omitted)
        let loanDateShort = loanDate.formatted(date: .numeric, time: .omitted)
        let paymentStartDateShort = paymentStartDate.formatted(date: .numeric, time: .omitted)
        
        print("Close Date: \(closeDateShort)")
        print("Loan Date: \(loanDateShort)")
        print("Payment Start Date: \(paymentStartDateShort)")
        
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
            unitID: newUnitID,
            principalChargeTypeID: 16,
            interestChargeTypeID: 38,
            prepayChargeTypeID: 16,
            loanRates: [ loanRate ]
        )
        
        // Send loan creation request
        guard let loanURL = URL(string: "https://trieq.api.rentmanager.com/Loans/") else {
            throw LoanCreationError.invalidURL
        }
        
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(requestBody)
        
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print("Loan Request JSON: \(jsonString)")
        }
        
        let apiKey = TokenManager.shared.token ?? ""
        var request = URLRequest(url: loanURL, timeoutInterval: 30.0)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "X-RM12Api-ApiToken")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        print("Loan Response: \(String(decoding: data, as: UTF8.self))")
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw LoanCreationError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw LoanCreationError.httpError(statusCode: httpResponse.statusCode)
        }
        
        print("✅ Loan created successfully!")
        print("🎉 All steps completed: Unit ➡️ Lease ➡️ Loan")
    }
    
    func createNewUnit(name: String = "Test - Loan\(Int.random(in: 1...305))") async throws -> CreatedUnitResponse {
        
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
    
    func addLeaseForLoan(unitID: Int) async throws {
        guard let url = URL(string: "https://trieq.api.rentmanager.com/Leases") else {
            throw LeaseCreationError.invalidURL
        }
        
        guard let tenantID = tenant.tenantID, tenantID > 0 else {
            throw LeaseCreationError.invalidTenantID
        }
        
        let moveInDate = "01/01/1990"
        
        print("Creating lease - TenantID: \(tenantID), UnitID: \(unitID)")
        
        let body: [String: Any] = [
            "TenantID": tenantID,
            "UnitID": unitID,
            "MoveInDate": moveInDate,
            "ActiveLeaseRenewal": []
        ]
        
        let result = await RentManagerAPIClient.shared.postRequest(url: url, body: body)
        
        print("Lease Response - Status: \(result.statusCode), Success: \(result.success)")
        
        if let data = result.data {
            print("Lease Response Data: \(String(decoding: data, as: UTF8.self))")
        }
        
        guard result.success else {
            throw LeaseCreationError.httpError(statusCode: result.statusCode)
        }
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

enum LeaseCreationError: LocalizedError {
    case invalidURL
    case invalidTenantID
    case httpError(statusCode: Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL for lease creation"
        case .invalidTenantID:
            return "Invalid tenant ID"
        case .httpError(let statusCode):
            return "Lease creation HTTP error with status code: \(statusCode)"
        }
    }
}

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



// MARK: - Loan Creation Model



