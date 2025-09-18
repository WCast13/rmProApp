//
//  WCTransaction.swift
//  rmProApp
//
//  Created by William Castellano on 4/21/25.
//

import Foundation
import SwiftData


@Model
final class WCTransaction: Identifiable, Hashable, Equatable {
    var id = UUID()
    // Charge
    var chargeID: Int?
    var chargeTypeID: Int?
    var chargeType: RMChargeType?
    var unitID: Int?
    // Charge/Payment
    var propertyID: Int?
    var accountID: Int?
    var amount: Decimal?
    var transactionDate: String?
    var createDate: String?
    var updateDate: String?
    var comment: String?
    var transactionType: String?
    var amountAllocated: Decimal?
    var isFullyAllocated: Bool?
    // Payment
    var paymentID: Int?
    var paymentReversalDate: String?
    var paymentReversalType: String?

    init(
        chargeID: Int? = nil,
        chargeTypeID: Int? = nil,
        chargeType: RMChargeType? = nil,
        unitID: Int? = nil,
        propertyID: Int? = nil,
        accountID: Int? = nil,
        amount: Decimal? = nil,
        transactionDate: String? = nil,
        createDate: String? = nil,
        updateDate: String? = nil,
        comment: String? = nil,
        transactionType: String? = nil,
        amountAllocated: Decimal? = nil,
        isFullyAllocated: Bool? = nil,
        paymentID: Int? = nil,
        paymentReversalDate: String? = nil,
        paymentReversalType: String? = nil
    ) {
        self.chargeID = chargeID
        self.chargeTypeID = chargeTypeID
        self.chargeType = chargeType
        self.unitID = unitID
        self.propertyID = propertyID
        self.accountID = accountID
        self.amount = amount
        self.transactionDate = transactionDate
        self.createDate = createDate
        self.updateDate = updateDate
        self.comment = comment
        self.transactionType = transactionType
        self.amountAllocated = amountAllocated
        self.isFullyAllocated = isFullyAllocated
        self.paymentID = paymentID
        self.paymentReversalDate = paymentReversalDate
        self.paymentReversalType = paymentReversalType
    }
    
    static func == (lhs: WCTransaction, rhs: WCTransaction) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
