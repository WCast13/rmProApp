//
//  MailingsViewModel.swift
//  rmProApp
//
//  State + actions for the Mailings tab home screen. Pulls units +
//  tenants from the repositories, filters them to the selected
//  property, and hands them to LabelGeneratorManager /
//  PS3877FormManager. Generated PDFs land in the documents directory.
//

import Foundation

@Observable
@MainActor
final class MailingsViewModel {
    enum Property: Int, Hashable, Identifiable, CaseIterable {
        case haven = 3
        case pembroke = 12

        var id: Int { rawValue }

        var title: String {
            switch self {
            case .haven: return "Haven Lake Estates"
            case .pembroke: return "Pembroke Park Lakes"
            }
        }
    }

    enum OutputKind {
        case labels, ps3877
    }

    struct GenerationResult: Equatable {
        let kind: OutputKind
        let url: URL
    }

    enum GenerationError: LocalizedError {
        case missingTemplate(String)
        case emptyUnits
        case writeFailed

        var errorDescription: String? {
            switch self {
            case .missingTemplate(let name): return "Template \"\(name)\" is missing from the app bundle."
            case .emptyUnits: return "No units found for the selected property."
            case .writeFailed: return "Failed to write the PDF to the documents directory."
            }
        }
    }

    var selectedProperty: Property = .haven
    var fileName: String = ""
    var isGenerating: Bool = false
    var lastResult: GenerationResult?
    var lastError: String?

    /// Generate Avery 5160 rent-increase labels for the selected property.
    func generateLabels() async {
        await runGeneration(kind: .labels) { units, tenants, outputURL in
            guard let template = Bundle.main.url(forResource: "Avery 5160 Template PDF", withExtension: "pdf") else {
                throw GenerationError.missingTemplate("Avery 5160 Template PDF")
            }
            LabelGeneratorManager.shared.generatePDFLabels(
                units: units,
                tenants: tenants,
                saveTo: outputURL,
                templatePDF: template
            )
        }
    }

    /// Generate the USPS PS Form 3877 firm-mailing book for the selected property.
    func generatePS3877() async {
        await runGeneration(kind: .ps3877) { units, tenants, outputURL in
            guard let template = Bundle.main.url(forResource: "ps3877", withExtension: "pdf") else {
                throw GenerationError.missingTemplate("ps3877")
            }
            PS3877FormManager.shared.create3877Form(
                units: units,
                tenants: tenants,
                saveTo: outputURL,
                templatePDF: template
            )
        }
    }

    // MARK: - Pipeline

    private func runGeneration(
        kind: OutputKind,
        render: (_ units: [RMUnit], _ tenants: [RMTenant], _ outputURL: URL) throws -> Void
    ) async {
        isGenerating = true
        lastError = nil
        defer { isGenerating = false }

        do {
            let (units, tenants) = try await loadData()
            guard !units.isEmpty else { throw GenerationError.emptyUnits }
            let outputURL = try makeOutputURL(kind: kind)
            try render(units, tenants, outputURL)
            guard FileManager.default.fileExists(atPath: outputURL.path) else {
                throw GenerationError.writeFailed
            }
            lastResult = GenerationResult(kind: kind, url: outputURL)
        } catch let error as GenerationError {
            lastError = error.errorDescription
        } catch {
            lastError = error.localizedDescription
        }
    }

    private func loadData() async throws -> (units: [RMUnit], tenants: [RMTenant]) {
        async let unitsTask = UnitRepository.shared.syncUnits(.full)
        async let tenantsTask = TenantRepository.shared.syncFull()
        let allUnits = await unitsTask
        let allTenants = await tenantsTask

        let filteredUnits = allUnits
            .filter { $0.propertyID == selectedProperty.rawValue }
            .filter { $0.unitType?.name != "Loan" }
            .sorted { ($0.name ?? "") < ($1.name ?? "") }

        return (filteredUnits, allTenants)
    }

    private func makeOutputURL(kind: OutputKind) throws -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let base = fileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? defaultBaseName()
            : fileName.trimmingCharacters(in: .whitespacesAndNewlines)
        let suffix = kind == .labels ? "Labels" : "PS3877"
        return docs.appendingPathComponent("\(base)_\(suffix).pdf")
    }

    private func defaultBaseName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "\(selectedProperty.title) \(formatter.string(from: Date()))"
    }
}
