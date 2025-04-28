//
//  RMLoan.swift
//  rmProApp
//
//  Created by William Castellano on 4/15/25.
//

import Foundation

// MARK: - Loan
struct RMLoan: Codable, Identifiable, Hashable {
    let id = UUID()
    let loanID: Int?
    let reference: String?
    let accountID: Int?
    let accountType: String?
    let originalPrincipal: Double?
    let downPayment: Int?
    let closeDate: String?
    let loanDate: String?
    let paymentStartDate: String?
    let paymentDay: Int?
    let startingPaymentNumber: Int?
    let adjustedPrincipal: Double?
    let adjustedStartDate: String?
    let lastPreexistingPaymentDate: String?
    let preexistingInterestYear: Int?
    let preexistingInterest: Int?
    let term: Int?
    let interestMethod: String?
    let visibleDaysBeforeDueDate: Int?
    let isRounded: Bool?
    let isExtendTerm: Bool?
    let isIncreasePrincipal: Bool?
    let principalChargeTypeID: Int?
    let interestChargeTypeID: Int?
    let prepayChargeTypeID: Int?
    let saleTransactionID: Int?
    let creditTransactionID: Int?
    let chargesPosted: Int?
    let lastPostDate: String?
    let insuranceExpirationDate: String?
    let isUsingAveragePrincipal: Bool?
    let propertyID: Int?
    let unitID: Int?
    let principalPaid: Double?
    let principalCredited: Int?
    let principalBalance: Double?
    let status: String?
    let acquisitionDate: String?
    let isOpen: Bool?
    let createDate: String?
    let createUserID: Int?
    let updateDate: String?
    let updateUserID: Int?
    let concurrencyID: Int?

    enum CodingKeys: String, CodingKey {
        case loanID = "LoanID"
        case reference = "Reference"
        case accountID = "AccountID"
        case accountType = "AccountType"
        case originalPrincipal = "OriginalPrincipal"
        case downPayment = "DownPayment"
        case closeDate = "CloseDate"
        case loanDate = "LoanDate"
        case paymentStartDate = "PaymentStartDate"
        case paymentDay = "PaymentDay"
        case startingPaymentNumber = "StartingPaymentNumber"
        case adjustedPrincipal = "AdjustedPrincipal"
        case adjustedStartDate = "AdjustedStartDate"
        case lastPreexistingPaymentDate = "LastPreexistingPaymentDate"
        case preexistingInterestYear = "PreexistingInterestYear"
        case preexistingInterest = "PreexistingInterest"
        case term = "Term"
        case interestMethod = "InterestMethod"
        case visibleDaysBeforeDueDate = "VisibleDaysBeforeDueDate"
        case isRounded = "IsRounded"
        case isExtendTerm = "IsExtendTerm"
        case isIncreasePrincipal = "IsIncreasePrincipal"
        case principalChargeTypeID = "PrincipalChargeTypeID"
        case interestChargeTypeID = "InterestChargeTypeID"
        case prepayChargeTypeID = "PrepayChargeTypeID"
        case saleTransactionID = "SaleTransactionID"
        case creditTransactionID = "CreditTransactionID"
        case chargesPosted = "ChargesPosted"
        case lastPostDate = "LastPostDate"
        case insuranceExpirationDate = "InsuranceExpirationDate"
        case isUsingAveragePrincipal = "IsUsingAveragePrincipal"
        case propertyID = "PropertyID"
        case unitID = "UnitID"
        case principalPaid = "PrincipalPaid"
        case principalCredited = "PrincipalCredited"
        case principalBalance = "PrincipalBalance"
        case status = "Status"
        case acquisitionDate = "AcquisitionDate"
        case isOpen = "IsOpen"
        case createDate = "CreateDate"
        case createUserID = "CreateUserID"
        case updateDate = "UpdateDate"
        case updateUserID = "UpdateUserID"
        case concurrencyID = "ConcurrencyID"
    }
}
