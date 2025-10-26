//
//  LoanFormSheet.swift
//  rmProApp
//
//  Created by William Castellano on 10/24/25.
//

import SwiftUI

// MARK: - Loan Form Sheet
struct LoanFormSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var unitName: String
    @Binding var originalPrincipal: Double
    @Binding var downPayment: Double
    @Binding var term: Int
    @Binding var paymentAmount: Double
    @Binding var interestRate: Double
    @Binding var closeDate: Date
    @Binding var loanDate: Date
    @Binding var paymentStartDate: Date
    var onSubmit: () -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Loan Information")) {
                    TextField("Loan Name", text: $unitName)

                    HStack {
                        Text("Original Principal")
                        Spacer()
                        TextField("Amount", value: $originalPrincipal, format: .currency(code: "USD"))
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                    }

                    HStack {
                        Text("Down Payment")
                        Spacer()
                        TextField("Amount", value: $downPayment, format: .currency(code: "USD"))
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                    }

                    HStack {
                        Text("Term (months)")
                        Spacer()
                        TextField("Months", value: $term, format: .number)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                    }

                    HStack {
                        Text("Payment Amount")
                        Spacer()
                        TextField("Amount", value: $paymentAmount, format: .currency(code: "USD"))
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                    }

                    HStack {
                        Text("Interest Rate (%)")
                        Spacer()
                        TextField("Rate", value: $interestRate, format: .number.precision(.fractionLength(3)))
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                    }
                }

                Section(header: Text("Dates")) {
                    DatePicker("Close Date", selection: $closeDate, displayedComponents: .date)

                    DatePicker("Loan Date", selection: $loanDate, displayedComponents: .date)

                    DatePicker("Payment Start Date", selection: $paymentStartDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Create Loan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
        
                    Button("Create") {
                        onSubmit()
                    }
                }
            }
        }
    }
}
