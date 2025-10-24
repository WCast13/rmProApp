//
//  SwiftUIView.swift
//  rmProApp
//
//  Created by William Castellano on 4/2/25.
//

import SwiftUI
import SwiftData

struct RentIncreaseNoticeBuilder: View {
    @Binding var navigationPath: NavigationPath
    @State private var communities: [String] = ["Haven Lake Estates", "Pembroke Park Lakes"]
    @State private var selectedCommunity: String = "Haven Lake Estates"
    @State private var nameOfFile: String = ""
    @State private var allUDFs: [RMUserDefinedValue] = []
    @State private var selectedUDFId: Int?
    
    var body: some View {
        
            VStack {
//                HomeButton(title: "Labels & PS3877 (Legacy ContentView)", destination: AppDestination.contentView)
                HomeButton(title: "Completed Labels and ps3877 Form", destination: AppDestination.documents)
                
                Text("Create Rent Increase Notice")
                
                Form {
                    Picker("Community", selection: $selectedCommunity) {
                        ForEach(communities, id: \.self) { community in
                            Text(community).tag(community)
                        }
                    }
                    TextField("Name of File", text: $nameOfFile)
                    
                    if selectedCommunity == "Haven Lake Estates" {
                        Picker("UDF", selection: $selectedUDFId) {
                            Text("Select a UDF").tag(nil as Int?)
                            ForEach(allUDFs, id: \.userDefinedFieldID) { udf in
                                Text(udf.name ?? "Unnamed").tag(udf.userDefinedFieldID as Int?)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
            .navigationTitle("Home")
        
        .onAppear() {
            Task {
                // Use the new cached UDF system
                allUDFs = RMDataManager.shared.getCachedUDFs(for: "Unit")

                // If no cached UDFs, fallback to API
                if allUDFs.isEmpty {
                    print("No cached Unit UDFs found, loading from API...")
                    let freshUDFs = await RMDataManager.shared.loadUserDefinedValues()
                    allUDFs = freshUDFs.filter { $0.parentType == "Unit" }
                }

                // Initialize selectedUDFId with first UDF if available
                if selectedUDFId == nil && !allUDFs.isEmpty {
                    selectedUDFId = allUDFs.first?.userDefinedFieldID
                }

                print("📋 Loaded \(allUDFs.count) Unit UDFs for picker")
            }
        }
    }
}

/*
 Update this ????? to be compatable with UnitTypes, Recurring Charges, Vendors, Loans
 */
