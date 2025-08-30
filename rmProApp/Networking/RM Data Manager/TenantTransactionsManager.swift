//
//  TenantTransactionsManager.swift
//  rmProApp
//
//  Created by William Castellano on 4/21/25.
//

import Foundation

struct TenantTransactionsManager {
    
    static let shared = TenantTransactionsManager()
    
    func processTransactions(tenant: WCLeaseTenant) async -> [WCTransaction] {
        
        let transactionData = await TenantDataManager.shared.fetchSingleTenantTransactions(tenantID: String(tenant.tenantID ?? 0))
        
        guard let charges = transactionData?.charges, !charges.isEmpty, let payments = transactionData?.payments, !payments.isEmpty, let paymentReversals = transactionData?.paymentReversals else { return [WCTransaction]() }
        
        var transaction = WCTransaction()
        var transactionArray: [WCTransaction] = []
        
        // Process charges
        for charge in charges {
            transaction.chargeID = charge.id
            transaction.chargeTypeID = charge.chargeTypeID
            transaction.chargeType = charge.chargeType
            transaction.propertyID = charge.propertyID
            transaction.unitID = charge.unitID
            
            // Process payments
            for payment in payments {
                transaction.paymentID = payment.id
                transaction.paymentReversalDate = payment.reversalDate
                transaction.paymentReversalType = payment.reversalType
                
                updateCommonFields(trasaction: transaction, payment: payment, charge: charge)
                transactionArray.append(transaction)
            }
        }
        
        func updateCommonFields(trasaction: WCTransaction, payment: RMPayment, charge: RMCharge) {
            
            if charge.transactionType == "Charge" {
                transaction.unitID = charge.unitID
                transaction.accountID = charge.accountID
                transaction.amount = charge.amount
                transaction.transactionDate = charge.transactionDate
                transaction.createDate = charge.createDate
                transaction.updateDate = charge.updateDate
                transaction.comment = charge.comment
                transaction.transactionType = charge.transactionType
                transaction.isFullyAllocated = charge.isFullyAllocated
                transaction.amountAllocated = charge.amountAllocated
            } else {
                transaction.accountID = payment.accountID
                transaction.amount = payment.amount
                transaction.transactionDate = payment.transactionDate
                transaction.createDate = payment.createDate
                transaction.updateDate = payment.updateDate
                transaction.comment = payment.comment
                transaction.transactionType = payment.transactionType
                transaction.isFullyAllocated = payment.isFullyAllocated
                transaction.amountAllocated = payment.amountAllocated
            }
        }
        return transactionArray
    }
}
