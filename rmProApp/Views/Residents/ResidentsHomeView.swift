//
//  ResidentsHomeView.swift
//  rmProApp
//
//  Created by William Castellano on 4/3/25.
//

import SwiftUI

struct ResidentsHomeView: View {
    @Binding var navigationPath: NavigationPath
    @Environment(TenantDataManager.self) private var tenantDataManager
    @State private var viewModel: ResidentsListViewModel?

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.gray.opacity(0.2), .white]),
                startPoint: .topLeading,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            if let viewModel {
                content(viewModel: viewModel)
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = ResidentsListViewModel(tenantDataManager: tenantDataManager)
            }
        }
        .navigationBarBackButtonHidden(false)
    }

    @ViewBuilder
    private func content(viewModel: ResidentsListViewModel) -> some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Residents")
                    .font(DSTypography.title)
                    .foregroundColor(DSColor.primary)

                Spacer()

                Button(action: { viewModel.isShowingFilters.toggle() }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title2)
                        .foregroundColor(DSColor.accent)
                        .padding(DSSpacing.m)
                        .background(Circle().fill(Color.white.opacity(0.8)))
                        .shadow(radius: 2)
                }
            }
            .padding(.horizontal, DSSpacing.l)
            .padding(.top, DSSpacing.m)

            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(DSColor.secondary)
                TextField("Search by Name or Unit", text: $viewModel.searchText)
                    .textFieldStyle(.plain)
                    .font(DSTypography.body)
                    .frame(minHeight: 50)
            }
            .padding(.horizontal, DSSpacing.l)

            // Filter Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.m) {
                    ForEach(ResidentsListViewModel.Filter.allCases) { filter in
                        FilterChip(title: filter.rawValue, isSelected: viewModel.selectedFilter == filter) {
                            withAnimation(.easeInOut) {
                                viewModel.selectedFilter = filter
                            }
                        }
                    }
                }
                .padding(.horizontal, DSSpacing.l)
                .padding(.vertical, DSSpacing.xs)
            }

            // Residents list / empty state
            if viewModel.filteredTenants.isEmpty {
                EmptyStateView(
                    systemImage: "person.3.sequence",
                    title: "No Residents Match",
                    message: "Try clearing the filter or searching a different name or unit."
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: DSSpacing.m) {
                        ForEach(viewModel.filteredTenants, id: \.id) { tenant in
                            ResidentCard(tenant: tenant, navigationPath: $navigationPath)
                                .padding(.horizontal, DSSpacing.l)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                    .padding(.top, DSSpacing.m)
                }
                .refreshable {
                    await tenantDataManager.fetchTenants(forceRefresh: true)
                }
            }
        }
        .sheet(isPresented: $viewModel.isShowingFilters) {
            FilterSheet(selectedFilter: $viewModel.selectedFilter)
                .presentationDetents([.medium])
        }
    }
}


// MARK: - Resident Card
struct ResidentCard: View {
    let tenant: WCLeaseTenant
    @Binding var navigationPath: NavigationPath

    var body: some View {
        Button(action: {
            navigationPath.append(ResidentsDestination.residentDetail(tenant))
        }) {
            HStack(alignment: .top, spacing: DSSpacing.m) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [.blue, .black],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 50, height: 50)
                    Text(initials(from: tenant.name ?? "N/A"))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    Text(tenant.name ?? "N/A")
                        .font(DSTypography.subheadlineBold)
                        .foregroundColor(DSColor.primary)

                    if let unitName = tenant.lease?.unit?.name {
                        Text("Unit: \(unitName)")
                            .font(DSTypography.caption)
                            .foregroundColor(DSColor.secondary)
                    }

                    if let balance = tenant.openBalance, balance > 0 {
                        Text("Balance: $\(balance)")
                            .font(DSTypography.subheadlineBold)
                            .foregroundColor(DSColor.destructive)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(DSColor.secondary)
                    .font(.system(size: 16))
            }
        }
        .padding(DSSpacing.l)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.medium)
                .fill(Color.white)
                .shadow(radius: 2)
        )
    }
}

private func initials(from name: String) -> String {
    let components = name.split(separator: " ")
    let initials = components.prefix(2).map { $0.first?.uppercased() ?? "" }.joined()
    return initials.isEmpty ? "N/A" : initials
}

struct FilterSheet: View {
    @Binding var selectedFilter: ResidentsListViewModel.Filter
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(ResidentsListViewModel.Filter.allCases) { filter in
                    Button(action: {
                        selectedFilter = filter
                        dismiss()
                    }) {
                        HStack {
                            Text(filter.rawValue)
                                .foregroundColor(DSColor.primary)
                            Spacer()
                            if selectedFilter == filter {
                                Image(systemName: "checkmark")
                                    .foregroundColor(DSColor.positive)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
