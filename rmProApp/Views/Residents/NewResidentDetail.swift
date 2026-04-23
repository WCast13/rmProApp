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
    @State private var loanName: String = ""
    @State private var showLoanForm = false
    @State private var originalPrincipal = 0.0
    @State private var downPayment = 0.0
    @State private var term = 300
    @State private var paymentAmount = 0.0
    @State private var interestRate = 6.5
    @State private var closeDate = Date()
    @State private var loanDate = Date()
    @State private var paymentStartDate: Date = {
        let calendar = Calendar.current
        let now = Date()
        // Move to next month, then set day to 15
        var comps = DateComponents()
        comps.month = 1
        let nextMonth = calendar.date(byAdding: comps, to: now) ?? now
        var target = calendar.dateComponents([.year, .month], from: nextMonth)
        target.day = 15
        // Start of day for consistency
        return calendar.date(from: target) ?? now
    }()
    @State private var newUnitID: Int?
    
    @State private var isCreatingLoan = false
    @State private var loanCreationError: String?
    @State private var showSuccessAlert = false
    
    var body: some View {
        ScrollView {
            
            Button("Create New Loan") {
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
            loanName = tenant.unit?.name ?? ""
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
                isCreating: $isCreatingLoan,
                onSubmit: {
                    Task {
                        await createNewUnit()
                        await createNewLease()
//                        await createNewLoan()
                        showSuccessAlert = true
                    }
                }
            )
        }
        .alert("Success!", isPresented: $showSuccessAlert) {
            Button("OK") {
                showLoanForm = false
            }
        } message: {
            Text("Loan created successfully!")
        }
        .alert("Error", isPresented: .constant(loanCreationError != nil)) {
            Button("OK") {
                loanCreationError = nil
            }
        } message: {
            Text(loanCreationError ?? "Unknown error")
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
  
    func createNewUnit() async {
        let newUnitName = "\(tenant.unit?.name ?? "") - Loan"
        let unitFilter = RMDataManager.shared.unitsWithBasicData.filter { $0.name == newUnitName }
        
        if unitFilter.isEmpty {
            let url = URL(string: "https://trieq.api.rentmanager.com/Units")
            guard let newURL = url else { return }

            let requestBody = CreateUnitRequest(name: newUnitName)
            // API returns an array, so we decode as [CreateUnitResponse] and get the first item
            if let response = await RentManagerAPIClient.shared.postRequest(url: newURL, body: requestBody, responseType: [CreateUnitResponse].self),
               let createdUnit = response.first {
                print("Unit created with ID: \(createdUnit.unitID)")
                newUnitID = createdUnit.unitID
                print("New Unit ID: \(newUnitID ?? 0)")
            }
        } else {
            newUnitID = unitFilter.first?.unitID ?? 0
            print("New Unit ID: \(newUnitID ?? 0)")
        }
    }
    
    func createNewLease() async {
        let url = URL(string: "https://trieq.api.rentmanager.com/Leases")
        guard let newURL = url else { return }
        let tenantID: Int = tenant.tenantID ?? 0
        let unitID = newUnitID ?? 0
        
        let moveInDateString = closeDate.toRentManagerAPIString()
        let activeLeaseRenewal = ActiveLeaseRenewal(startDate: moveInDateString)
        
        let requestBody = CreateLeaseRequest(tenantID: tenantID, unitID: unitID, moveInDate: moveInDateString, startDate: moveInDateString, activeLeaseRenewal: activeLeaseRenewal)
        
        let status = await RentManagerAPIClient.shared.postRequest(url: newURL, body: requestBody)
        print(status)
    }
    
    func createNewLoan() async {
        // MARK: Loan Post Request Section
        
        let url = URL(string: "https://trieq.api.rentmanager.com/Loans")
        guard let newURL = url else { return }
        
        let tenantID: Int = tenant.tenantID ?? 0
        let unitID = newUnitID ?? 0
        
        let closeDateString = closeDate.toRentManagerAPIString()
        let loanDateString = loanDate.toRentManagerAPIString()
        let paymentStartDateString = paymentStartDate.toRentManagerAPIString()
        
        let loanRate = LoanRates(paymentAmount: paymentAmount, interestRate: interestRate)
        let reference: String = "\(tenant.lease?.unit?.name ?? "") - Loan"
        
        
        let loanRequest = CreateLoanRequest(
            reference: reference,
            unitID: unitID,
            accountID: tenantID,
            originalPrincipal: originalPrincipal,
            downPayment: downPayment,
            adjustedPrincipal: originalPrincipal - downPayment,
            closeDate: closeDateString,
            loanDate: loanDateString,
            paymentStartDate: paymentStartDateString,
            term: term,
            loanRates: [loanRate])
        
        let status = await RentManagerAPIClient.shared.postRequest(url: newURL, body: loanRequest)
        
        // MARK: Down Payment Post Request Section
        
        let downPaymentURL = URL(string: "https://trieq.api.rentmanager.com/Credits")
        guard let downPaymentNewURL = downPaymentURL else { return }
        
        let downPaymentRequest: CreateCreditRequest = CreateCreditRequest(
            accountID: tenantID,
            transactionDate: loanDateString,
            unitID: unitID,
            reference: reference,
            amount: originalPrincipal - downPayment
        )
         
        let downPaymetStatus = await RentManagerAPIClient.shared.postRequest(url: downPaymentNewURL, body: downPaymentRequest)
        
        print(downPaymetStatus)
        
        
        // MARK: Home Sales Post Request Section
        
        let homeSalesURL = URL(string: "https://trieq.api.rentmanager.com/Charges")
        guard let homeSalesNewURL = homeSalesURL else { return }
        
        let CreateHomeSalesRequest: CreateHomeSalesRequest = CreateHomeSalesRequest(
           accountID: tenantID,
           amount: originalPrincipal,
           transactionDate: loanDateString,
           unitID: unitID,
           reference: reference
        )
        
        let homeSalesChargeStatus = await RentManagerAPIClient.shared.postRequest(url: homeSalesNewURL, body: CreateHomeSalesRequest)
        
        print("Loan Status: \(status)")
        print("Down Payment Status: \(downPaymetStatus)")
        print("Home Sales Status: \(homeSalesChargeStatus)")
        
        
    }
}

struct CreateCreditRequest: Encodable {
    let accountID: Int
    let chargeTypeID: Int = 15
    let transactionType: String = "Credit"
    let transactionDate: String
    let propertyID: Int = 8
    let unitID: Int
    let reference: String
    let amount: Double
    
    enum CodingKeys: String, CodingKey {
        case accountID = "AccountID"
        case chargeTypeID = "ChargeTypeID"
        case transactionType = "TransactionType"
        case transactionDate = "TransactionDate"
        case propertyID = "PropertyID"
        case unitID = "UnitID"
        case reference = "Reference"
        case amount = "Amount"
    }
    
    
    /*
     {
     "AccountID": 2588,
     "ChargeTypeID": 15, // Notes Recievable
     "TransactionType": "Credit",
     "TransactionDate": "2023-03-01T00:00:00",
     "PropertyID": 8,
     "UnitID": 1336,
     //   "AmountAllocated": 187500.00,
     //   "IsFullyAllocated": true,
     //   "IsRecordingCashReallocations": true,
     //   "IsRecordingCashPreallocationsAsLiability": true,
     //   "IsRecordingAccrualPrepayments": true,
     "AccountType": "Customer",
     "Reference": "LN: 53",
     "Amount": 187500.00
     }
     */
}

struct CreateHomeSalesRequest: Encodable {
    let accountID: Int
    let amount: Double
    let transactionDate: String
    let unitID: Int
    let propertyID: Int = 8
    let chargeTypeID: Int = 17
    let accountType: String = "Customer"
    let reference: String
    
    enum CodingKeys: String, CodingKey {
        case accountID = "AccountID"
        case amount = "Amount"
        case transactionDate = "TransactionDate"
        case unitID = "UnitID"
        case propertyID = "PropertyID"
        case chargeTypeID = "ChargeTypeID"
        case accountType = "AccountType"
        case reference = "Reference"
    }
    
    /*
     {
         "AccountID": 2926,
         "Amount": 40000.00,
         "TransactionDate": "2025-10-21T00:00:00",
         "PropertyID": 8,
         "UnitID": 1396,
         "ChargeTypeID": 17, // Home Sales
         "AccountType": "Customer"
         "Reference": "Reference # Loan"
     }
     */
}

struct CreateUnitRequest: Encodable {
    let propertyID: Int = 8
    let name: String
    let unitTypeID: Int = 6

    enum CodingKeys: String, CodingKey {
        case propertyID = "PropertyID"
        case name = "Name"
        case unitTypeID = "UnitTypeID"
    }
}

struct CreateUnitResponse: Decodable {
    let unitID: Int
    let name: String

    enum CodingKeys: String, CodingKey {
        case unitID = "UnitID"
        case name = "Name"
    }
}

struct CreateLeaseRequest: Encodable {
    let tenantID: Int
    let unitID: Int
    let moveInDate: String
    let startDate: String
    let activeLeaseRenewal: ActiveLeaseRenewal?
    
    enum CodingKeys: String, CodingKey {
        case tenantID = "TenantID"
        case unitID = "UnitID"
        case moveInDate = "MoveInDate"
        case startDate = "StartDate"
        case activeLeaseRenewal = "ActiveLeaseRenewal"
    }
}

struct ActiveLeaseRenewal: Encodable {
    let startDate: String
    
    enum CodingKeys: String, CodingKey {
        case startDate = "StartDate"
    }
}

struct CreateLoanRequest: Encodable {
    let reference: String
    let propertyID: Int = 8
    let unitID: Int
    let accountID: Int
    let originalPrincipal: Double
    let downPayment: Double
    let adjustedPrincipal: Double
    let closeDate: String
    let loanDate: String
    let paymentStartDate: String
    let paymentDay: Int = 15
    let startingPaymentNumber: Int = 0
    let term: Int
    let interestMethod: String = "Straight"
    let principalChargeTypeID: Int = 16
    let interestChargeTypeID: Int = 38
    let prepayChargeTypeID: Int = 16
    let loanRates: [LoanRates]
    
    enum CodingKeys: String, CodingKey {
        case reference = "Reference"
        case propertyID = "PropertyID"
        case accountID = "AccountID"
        case originalPrincipal = "OriginalPrincipal"
        case downPayment = "DownPayment"
        case adjustedPrincipal = "AdjustedPrincipal"
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

struct LoanRates: Encodable {
    let paymentAmount: Double
    let paymentNumber: Int = 1
    let interestRate: Double
    
    enum CodingKeys: String, CodingKey {
        case paymentAmount
        case paymentNumber
        case interestRate
    }
}

/*
 {
     "TenantID": 838,
     "UnitID": 1346,
     "MoveInDate": "1941-12-06T00:00:00",
     "ActiveLeaseRenewal": {}
 }
 */


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

