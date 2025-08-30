//
//  ViolationBuilderView.swift
//  rmProApp
//
//  Created by William Castellano on 4/4/25.
//

import SwiftUI

struct ViolationBuilderView: View {
    @Binding var navigationPath: NavigationPath
    
    @State var unit: RMUnit
    @State private var selectedDate: Date = Date()
    @State private var violationsArray: [String] = []
    @State private var violation: String = ""
    @State private var fixesText: String = ""
    
    var body: some View {
        
        Form {
            // Tenant Information Section
            Section {
                HStack {
                    Text("Tenant Name:")
                    Text(unit.currentOccupants?.first?.name ?? "")
                }
                
                HStack {
                    Text("Lot Number:")
                    Text(unit.name ?? "")
                }
            } header: {
                Text("Tenant Information")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Section {
                DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                
            } header: {
                Text("Notice Date")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            // Violation Bullet Points Section
            Section {
                HStack {
                    TextField("Add Violation", text: $violation)
                                        .padding()
                    
                    Button("Add") {
                        if !violation.isEmpty {
                            violationsArray.append(violation)
                            violation = ""
                        }
                    }
                }
            
                ForEach(violationsArray, id: \.self) { violation in
                    Text("• \(violation)")
                }
            } header: {
                Text("Violations Observed")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Section {
                TextEditor(text: $fixesText)
                    .frame(minHeight: 100)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    }
            } header: {
                Text("How to Fix Violations")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .navigationTitle("Violation Notice")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    // Save function here
                    // Build word document from template
                    // Email Document
                }
            }
        }
    }
}

//#Preview {
//    ViolationBuilderView()
//}
