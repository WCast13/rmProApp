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
                    .font(.title)
                    .bold()
                    .foregroundColor(.primary)

                Spacer()

                Button(action: { viewModel.isShowingFilters.toggle() }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title2)
                        .foregroundColor(.accentColor)
                        .padding(10)
                        .background(Circle().fill(Color.white.opacity(0.8)))
                        .shadow(radius: 2)
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)

            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search by Name or Unit", text: $viewModel.searchText)
                    .textFieldStyle(.plain)
                    .font(.body)
                    .frame(minHeight: 50)
            }

            // Filter Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(ResidentsListViewModel.Filter.allCases) { filter in
                        FilterChipView(title: filter.rawValue, isSelected: viewModel.selectedFilter == filter) {
                            withAnimation(.easeInOut) {
                                viewModel.selectedFilter = filter
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
            }

            // Residents List
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.filteredTenants, id: \.id) { tenant in
                        ResidentCard(tenant: tenant, navigationPath: $navigationPath)
                            .padding(.horizontal)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .padding(.top, 10)
            }
        }
        .sheet(isPresented: $viewModel.isShowingFilters) {
            FilterSheet(selectedFilter: $viewModel.selectedFilter)
                .presentationDetents([.medium])
        }
    }
}


// MARK: View Helpers
// Filter Chip
struct FilterChipView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : .gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(.capsule)
        }
    }
}

// Resident Card
struct ResidentCard : View {
    let tenant: WCLeaseTenant
    @Binding var navigationPath: NavigationPath

    var body: some View {
        Button(action: {
            navigationPath.append(ResidentsDestination.residentDetail(tenant))
        }) {
            HStack(alignment: .top, spacing: 12) {
                //Initials Circle
                ZStack {
                    Circle()
                        .fill( LinearGradient(colors: [.blue, .black], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 50, height: 50)
                    Text(initials(from: tenant.name ?? "N/A"))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }

                // Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(tenant.name ?? "N/A")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.red)

                    if let unitName = tenant.lease?.unit?.name {
                        Text("Unit: \(unitName)")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.green)
                    }

                    if let balance = tenant.openBalance, balance > 0 {
                        Text("Balance: $\(balance)")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.red)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.system(size: 16))
            }
        }
        .padding()
        .background( RoundedRectangle(cornerRadius: 12)
            .fill(Color.white)
            .shadow(radius: 2))
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
        NavigationView {
            List {
                ForEach(ResidentsListViewModel.Filter.allCases) { filter in
                    Button(action: {
                        selectedFilter = filter
                        dismiss()
                    }) {
                        HStack {
                            Text(filter.rawValue)
                                .foregroundColor(.primary)
                            Spacer()
                            if selectedFilter == filter {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}
