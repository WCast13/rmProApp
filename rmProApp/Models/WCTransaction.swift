//
//  WCTransaction.swift
//  rmProApp
//
//  Created by William Castellano on 4/21/25.
//

import Foundation


struct WCTransaction: Identifiable, Hashable {
    
    let id = UUID()
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
}
