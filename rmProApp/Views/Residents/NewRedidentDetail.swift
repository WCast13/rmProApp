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

    func sendCreateLoanRequest(
        reference: String,
        propertyID: Int,
        accountID: Int,
        originalPrincipal: Double,
        downPayment: Double,
        closeDate: Date,
        loanDate: Date,
        paymentStartDate: Date,
        paymentDay: Int,
        startingPaymentNumber: Int,
        term: Int,
        interestMethod: String,
        unitID: Int,
        principalChargeTypeID: Int,
        interestChargeTypeID: Int,
        prepayChargeTypeID: Int,
        paymentAmount: Double,
        paymentNumber: Int,
        interestRate: Double
    ) async throws -> CreatedLoanResponse {
        // Create loan rate
        let loanRate = LoanRate(
            paymentAmount: paymentAmount,
            paymentNumber: paymentNumber,
            interestRate: interestRate
        )

        // Create request payload
        let requestBody = CreateLoanRequest(
            reference: reference,
            propertyID: propertyID,
            accountID: accountID,
            originalPrincipal: originalPrincipal,
            downPayment: downPayment,
            closeDate: closeDate,
            loanDate: loanDate,
            paymentStartDate: paymentStartDate,
            paymentDay: paymentDay,
            startingPaymentNumber: startingPaymentNumber,
            term: term,
            interestMethod: interestMethod,
            unitID: unitID,
            principalChargeTypeID: principalChargeTypeID,
            interestChargeTypeID: interestChargeTypeID,
            prepayChargeTypeID: prepayChargeTypeID,
            loanRates: [loanRate]
        )

        // Encode to JSON
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let jsonData = try encoder.encode(requestBody)

        // Debug: Print JSON
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print("Request JSON: \(jsonString)")
        }

        // Configure request
        let urlString = "https://trieq.api.rentmanager.com/Loans/?embeds=Account%2CInterestChargeType%2CLoanContacts%2CLoanContacts.Address%2CLoanContacts.EmployerAddress%2CLoanContacts.PhoneNumber%2CLoanOtherCharges%2CLoanRates%2CLoanTransactions%2CMetroLoan%2CPrepayChargeType%2CPrincipalChargeType%2CProperty%2CProspect%2CTenant%2CUnit%2CUserDefinedValues%2CUserDefinedValues.Attachment&fields=Account%2CAccountID%2CAccountType%2CAcquisitionDate%2CAdjustedPrincipal%2CAdjustedStartDate%2CChargesPosted%2CCloseDate%2CConcurrencyID%2CCreateDate%2CCreateUserID%2CCreditTransactionID%2CDownPayment%2CInListItemMode%2CInsuranceExpirationDate%2CInterestChargeType%2CInterestChargeTypeID%2CInterestMethod%2CIsExtendTerm%2CIsIncreasePrincipal%2CIsOpen%2CIsRounded%2CIsUsingAveragePrincipal%2CLastPostDate%2CLastPreexistingPaymentDate%2CLoanContacts%2CLoanDate%2CLoanID%2CLoanOtherCharges%2CLoanRates%2CLoanTransactions%2CMetaTag%2CMetroLoan%2CNotesReceivableChargeTypeID%2COriginalPrincipal%2CPaymentDay%2CPaymentStartDate%2CPreexistingInterest%2CPreexistingInterestYear%2CPrepayChargeType%2CPrepayChargeTypeID%2CPrincipalBalance%2CPrincipalChargeType%2CPrincipalChargeTypeID%2CPrincipalCredited%2CPrincipalPaid%2CProperty%2CPropertyID%2CProspect%2CReference%2CSalesChargeTypeID%2CSaleTransactionID%2CStartingPaymentNumber%2CStatus%2CTenant%2CTerm%2CUnit%2CUnitID%2CUpdateDate%2CUpdateUserID%2CUserDefinedValues%2CVisibleDaysBeforeDueDate"

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
        guard let httpResponse = response as? HTTPURLResponse else {
            throw LoanCreationError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw LoanCreationError.httpError(statusCode: httpResponse.statusCode)
        }

        // Decode response
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let createdLoan = try decoder.decode(CreatedLoanResponse.self, from: data)

        print("Created Loan: \(createdLoan)")

        return createdLoan
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
struct CreateLoanRequest: Codable {
    let reference: String
    let propertyID: Int
    let accountID: Int
    let originalPrincipal: Double
    let downPayment: Double
    let closeDate: Date
    let loanDate: Date
    let paymentStartDate: Date
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
