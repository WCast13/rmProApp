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

        let charges = transactionData.charges ?? []
        let payments = transactionData.payments ?? []
        let paymentReversals = transactionData.paymentReversals ?? []

        tenant.charges = charges
        tenant.payments = payments
        tenant.paymentReversals = paymentReversals
        tenant.transactions = buildTransactions(
            charges: charges,
            payments: payments,
            reversals: paymentReversals
        )
    }

    /// Merge charges, payments, and payment reversals into a single
    /// timeline. One `WCTransaction` per source row — each with its own
    /// identity — sorted by transactionDate descending (ISO-8601 strings
    /// order correctly as lexical sorts).
    private func buildTransactions(
        charges: [RMCharge],
        payments: [RMPayment],
        reversals: [RMPaymentReversal]
    ) -> [WCTransaction] {
        var result: [WCTransaction] = []
        result.reserveCapacity(charges.count + payments.count + reversals.count)

        for charge in charges {
            result.append(WCTransaction(
                chargeID: charge.id,
                chargeTypeID: charge.chargeTypeID,
                chargeType: charge.chargeType,
                unitID: charge.unitID,
                propertyID: charge.propertyID,
                accountID: charge.accountID,
                amount: charge.amount,
                transactionDate: charge.transactionDate,
                createDate: charge.createDate,
                updateDate: charge.updateDate,
                comment: charge.comment,
                transactionType: charge.transactionType,
                amountAllocated: charge.amountAllocated,
                isFullyAllocated: charge.isFullyAllocated
            ))
        }

        for payment in payments {
            result.append(WCTransaction(
                accountID: payment.accountID,
                amount: payment.amount,
                transactionDate: payment.transactionDate,
                createDate: payment.createDate,
                updateDate: payment.updateDate,
                comment: payment.comment,
                transactionType: payment.transactionType,
                amountAllocated: payment.amountAllocated,
                isFullyAllocated: payment.isFullyAllocated,
                paymentID: payment.id,
                paymentReversalDate: payment.reversalDate,
                paymentReversalType: payment.reversalType
            ))
        }

        for reversal in reversals {
            result.append(WCTransaction(
                accountID: reversal.accountID,
                transactionDate: reversal.reversalDate,
                createDate: reversal.createDate,
                comment: reversal.reversalReason,
                transactionType: "Reversal",
                paymentID: reversal.paymentID,
                paymentReversalDate: reversal.reversalDate,
                paymentReversalType: reversal.reversalType
            ))
        }

        return result.sorted { ($0.transactionDate ?? "") > ($1.transactionDate ?? "") }
    }
}
