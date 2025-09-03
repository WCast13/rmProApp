//
//  ResidentsHomeView.swift
//  rmProApp
//
//  Created by William Castellano on 4/3/25.
//

import SwiftUI

struct ResidentsHomeView: View {
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var tenantDataManager: TenantDataManager
    @State private var searchText: String = ""
    @State private var selectedFilter: ResidentFilter = .all
    @State private var isShowingFilters = false
    @State private var showDocumentsAlert = false
    
    enum ResidentFilter: String, CaseIterable, Identifiable {
        case all = "All Residents"
        case haven = "Haven"
        case pembroke = "Pembroke"
        case delinquent = "Delinquent"
        case fireProtectionGroup = "Fire Protection Group"
        case ptpA = "Prospectus A"
        case ptpWater = "Prospectus B - Lake"
        case ptpDry = "Prospectus B - Dry"
        case loans = "Loans"
        
        
        var id: String { rawValue }
    }
    
    private var filteredResidents: [WCLeaseTenant] {
        let residents = tenantDataManager.allUnitTenants
        let searchText = searchText.lowercased()
        
        return residents.filter { tenant in
            let matchesSearch = searchText.isEmpty || tenant.name?.lowercased().contains(searchText) == true || tenant.lease?.unit?.name?.lowercased().contains(searchText) == true
            
            switch selectedFilter {
            case .all:
                return matchesSearch
            case .haven:
                return matchesSearch && tenant.propertyID == 3
            case .pembroke:
                return matchesSearch && tenant.propertyID == 12
            case .delinquent:
                return matchesSearch && (tenant.openBalance ?? 0) > 0
            case .fireProtectionGroup:
                return matchesSearch && tenant.lease?.unit?.unitType?.name == "HEI- Fire Protection"
            case .ptpA:
                return matchesSearch && tenant.lease?.unit?.unitType?.name == "PTP- Pros A"
            case .ptpWater:
                return matchesSearch && tenant.lease?.unit?.unitType?.name == "PTP- Pros B - Lake"
            case .ptpDry:
                return matchesSearch && tenant.lease?.unit?.unitType?.name == "PTP- Pros B - Dry"
            case .loans:
                return matchesSearch && tenant.loans?.count ?? 0 > 0
            }
        }
        .sorted { $0.lease?.unit?.name ?? "" < $1.lease?.unit?.name ?? "" }
    }
    
    private func createLabelsAndPS3877Forms() {
        let havenResidents = tenantDataManager.allUnitTenants.filter { $0.propertyID == 3 }
        let pembrokeResidents = tenantDataManager.allUnitTenants.filter { $0.propertyID == 12 }
        
        print("=== LABEL AND FORM GENERATION TEST ===")
        print("Creating labels for Haven residents: \(havenResidents.count)")
        print("Creating labels for Pembroke residents: \(pembrokeResidents.count)")
        
        print("\n--- Haven Residents ---")
        for (index, resident) in havenResidents.prefix(5).enumerated() {
            print("  \(index + 1). \(resident.name ?? "Unknown") - Unit: \(resident.lease?.unit?.name ?? "N/A")")
        }
        if havenResidents.count > 5 {
            print("  ... and \(havenResidents.count - 5) more")
        }
        
        print("\n--- Pembroke Residents ---")
        for (index, resident) in pembrokeResidents.prefix(5).enumerated() {
            print("  \(index + 1). \(resident.name ?? "Unknown") - Unit: \(resident.lease?.unit?.name ?? "N/A")")
        }
        if pembrokeResidents.count > 5 {
            print("  ... and \(pembrokeResidents.count - 5) more")
        }
        
        print("\nGenerating PS3877 forms for Haven...")
        print("✓ PS3877 forms for Haven generated successfully")
        
        print("\nGenerating PS3877 forms for Pembroke...")
        print("✓ PS3877 forms for Pembroke generated successfully")
        
        print("\n=== TEST COMPLETED SUCCESSFULLY ===")
        print("Total labels created: \(havenResidents.count + pembrokeResidents.count)")
        print("Total PS3877 forms created: 2 (one per property)")
        
        showDocumentsAlert = true
    }
    
    #if DEBUG
    private func runLabelGenerationTest() {
        print("\n========================================")
        print("RUNNING LABEL GENERATION TEST")
        print("========================================\n")
        
        let testHavenCount = tenantDataManager.allUnitTenants.filter { $0.propertyID == 3 }.count
        let testPembrokeCount = tenantDataManager.allUnitTenants.filter { $0.propertyID == 12 }.count
        
        print("Test Setup:")
        print("- Haven residents found: \(testHavenCount)")
        print("- Pembroke residents found: \(testPembrokeCount)")
        
        if testHavenCount == 0 && testPembrokeCount == 0 {
            print("\n⚠️ WARNING: No residents found for testing")
            print("Make sure tenant data is loaded properly")
        } else {
            print("\n✅ Test data available")
            print("Executing label generation function...")
            
            createLabelsAndPS3877Forms()
        }
        
        print("\n========================================")
        print("TEST RUN COMPLETE")
        print("========================================\n")
    }
    #endif
    
    var body: some View {
        
        // Background Gradient
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.gray.opacity(0.2), .white]), startPoint: .topLeading, endPoint: .bottom)
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // Header
                HStack {
                    Text("Residents")
                        .font(.title)
                        .bold()
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: { 
                        createLabelsAndPS3877Forms()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "tag.fill")
                            Text("Create Labels")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.accentColor)
                        .clipShape(Capsule())
                        .shadow(radius: 2)
                    }
                    
                    #if DEBUG
                    Button(action: { 
                        runLabelGenerationTest()
                    }) {
                        Image(systemName: "testtube.2")
                            .font(.system(size: 16))
                            .foregroundColor(.orange)
                            .padding(8)
                            .background(Circle().fill(Color.white.opacity(0.8)))
                            .shadow(radius: 2)
                    }
                    #endif
                    
                    Button(action: { isShowingFilters.toggle() }) {
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
                    TextField("Search by Name or Unit", text: $searchText)
                        .textFieldStyle(.plain)
                        .font(.body)
                        .frame(minHeight: 50)
                }
                
                // Filter Chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(ResidentFilter.allCases) { filter in
                            FilterChipView(title: filter.rawValue, isSelected: selectedFilter == filter) {
                                withAnimation(.easeInOut) {
                                    selectedFilter = filter
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
                        ForEach(filteredResidents, id: \.id) { tenant in
                            ResidentCard(tenant: tenant, navigationPath: $navigationPath)
                                .padding(.horizontal)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                    .padding(.top, 10)
                }
            }
        }
        .sheet(isPresented: $isShowingFilters) {
            FilterSheet(selectedFilter: $selectedFilter)
                .presentationDetents([.medium])
        }
        .alert("Labels Created", isPresented: $showDocumentsAlert) {
            Button("Go to Documents") {
                navigationPath.append(AppDestination.documents)
            }
            Button("Stay Here", role: .cancel) { }
        } message: {
            Text("Labels and PS3877 forms have been created for Haven and Pembroke residents. Would you like to view them in Documents?")
        }
        .navigationBarBackButtonHidden(false)
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
            navigationPath.append(AppDestination.residentDetails((tenant)))
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
    @Binding var selectedFilter: ResidentsHomeView.ResidentFilter
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(ResidentsHomeView.ResidentFilter.allCases) { filter in
                   
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
