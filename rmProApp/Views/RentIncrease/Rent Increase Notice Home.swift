//
//  SwiftUIView.swift
//  rmProApp
//
//  Created by William Castellano on 4/2/25.
//

import SwiftUI

struct RentIncreaseNoticeBuilder: View {
    @Binding var navigationPath: NavigationPath
    @State private var communities: [String] = ["Haven Lake Estates", "Pembroke Park Lakes"]
    @State private var selectedCommunity: String = "Haven Lake Estates"
    @State private var nameOfFile: String = ""
    @State private var allUDFs: [RMUserDefinedValue] = []
    @State private var selectedUDFId: Int = 0
    
    var body: some View {
        
        NavigationStack(path: $navigationPath) {
            VStack {
                HomeButton(title: "Labels & PS3877 (Legacy ContentView)", destination: AppDestination.contentView)
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
                            ForEach(allUDFs) { udf in
                                Text(udf.name ?? "").tag(udf.userDefinedValueID)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
            .navigationTitle("Home")
        }
        .onAppear() {
            Task {
                allUDFs = try! SwiftDataManager.shared.load(
                    of: RMUserDefinedValue.self,
                    where: #Predicate { $0.parentType == "Tenant" }
                )
                
                if allUDFs.isEmpty {
                    allUDFs = await RMDataManager.shared.loadUserDefinedValues()
                    try? SwiftDataManager.shared.save(allUDFs)
                    
                }
            }
        }
    }
}
