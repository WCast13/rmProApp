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
    @State private var paymentStartDate = Date()
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
                        await createNewLoan()
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
        let activeLeaseRenewal = ActiveLeaseRenewal()
        
        let requestBody = CreateLeaseRequest(tenantID: tenantID, unitID: unitID, moveInDate: moveInDateString, activeLeaseRenewal: activeLeaseRenewal)
        
        let status = await RentManagerAPIClient.shared.postRequest(url: newURL, body: requestBody)
        print(status)
    }
    
    func createNewLoan() async {
        let url = URL(string: "https://trieq.api.rentmanager.com/Loans")
        guard let newURL = url else { return }
        let tenantID: Int = tenant.tenantID ?? 0
        let unitID = newUnitID ?? 0
        
        let closeDateString = closeDate.toRentManagerAPIString()
        let loanDateString = loanDate.toRentManagerAPIString()
        let paymentStartDateString = paymentStartDate.toRentManagerAPIString()
        
        let loanRate = LoanRates(paymentAmount: paymentAmount, interestRate: interestRate)
        
        let loanRequest = CreateLoanRequest(reference: "100", unitID: unitID, accountID: tenantID, originalPrincipal: originalPrincipal, downPayment: downPayment, closeDate: closeDateString, loanDate: loanDateString, paymentStartDate: paymentStartDateString, term: term, loanRates: [loanRate])
        
        let status = await RentManagerAPIClient.shared.postRequest(url: newURL, body: loanRequest)
        print(status)
        
    }
    
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
    let activeLeaseRenewal: ActiveLeaseRenewal?
    
    enum CodingKeys: String, CodingKey {
        case tenantID = "TenantID"
        case unitID = "UnitID"
        case moveInDate = "MoveInDate"
        case activeLeaseRenewal = "ActiveLeaseRenewal"
    }
}

struct ActiveLeaseRenewal: Encodable { }

struct CreateLoanRequest: Encodable {
    let reference: String
    let propertyID: Int = 8
    let unitID: Int
    let accountID: Int
    let originalPrincipal: Double
    let downPayment: Double
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
        case reference
        case propertyID
        case accountID
        case originalPrincipal = "OriginalPrincipal"
        case downPayment
        case closeDate
        case loanDate
        case paymentStartDate
        case paymentDay
        case startingPaymentNumber = "StartingPaymentNumber"
        case term
        case interestMethod
        case unitID = "UnitID"
        case principalChargeTypeID = "PrincipalChargeTypeID"
        case interestChargeTypeID = "InterestChargeTypeID"
        case prepayChargeTypeID = "PrepayChargeTypeID"
        case loanRates
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
