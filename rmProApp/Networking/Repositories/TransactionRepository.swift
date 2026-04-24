//
//  TransactionRepository.swift
//  rmProApp
//
//  Live-fetch (never cached) repository for per-tenant transactions —
//  charges, payments, payment reversals. The plan keeps transactions
//  out of SwiftData because they grow unboundedly and readers need
//  freshness; the repo exists to give callers one clean seam to hit.
//

import Foundation

actor TransactionRepository {
    static let shared = TransactionRepository()
    private init() {}

    /// Fetches a single tenant's transaction stream (charges + payments +
    /// payment reversals) from the API. No caching — always hits the network.
    /// Returns the RMTenant envelope whose nested arrays are populated.
    func fetchTransactions(for tenantID: String) async -> RMTenant? {
        let request = GetTenantDetailRequest(
            tenantID: tenantID,
            embeds: [.charges, .charges_ChargeType, .payments, .paymentReversals],
            fields: [.charges, .payments, .paymentReversals]
        )
        do {
            return try await RMAPIClient.shared.send(request)
        } catch {
            print("❌ TransactionRepository fetchTransactions(\(tenantID)) failed: \(error.localizedDescription)")
            return nil
        }
    }
}
