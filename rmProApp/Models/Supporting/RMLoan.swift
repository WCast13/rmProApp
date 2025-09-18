//
//  RMLoan.swift
//  rmProApp
//
//  Created by William Castellano on 4/15/25.
//

import Foundation
import SwiftData

// MARK: - Loan
@Model
final class RMLoan: Codable, Identifiable, Hashable {
    var id = UUID()
    var loanID: Int?
    var reference: String?
    var accountID: Int?
    var accountType: String?
    var originalPrincipal: Double?
    var downPayment: Int?
    var closeDate: String?
    var loanDate: String?
    var paymentStartDate: String?
    var paymentDay: Int?
    var startingPaymentNumber: Int?
    var adjustedPrincipal: Double?
    var adjustedStartDate: String?
    var lastPreexistingPaymentDate: String?
    var preexistingInterestYear: Int?
    var preexistingInterest: Int?
    var term: Int?
    var interestMethod: String?
    var visibleDaysBeforeDueDate: Int?
    var isRounded: Bool?
    var isExtendTerm: Bool?
    var isIncreasePrincipal: Bool?
    var principalChargeTypeID: Int?
    var interestChargeTypeID: Int?
    var prepayChargeTypeID: Int?
    var saleTransactionID: Int?
    var creditTransactionID: Int?
    var chargesPosted: Int?
    var lastPostDate: String?
    var insuranceExpirationDate: String?
    var isUsingAveragePrincipal: Bool?
    var propertyID: Int?
    var unitID: Int?
    var principalPaid: Double?
    var principalCredited: Int?
    var principalBalance: Double?
    var status: String?
    var acquisitionDate: String?
    var isOpen: Bool?
    var createDate: String?
    var createUserID: Int?
    var updateDate: String?
    var updateUserID: Int?
    var concurrencyID: Int?

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

    init(
        id: UUID = UUID(),
        loanID: Int? = nil,
        reference: String? = nil,
        accountID: Int? = nil,
        accountType: String? = nil,
        originalPrincipal: Double? = nil,
        downPayment: Int? = nil,
        closeDate: String? = nil,
        loanDate: String? = nil,
        paymentStartDate: String? = nil,
        paymentDay: Int? = nil,
        startingPaymentNumber: Int? = nil,
        adjustedPrincipal: Double? = nil,
        adjustedStartDate: String? = nil,
        lastPreexistingPaymentDate: String? = nil,
        preexistingInterestYear: Int? = nil,
        preexistingInterest: Int? = nil,
        term: Int? = nil,
        interestMethod: String? = nil,
        visibleDaysBeforeDueDate: Int? = nil,
        isRounded: Bool? = nil,
        isExtendTerm: Bool? = nil,
        isIncreasePrincipal: Bool? = nil,
        principalChargeTypeID: Int? = nil,
        interestChargeTypeID: Int? = nil,
        prepayChargeTypeID: Int? = nil,
        saleTransactionID: Int? = nil,
        creditTransactionID: Int? = nil,
        chargesPosted: Int? = nil,
        lastPostDate: String? = nil,
        insuranceExpirationDate: String? = nil,
        isUsingAveragePrincipal: Bool? = nil,
        propertyID: Int? = nil,
        unitID: Int? = nil,
        principalPaid: Double? = nil,
        principalCredited: Int? = nil,
        principalBalance: Double? = nil,
        status: String? = nil,
        acquisitionDate: String? = nil,
        isOpen: Bool? = nil,
        createDate: String? = nil,
        createUserID: Int? = nil,
        updateDate: String? = nil,
        updateUserID: Int? = nil,
        concurrencyID: Int? = nil
    ) {
        self.id = id
        self.loanID = loanID
        self.reference = reference
        self.accountID = accountID
        self.accountType = accountType
        self.originalPrincipal = originalPrincipal
        self.downPayment = downPayment
        self.closeDate = closeDate
        self.loanDate = loanDate
        self.paymentStartDate = paymentStartDate
        self.paymentDay = paymentDay
        self.startingPaymentNumber = startingPaymentNumber
        self.adjustedPrincipal = adjustedPrincipal
        self.adjustedStartDate = adjustedStartDate
        self.lastPreexistingPaymentDate = lastPreexistingPaymentDate
        self.preexistingInterestYear = preexistingInterestYear
        self.preexistingInterest = preexistingInterest
        self.term = term
        self.interestMethod = interestMethod
        self.visibleDaysBeforeDueDate = visibleDaysBeforeDueDate
        self.isRounded = isRounded
        self.isExtendTerm = isExtendTerm
        self.isIncreasePrincipal = isIncreasePrincipal
        self.principalChargeTypeID = principalChargeTypeID
        self.interestChargeTypeID = interestChargeTypeID
        self.prepayChargeTypeID = prepayChargeTypeID
        self.saleTransactionID = saleTransactionID
        self.creditTransactionID = creditTransactionID
        self.chargesPosted = chargesPosted
        self.lastPostDate = lastPostDate
        self.insuranceExpirationDate = insuranceExpirationDate
        self.isUsingAveragePrincipal = isUsingAveragePrincipal
        self.propertyID = propertyID
        self.unitID = unitID
        self.principalPaid = principalPaid
        self.principalCredited = principalCredited
        self.principalBalance = principalBalance
        self.status = status
        self.acquisitionDate = acquisitionDate
        self.isOpen = isOpen
        self.createDate = createDate
        self.createUserID = createUserID
        self.updateDate = updateDate
        self.updateUserID = updateUserID
        self.concurrencyID = concurrencyID
    }

    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            id: UUID(), // 'id' is not in CodingKeys, initialize as new UUID or customize if needed
            loanID: try container.decodeIfPresent(Int.self, forKey: .loanID),
            reference: try container.decodeIfPresent(String.self, forKey: .reference),
            accountID: try container.decodeIfPresent(Int.self, forKey: .accountID),
            accountType: try container.decodeIfPresent(String.self, forKey: .accountType),
            originalPrincipal: try container.decodeIfPresent(Double.self, forKey: .originalPrincipal),
            downPayment: try container.decodeIfPresent(Int.self, forKey: .downPayment),
            closeDate: try container.decodeIfPresent(String.self, forKey: .closeDate),
            loanDate: try container.decodeIfPresent(String.self, forKey: .loanDate),
            paymentStartDate: try container.decodeIfPresent(String.self, forKey: .paymentStartDate),
            paymentDay: try container.decodeIfPresent(Int.self, forKey: .paymentDay),
            startingPaymentNumber: try container.decodeIfPresent(Int.self, forKey: .startingPaymentNumber),
            adjustedPrincipal: try container.decodeIfPresent(Double.self, forKey: .adjustedPrincipal),
            adjustedStartDate: try container.decodeIfPresent(String.self, forKey: .adjustedStartDate),
            lastPreexistingPaymentDate: try container.decodeIfPresent(String.self, forKey: .lastPreexistingPaymentDate),
            preexistingInterestYear: try container.decodeIfPresent(Int.self, forKey: .preexistingInterestYear),
            preexistingInterest: try container.decodeIfPresent(Int.self, forKey: .preexistingInterest),
            term: try container.decodeIfPresent(Int.self, forKey: .term),
            interestMethod: try container.decodeIfPresent(String.self, forKey: .interestMethod),
            visibleDaysBeforeDueDate: try container.decodeIfPresent(Int.self, forKey: .visibleDaysBeforeDueDate),
            isRounded: try container.decodeIfPresent(Bool.self, forKey: .isRounded),
            isExtendTerm: try container.decodeIfPresent(Bool.self, forKey: .isExtendTerm),
            isIncreasePrincipal: try container.decodeIfPresent(Bool.self, forKey: .isIncreasePrincipal),
            principalChargeTypeID: try container.decodeIfPresent(Int.self, forKey: .principalChargeTypeID),
            interestChargeTypeID: try container.decodeIfPresent(Int.self, forKey: .interestChargeTypeID),
            prepayChargeTypeID: try container.decodeIfPresent(Int.self, forKey: .prepayChargeTypeID),
            saleTransactionID: try container.decodeIfPresent(Int.self, forKey: .saleTransactionID),
            creditTransactionID: try container.decodeIfPresent(Int.self, forKey: .creditTransactionID),
            chargesPosted: try container.decodeIfPresent(Int.self, forKey: .chargesPosted),
            lastPostDate: try container.decodeIfPresent(String.self, forKey: .lastPostDate),
            insuranceExpirationDate: try container.decodeIfPresent(String.self, forKey: .insuranceExpirationDate),
            isUsingAveragePrincipal: try container.decodeIfPresent(Bool.self, forKey: .isUsingAveragePrincipal),
            propertyID: try container.decodeIfPresent(Int.self, forKey: .propertyID),
            unitID: try container.decodeIfPresent(Int.self, forKey: .unitID),
            principalPaid: try container.decodeIfPresent(Double.self, forKey: .principalPaid),
            principalCredited: try container.decodeIfPresent(Int.self, forKey: .principalCredited),
            principalBalance: try container.decodeIfPresent(Double.self, forKey: .principalBalance),
            status: try container.decodeIfPresent(String.self, forKey: .status),
            acquisitionDate: try container.decodeIfPresent(String.self, forKey: .acquisitionDate),
            isOpen: try container.decodeIfPresent(Bool.self, forKey: .isOpen),
            createDate: try container.decodeIfPresent(String.self, forKey: .createDate),
            createUserID: try container.decodeIfPresent(Int.self, forKey: .createUserID),
            updateDate: try container.decodeIfPresent(String.self, forKey: .updateDate),
            updateUserID: try container.decodeIfPresent(Int.self, forKey: .updateUserID),
            concurrencyID: try container.decodeIfPresent(Int.self, forKey: .concurrencyID)
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(loanID, forKey: .loanID)
        try container.encodeIfPresent(reference, forKey: .reference)
        try container.encodeIfPresent(accountID, forKey: .accountID)
        try container.encodeIfPresent(accountType, forKey: .accountType)
        try container.encodeIfPresent(originalPrincipal, forKey: .originalPrincipal)
        try container.encodeIfPresent(downPayment, forKey: .downPayment)
        try container.encodeIfPresent(closeDate, forKey: .closeDate)
        try container.encodeIfPresent(loanDate, forKey: .loanDate)
        try container.encodeIfPresent(paymentStartDate, forKey: .paymentStartDate)
        try container.encodeIfPresent(paymentDay, forKey: .paymentDay)
        try container.encodeIfPresent(startingPaymentNumber, forKey: .startingPaymentNumber)
        try container.encodeIfPresent(adjustedPrincipal, forKey: .adjustedPrincipal)
        try container.encodeIfPresent(adjustedStartDate, forKey: .adjustedStartDate)
        try container.encodeIfPresent(lastPreexistingPaymentDate, forKey: .lastPreexistingPaymentDate)
        try container.encodeIfPresent(preexistingInterestYear, forKey: .preexistingInterestYear)
        try container.encodeIfPresent(preexistingInterest, forKey: .preexistingInterest)
        try container.encodeIfPresent(term, forKey: .term)
        try container.encodeIfPresent(interestMethod, forKey: .interestMethod)
        try container.encodeIfPresent(visibleDaysBeforeDueDate, forKey: .visibleDaysBeforeDueDate)
        try container.encodeIfPresent(isRounded, forKey: .isRounded)
        try container.encodeIfPresent(isExtendTerm, forKey: .isExtendTerm)
        try container.encodeIfPresent(isIncreasePrincipal, forKey: .isIncreasePrincipal)
        try container.encodeIfPresent(principalChargeTypeID, forKey: .principalChargeTypeID)
        try container.encodeIfPresent(interestChargeTypeID, forKey: .interestChargeTypeID)
        try container.encodeIfPresent(prepayChargeTypeID, forKey: .prepayChargeTypeID)
        try container.encodeIfPresent(saleTransactionID, forKey: .saleTransactionID)
        try container.encodeIfPresent(creditTransactionID, forKey: .creditTransactionID)
        try container.encodeIfPresent(chargesPosted, forKey: .chargesPosted)
        try container.encodeIfPresent(lastPostDate, forKey: .lastPostDate)
        try container.encodeIfPresent(insuranceExpirationDate, forKey: .insuranceExpirationDate)
        try container.encodeIfPresent(isUsingAveragePrincipal, forKey: .isUsingAveragePrincipal)
        try container.encodeIfPresent(propertyID, forKey: .propertyID)
        try container.encodeIfPresent(unitID, forKey: .unitID)
        try container.encodeIfPresent(principalPaid, forKey: .principalPaid)
        try container.encodeIfPresent(principalCredited, forKey: .principalCredited)
        try container.encodeIfPresent(principalBalance, forKey: .principalBalance)
        try container.encodeIfPresent(status, forKey: .status)
        try container.encodeIfPresent(acquisitionDate, forKey: .acquisitionDate)
        try container.encodeIfPresent(isOpen, forKey: .isOpen)
        try container.encodeIfPresent(createDate, forKey: .createDate)
        try container.encodeIfPresent(createUserID, forKey: .createUserID)
        try container.encodeIfPresent(updateDate, forKey: .updateDate)
        try container.encodeIfPresent(updateUserID, forKey: .updateUserID)
        try container.encodeIfPresent(concurrencyID, forKey: .concurrencyID)
    }
}
