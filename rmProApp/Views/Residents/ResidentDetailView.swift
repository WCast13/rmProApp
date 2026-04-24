//
//  ResidentDetailView.swift
//  rmProApp
//
//  Resident detail screen. Owns a ResidentDetailViewModel that loads
//  the merged transaction timeline; cards read from the view model's
//  tenant reference.
//

import SwiftUI

struct ResidentDetailView: View {
    @Binding var navigationPath: NavigationPath
    @State private var viewModel: ResidentDetailViewModel

    init(navigationPath: Binding<NavigationPath>, tenant: WCLeaseTenant) {
        self._navigationPath = navigationPath
        self._viewModel = State(initialValue: ResidentDetailViewModel(tenant: tenant))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: DSSpacing.xl) {
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
            .padding(.horizontal, DSSpacing.l)
            .padding(.bottom, DSSpacing.xl)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Resident Details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadTransactions()
        }
    }
}
