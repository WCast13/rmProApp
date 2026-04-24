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
    @State private var viewModel: ResidentDetailViewModel

    init(navigationPath: Binding<NavigationPath>, tenant: WCLeaseTenant) {
        self._navigationPath = navigationPath
        self._viewModel = State(initialValue: ResidentDetailViewModel(tenant: tenant))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HeaderView(tenant: viewModel.tenant)
                InformationCard(tenant: viewModel.tenant)
                AddressesCard(tenant: viewModel.tenant)
                ContactsCard(contacts: viewModel.tenant.contacts ?? [])
                LeaseCard(
                    leases: viewModel.tenant.allLeases ?? [],
                    recurringCharges: viewModel.tenant.allLeases?.first?.unit?.unitType?.recurringCharges ?? []
                )
                TransactionsCard(
                    transactions: viewModel.tenant.transactions ?? [],
                    isLoading: viewModel.isLoadingTransactions
                )
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Resident Details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadTransactions()
        }
    }
}
