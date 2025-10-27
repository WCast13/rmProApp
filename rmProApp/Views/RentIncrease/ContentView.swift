//
//  ContentView.swift
//  rmProApp
//
//  Created by William Castellano on 8/7/24.
//

import SwiftUI
import Combine

struct ContentView: View {

    @State private var tenants: [RMTenant] = []
    @State private var units: [RMUnit] = []
    @State private var community: String = "Haven Lake Estates"
    @State private var isLoading = false
    @State private var errorMessage: String?
    @Binding var navigationPath: NavigationPath

    var body: some View {
        VStack {
            if isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading data...")
                        .font(.headline)
                }
            } else if let error = errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundColor(.red)
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                    Button("Retry") {
                        Task { await loadData() }
                    }
                }
            } else {
                HStack {
                    Spacer()

                    Button("Haven Labels") {
                        generateHavenLabels()
                    }
                    .disabled(units.isEmpty || tenants.isEmpty)

                    Spacer()

                    Button("Pembroke Labels") {
                        generatePembrokeLabels()
                    }
                    .disabled(units.isEmpty || tenants.isEmpty)

                    Spacer()
                }

                Text("Units: \(units.count) | Tenants: \(tenants.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .onAppear {
            Task { await loadData() }
        }
    }

    func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            // Load units
            await RMDataManager.shared.loadUnits()
            units = RMDataManager.shared.unitsWithBasicData

            // Load tenants
            tenants = TenantDataManager.shared.allTenants

            print("✅ Content View - Loaded \(units.count) units and \(tenants.count) tenants")

            if units.isEmpty {
                errorMessage = "No units found"
            }
        } catch {
            errorMessage = "Failed to load data: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func generateHavenLabels() {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("❌ Could not access documents directory")
            return
        }

        guard let templateURL = Bundle.main.url(forResource: "Avery 5160 Template PDF", withExtension: "pdf") else {
            print("❌ Template PDF not found in bundle")
            return
        }

        guard let ps3877templateURL = Bundle.main.url(forResource: "ps3877", withExtension: "pdf") else {
            print("❌ PS3877 Template PDF not found in bundle")
            return
        }

        // Filter Haven units (propertyID == 3)
        let filteredUnits = units
            .filter { $0.propertyID == 3 }
            .sorted { unit1, unit2 in
                // Safe sorting with fallback
                let value1 = unit1.userDefinedValues?.last?.value ?? ""
                let value2 = unit2.userDefinedValues?.last?.value ?? ""
                return value1 > value2
            }

        let filteredTenants = tenants.filter { $0.propertyID == 3 }

        guard !filteredUnits.isEmpty else {
            print("❌ No Haven units found")
            return
        }

        guard !filteredTenants.isEmpty else {
            print("❌ No Haven tenants found")
            return
        }

        print("📄 Generating labels for \(filteredUnits.count) Haven units...")

        // Generate PDFs
        let pdfURL = documentsDirectory.appendingPathComponent("HavenFINAL2.pdf")
        LabelGeneratorManager.shared.generatePDFLabels(
            units: filteredUnits,
            tenants: filteredTenants,
            saveTo: pdfURL,
            templatePDF: templateURL
        )

        let ps3877PdfURL = documentsDirectory.appendingPathComponent("Filled_PS_Form_3877.pdf")
        PS3877FormManager.shared.create3877Form(
            units: filteredUnits,
            tenants: filteredTenants,
            saveTo: ps3877PdfURL,
            templatePDF: ps3877templateURL
        )

        print("✅ Haven labels generated at: \(pdfURL)")
        print("✅ PS3877 form generated at: \(ps3877PdfURL)")
    }

    func generatePembrokeLabels() {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("❌ Could not access documents directory")
            return
        }

        guard let templateURL = Bundle.main.url(forResource: "Avery 5160 Template PDF", withExtension: "pdf") else {
            print("❌ Template PDF not found in bundle")
            return
        }

        guard let ps3877templateURL = Bundle.main.url(forResource: "ps3877", withExtension: "pdf") else {
            print("❌ PS3877 Template PDF not found in bundle")
            return
        }
        
        // Filter Pembroke units (propertyID == 12)
        let filteredUnits = units
            .filter { $0.propertyID == 12 }
            .sorted { unit1, unit2 in
                // Safe sorting with fallback
                let typeID1 = unit1.unitType?.unitTypeID ?? 0
                let typeID2 = unit2.unitType?.unitTypeID ?? 0
                return typeID1 < typeID2
            }

        let filteredTenants = tenants.filter { $0.propertyID == 12 }

        guard !filteredUnits.isEmpty else {
            print("❌ No Pembroke units found")
            return
        }

        guard !filteredTenants.isEmpty else {
            print("❌ No Pembroke tenants found")
            return
        }

        print("📄 Generating labels for \(filteredUnits.count) Pembroke units...")

        let pdfURL = documentsDirectory.appendingPathComponent("PembrokeUnitLabels-\(Date.now.formatted(date: .abbreviated, time: .shortened)).pdf")
        LabelGeneratorManager.shared.generatePDFLabels(
            units: filteredUnits,
            tenants: filteredTenants,
            saveTo: pdfURL,
            templatePDF: templateURL
        )
        
        let ps3877PdfURL = documentsDirectory.appendingPathComponent("Filled_PS_Form_3877.pdf")
        PS3877FormManager.shared.create3877Form(
            units: filteredUnits,
            tenants: filteredTenants,
            saveTo: ps3877PdfURL,
            templatePDF: ps3877templateURL
        )
        

        print("✅ Pembroke labels generated at: \(pdfURL)")
    }
}
