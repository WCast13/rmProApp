//
//  MailingsHomeView.swift
//  rmProApp
//
//  Mailings home: pick a property, name the file, generate the
//  Avery 5160 label PDF or the USPS PS Form 3877 firm mailing book.
//  Generated files land in the app's Documents folder; the Documents
//  sub-destination lists them.
//

import SwiftUI

struct MailingsHomeView: View {
    @Binding var navigationPath: NavigationPath
    @State private var viewModel = MailingsViewModel()

    var body: some View {
        Form {
            propertySection
            fileNameSection
            actionsSection
            resultSection
            documentsSection
        }
        .navigationTitle("Mailings")
    }

    // MARK: - Sections

    private var propertySection: some View {
        Section("Property") {
            Picker("Property", selection: $viewModel.selectedProperty) {
                ForEach(MailingsViewModel.Property.allCases) { property in
                    Text(property.title).tag(property)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var fileNameSection: some View {
        Section {
            TextField("File name (optional)", text: $viewModel.fileName)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
        } header: {
            Text("File")
        } footer: {
            Text("Leave blank to use the property name and today's date.")
                .font(DSTypography.caption)
                .foregroundColor(DSColor.secondary)
        }
    }

    private var actionsSection: some View {
        Section("Generate") {
            Button {
                Task { await viewModel.generateLabels() }
            } label: {
                Label("Generate Avery 5160 Labels", systemImage: "tag.fill")
            }
            .disabled(viewModel.isGenerating)

            Button {
                Task { await viewModel.generatePS3877() }
            } label: {
                Label("Generate PS Form 3877", systemImage: "list.bullet.rectangle")
            }
            .disabled(viewModel.isGenerating)
        }
    }

    @ViewBuilder
    private var resultSection: some View {
        if viewModel.isGenerating {
            Section {
                HStack(spacing: DSSpacing.m) {
                    ProgressView()
                    Text("Generating PDF…")
                        .font(DSTypography.subheadline)
                        .foregroundColor(DSColor.secondary)
                }
            }
        } else if let result = viewModel.lastResult {
            Section("Last Generated") {
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    Text(result.url.lastPathComponent)
                        .font(DSTypography.subheadlineBold)
                    Text(result.url.deletingLastPathComponent().path)
                        .font(DSTypography.caption)
                        .foregroundColor(DSColor.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }
        } else if let error = viewModel.lastError {
            Section("Error") {
                Text(error)
                    .font(DSTypography.subheadline)
                    .foregroundColor(DSColor.destructive)
            }
        }
    }

    private var documentsSection: some View {
        Section {
            NavigationLink(value: MailingsDestination.documents) {
                Label("View Generated Documents", systemImage: "folder.fill")
            }
        }
    }
}
