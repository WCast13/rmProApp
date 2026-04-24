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
    @Environment(TenantDataManager.self) private var tenantDataManager
    @State var tenant: WCLeaseTenant
    @State private var isLoadingTransactions = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HeaderView(tenant: tenant)
                InformationCard(tenant: tenant)
                AddressesCard(tenant: tenant)
                ContactsCard(contacts: tenant.contacts ?? [])
                LeaseCard(
                    leases: tenant.allLeases ?? [],
                    recurringCharges: tenant.allLeases?.first?.unit?.unitType?.recurringCharges ?? []
                )
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
}
