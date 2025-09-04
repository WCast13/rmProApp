//
//  ContentView.swift
//  rmProApp
//
//  Created by William Castellano on 8/7/24.
//

import SwiftUI
import Combine
import MessageUI

struct ContentView: View {
    //    @State private var properties: [RMProperty]?
    @State private var tenants: [RMTenant]?
    @State private var units: [RMUnit]?
    //    @State private var contacts: [RMContact]?
    @State private var community: String = "Haven Lake Estates"
    @Binding var navigationPath: NavigationPath
    
    // MARK: - Mail Composer State
    @State private var isShowingMailComposer = false
    @State private var mailData = MailData(
        recipients: ["wc@t4mgt.com"],
        subject: "Labels",
        body: "\(Date.now)"
    )
    @State private var mailAttachments: [URL] = []
    @State private var showMailUnavailableAlert = false
    
    var body: some View {
        // Need segmented Control to Filter Units by Type
        // Haven or Pembroke
        // Sorted by Group or Unit
        VStack {
            HStack {
                Spacer()
                Button("Haven Labels") {
                    // Prepare data
                    let filteredUnits = units?.filter { $0.propertyID == 3 }.sorted { ($0.userDefinedValues?.last?.value)! > ($1.userDefinedValues?.last?.value)! }
                    let filteredTenants = tenants?.filter { $0.propertyID == 3 }
                    
                    // File locations
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let pdfURL = documentsDirectory.appendingPathComponent("HavenFINAL2.pdf")
                    let templateURL = Bundle.main.url(forResource: "Avery 5160 Template PDF", withExtension: "pdf")!
                    
                    // Generate Labels PDF
                    if let filteredUnits = filteredUnits, let filteredTenants = filteredTenants {
                        LabelGeneratorManager.shared.generatePDFLabels(units: filteredUnits, tenants: filteredTenants, saveTo: pdfURL, templatePDF: templateURL)
                    }
                    
                    // PS3877
                    let ps3877templateURL = Bundle.main.url(forResource: "ps3877", withExtension: "pdf")!
                    let ps3877PdfURL = documentsDirectory.appendingPathComponent("Filled_PS_Form_3877.pdf")
                    
                    if let filteredUnits = filteredUnits, let filteredTenants = filteredTenants {
                        PS3877FormManager.shared.create3877Form(units: filteredUnits, tenants: filteredTenants, saveTo: ps3877PdfURL, templatePDF: ps3877templateURL)
                    }
                    
                    print("PDF generated at: \(pdfURL)")
                    
                    // CSV (optional)
                    let csvURL = documentsDirectory.appendingPathComponent("Units.csv")
                    if let filteredUnits = filteredUnits, let filteredTenants = filteredTenants {
                        LabelGeneratorManager.shared.generateCSVFile(units: filteredUnits, tenants: filteredTenants, saveTo: csvURL)
                    }
                    
                    // Prepare email
                    var attachments: [URL] = []
                    if FileManager.default.fileExists(atPath: pdfURL.path) { attachments.append(pdfURL) }
                    if FileManager.default.fileExists(atPath: ps3877PdfURL.path) { attachments.append(ps3877PdfURL) }
                    if FileManager.default.fileExists(atPath: csvURL.path) { attachments.append(csvURL) }
                    
                    presentEmail(
                        subject: "Haven Labels and PS3877",
                        body: "Attached are the generated mailing labels and PS Form 3877 for Haven.",
                        attachments: attachments
                    )
                }
                
                Spacer()
                
                Button("Pembroke Labels") {
                    let filteredUnits = units?.filter { $0.propertyID == 12 }.sorted { ($0.unitType?.unitTypeID)! < ($1.unitType?.unitTypeID)! }
                    let filteredTenants = tenants?.filter { $0.propertyID == 12 }
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let pdfURL = documentsDirectory.appendingPathComponent("PembrokeUnitLabels- \(Date.now.formatted(date: .abbreviated, time: .shortened)).pdf")
                    let templateURL = Bundle.main.url(forResource: "Avery 5160 Template PDF", withExtension: "pdf")!
                    
                    if let filteredUnits = filteredUnits, let filteredTenants = filteredTenants {
                        LabelGeneratorManager.shared.generatePDFLabels(units: filteredUnits, tenants: filteredTenants, saveTo: pdfURL, templatePDF: templateURL)
                    }
                    
                    print("PDF generated at: \(pdfURL)")
                    
                    // Optional: If you also want a PS3877 for Pembroke, uncomment and ensure template fits
                    // let ps3877templateURL = Bundle.main.url(forResource: "ps3877", withExtension: "pdf")!
                    // let ps3877PdfURL = documentsDirectory.appendingPathComponent("Filled_PS_Form_3877_Pembroke.pdf")
                    // if let filteredUnits = filteredUnits, let filteredTenants = filteredTenants {
                    //     PS3877FormManager.shared.create3877Form(units: filteredUnits, tenants: filteredTenants, saveTo: ps3877PdfURL, templatePDF: ps3877templateURL)
                    // }
                    
                    // Prepare email
                    var attachments: [URL] = []
                    if FileManager.default.fileExists(atPath: pdfURL.path) { attachments.append(pdfURL) }
                    // if FileManager.default.fileExists(atPath: ps3877PdfURL.path) { attachments.append(ps3877PdfURL) }
                    
                    presentEmail(
                        subject: "Pembroke Labels",
                        body: "Attached are the generated mailing labels for Pembroke.",
                        attachments: attachments
                    )
                }
                Spacer()
            }
            
            if let units = units {
                List(units) { unit in
                    MailingLabelView(unit: unit)
                }
            } else {
                ProgressView("Loading Units...")
            }
        }
        .onAppear {
            Task {
                
                //                 properties = await RentManagerAPIClient.shared.request(endpoint: .properties, responseType: [RMProperty].self)
                
                // Build Tenants URL using URLBuilder
                let tenantEmbeds = ["Contacts", "UserDefinedValues"].joined(separator: ",")
                let tenantFields = ["Contacts", "Name", "PropertyID", "TenantID", "UserDefinedValues"].joined(separator: ",")
                let tenantFilters = [RMFilter(key: "PropertyID", operation: "eq", value: "3")]
                
                let tenantsURL = URLBuilder.shared.buildURL(
                    endpoint: .tenants,
                    embeds: tenantEmbeds,
                    fields: tenantFields,
                    filters: tenantFilters,
                    pageSize: 20000
                )
                
                // Build Units URL using URLBuilder
                let unitEmbeds = ["CurrentOccupants", "PrimaryAddress", "Property.Addresses", "UnitType", "Leases", "Leases.Tenant", "UserDefinedValues"].joined(separator: ",")
                let unitFields = ["CurrentOccupants", "Name", "PrimaryAddress", "PropertyID", "UnitType", "Leases", "UserDefinedValues"].joined(separator: ",")
                let unitFilters = [RMFilter(key: "PropertyID", operation: "in", value: "3")]
                
                let unitsURL = URLBuilder.shared.buildURL(
                    endpoint: .units,
                    embeds: unitEmbeds,
                    fields: unitFields,
                    filters: unitFilters
                )
                
                if let tenantsURL = tenantsURL {
                    tenants = await RentManagerAPIClient.shared.request(url: tenantsURL, responseType: [RMTenant].self)
                }
                
                if let unitsURL = unitsURL {
                    units = await RentManagerAPIClient.shared.request(url: unitsURL, responseType: [RMUnit].self)
                }
            }
        }
        .sheet(isPresented: $isShowingMailComposer) {
            MailComposeView(isPresented: $isShowingMailComposer, data: mailData, attachments: mailAttachments)
        }
        .alert("Mail Unavailable", isPresented: $showMailUnavailableAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Mail services are not available on this device.")
        }
    }
    
    // MARK: - Email Helper
    private func presentEmail(subject: String, body: String, attachments: [URL]) {
        if MailComposeView.canSendMail {
            mailData = MailData(
                recipients: ["wc@t4mgt.com"],
                subject: subject,
                body: body
            )
            mailAttachments = attachments
            isShowingMailComposer = true
        } else {
            // Fallback: could present a share sheet instead, for now show alert
            showMailUnavailableAlert = true
        }
    }
}

// MARK: - Mail Compose Wrapper
struct MailData {
    var recipients: [String]
    var subject: String
    var body: String
}

struct MailComposeView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var data: MailData
    var attachments: [URL] = []
    
    static var canSendMail: Bool {
        MFMailComposeViewController.canSendMail()
    }
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setToRecipients(data.recipients)
        vc.setSubject(data.subject)
        vc.setMessageBody(data.body, isHTML: false)
        
        for url in attachments {
            if let fileData = try? Data(contentsOf: url) {
                let mime = mimeType(for: url)
                vc.addAttachmentData(fileData, mimeType: mime, fileName: url.lastPathComponent)
            }
        }
        
        vc.mailComposeDelegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var isPresented: Bool
        
        init(isPresented: Binding<Bool>) {
            _isPresented = isPresented
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            controller.dismiss(animated: true) {
                self.isPresented = false
            }
        }
    }
    
    private func mimeType(for url: URL) -> String {
        switch url.pathExtension.lowercased() {
        case "pdf": return "application/pdf"
        case "csv": return "text/csv"
        case "txt": return "text/plain"
        default:    return "application/octet-stream"
        }
    }
}

/*
 UNITS ITERATION- For Labels
 
 https://trieq.api.rentmanager.com/Units?embeds=CurrentOccupants,PrimaryAddress,Property.Addresses,UnitType,Leases,Leases.Tenant&filters=PropertyID,in,(3%2C12)&fields=CurrentOccupants,Name,PrimaryAddress,PropertyID,UnitType,Leases")
 
 /Units?embeds=CurrentOccupants,PrimaryAddress,Property.Addresses,UnitType&filters=Property.IsActive,eq,true&fields=CurrentOccupants,Name,PrimaryAddress,PropertyID,UnitType
 
 /Units?embeds=CurrentOccupants,PrimaryAddress,Property.Addresses,UnitType,Leases,Leases.Tenant&filters=PropertyID,in,(3%2C12)&fields=CurrentOccupants,Name,PrimaryAddress,PropertyID,UnitType,Leases
 
 /Units?embeds=Leases,Leases.Tenant&fields=Leases,Name
 */

