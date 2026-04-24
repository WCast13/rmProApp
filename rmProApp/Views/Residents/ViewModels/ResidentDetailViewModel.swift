//
//  ResidentDetailViewModel.swift
//  rmProApp
//
//  Owns the state for the resident detail screen: the tenant being viewed,
//  the live-fetched transaction stream, and loading state. Fetches via
//  TransactionRepository directly — no TenantDataManager dependency.
//

import Foundation

@Observable
@MainActor
final class ResidentDetailViewModel {
    let tenant: WCLeaseTenant
    var isLoadingTransactions: Bool = false

    init(tenant: WCLeaseTenant) {
        self.tenant = tenant
    }

    /// Fetch charges + payments + payment reversals for this tenant, then
    /// build the merged WCTransaction stream. Mutates `tenant` in place so
    /// the view's child cards (which read `tenant.transactions`) see the
    /// updated data.
    func loadTransactions() async {
        isLoadingTransactions = true
        defer { isLoadingTransactions = false }

        guard let transactionData = await TransactionRepository.shared
            .fetchTransactions(for: String(tenant.tenantID ?? 0)) else {
            return
        }

        guard let charges = transactionData.charges, !charges.isEmpty,
              let payments = transactionData.payments, !payments.isEmpty,
              let paymentReversals = transactionData.paymentReversals else {
            return
        }

        tenant.charges = charges
        tenant.payments = payments
        tenant.paymentReversals = paymentReversals
        tenant.transactions = buildTransactions(charges: charges, payments: payments)
    }

    // NOTE: preserves the existing (likely broken) N×M merge from the old
    // TenantTransactionsManager.processTransactions. Fixing the merge is a
    // separate scope — see WCTransaction.swift.
    private func buildTransactions(charges: [RMCharge], payments: [RMPayment]) -> [WCTransaction] {
        var result: [WCTransaction] = []
        var scratch = WCTransaction()

        for charge in charges {
            scratch.chargeID = charge.id
            scratch.chargeTypeID = charge.chargeTypeID
            scratch.chargeType = charge.chargeType
            scratch.propertyID = charge.propertyID
            scratch.unitID = charge.unitID

            for payment in payments {
                scratch.paymentID = payment.id
                scratch.paymentReversalDate = payment.reversalDate
                scratch.paymentReversalType = payment.reversalType

                if charge.transactionType == "Charge" {
                    scratch.unitID = charge.unitID
                    scratch.accountID = charge.accountID
                    scratch.amount = charge.amount
                    scratch.transactionDate = charge.transactionDate
                    scratch.createDate = charge.createDate
                    scratch.updateDate = charge.updateDate
                    scratch.comment = charge.comment
                    scratch.transactionType = charge.transactionType
                    scratch.isFullyAllocated = charge.isFullyAllocated
                    scratch.amountAllocated = charge.amountAllocated
                } else {
                    scratch.accountID = payment.accountID
                    scratch.amount = payment.amount
                    scratch.transactionDate = payment.transactionDate
                    scratch.createDate = payment.createDate
                    scratch.updateDate = payment.updateDate
                    scratch.comment = payment.comment
                    scratch.transactionType = payment.transactionType
                    scratch.isFullyAllocated = payment.isFullyAllocated
                    scratch.amountAllocated = payment.amountAllocated
                }
                result.append(scratch)
            }
        }
        return result
    }
}
