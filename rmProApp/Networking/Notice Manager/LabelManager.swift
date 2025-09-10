//
//  LabelManager.swift
//  rmProApp
//
//  Created by William Castellano on 8/17/24.
//

import PDFKit
import UIKit
import SwiftUI

class LabelGeneratorManager {
    static let shared = LabelGeneratorManager() // Singleton for Label Manager
    private init() {}
    
    // Constants for Avery 5160 label template
    private let pageWidth: CGFloat = 8.5 * 72 // 8.5 inches
    private let pageHeight: CGFloat = 11 * 72 // 11 inches
    
    private let labelWidth: CGFloat = 2.625 * 72 // 2.625 inches
    private let labelHeight: CGFloat = 1 * 72 // 1 inch
    
    private let topMargin: CGFloat = 0.5 * 72 // 0.5 inches
    private let leftMargin: CGFloat = 0.35 * 72 // 0.35 inches
    
    private let verticalSpacing: CGFloat = 0.0 // Adjusted vertical spacing
    private let horizontalSpacing: CGFloat = 0.125 * 72 // 0.125 inches
    
    func generatePDFLabels(units: [RMUnit], tenants: [RMTenant], saveTo url: URL, templatePDF: URL) {
        
        guard let templateDocument = PDFDocument(url: templatePDF) else {
            print("Failed to load template PDF.")
            return
        }
        
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))
        
        do {
            try pdfRenderer.writePDF(to: url) { context in
                context.beginPage()
                
                var currentX = leftMargin
                var currentY = topMargin
                var pageIndex = 0
                
                for (index, unit) in units.enumerated() {
                    // Start a new page if necessary
                    if index % 30 == 0 {
                        if index != 0 {
                            context.beginPage()
                            pageIndex += 1
                        }
                        
                        if let templatePage = templateDocument.page(at: pageIndex % templateDocument.pageCount) {
                            context.cgContext.drawPDFPage(templatePage.pageRef!)
                        }
                    }
                    
                    // Draw the label
                    let labelRect = CGRect(x: currentX, y: currentY, width: labelWidth, height: labelHeight)
                    
                    let tenant = tenants.filter { $0.tenantID == unit.currentOccupants?.first?.tenantID }
                    drawLabel(for: unit, tenant: tenant, in: labelRect)
                
                    
                    // Update the position for the next label
                    if (index + 1) % 3 == 0 {
                        currentX = leftMargin
                        currentY += labelHeight + verticalSpacing
                    } else {
                        currentX += labelWidth + horizontalSpacing
                    }
                    
                    // Move to the next page if necessary
                    if (index + 1) % 30 == 0 {
                        currentX = leftMargin
                        currentY = topMargin
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // Function to draw an individual label
    private func drawLabel(for unit: RMUnit, tenant: [RMTenant], in rect: CGRect) {
        
        // Determine the text color based on unitType.name
        var textColor: UIColor
        
        let currentUDF = unit.userDefinedValues?
            .first(where: { $0.userDefinedFieldID == 67 })?
            .name
        
        print("\n")
        print(unit.name ?? "")
        print(unit.userDefinedValues?.count ?? 0)
        print(currentUDF ?? "N/a")
        
        if currentUDF == "HEI- Fire Protection Approved 2026" {
            textColor = .fireRed
        } else {
            textColor = .black
        }
        
        switch currentUDF {
        case "HEI- Fire Protection Approved 2026":
            textColor = .fireRed
        case "PTP- Pros B - Dry":
            textColor = .havenGreen
        case "PTP- Pros B - Lake":
            textColor = .pembrokeBlue
        case "PTP- Pros A":
            textColor = .fireRed
        default:
            textColor = .black // Default or for any other types
        }
        
        
//        switch unit.unitType?.name {
//        case "HEI- Regular Rent":
//            textColor = .black
//        case "HEI- Fire Protection":
//            textColor = .fireRed
//        case "PTP- Pros B - Dry":
//            textColor = .havenGreen
//        case "PTP- Pros B - Lake":
//            textColor = .pembrokeBlue
//        case "PTP- Pros A":
//            textColor = .fireRed
//        default:
//            textColor = .yellow // Default or for any other types
//        }
        
        let contactsForLabel = tenant.first?.contacts?.filter { $0.isShowOnBill == true }
        var namesPortion = ""
        
        if contactsForLabel?.count ?? 0 > 0 {
            for (index, contact) in contactsForLabel!.enumerated() {
                namesPortion.append(index == 0 ? "\(contact.firstName!) \(contact.lastName!)" : "\n\(contact.firstName!) \(contact.lastName!)")
            }
        } else { namesPortion = "VACANT" }
        
        var labelText = ""
        
        if unit.propertyID == 3 {
            let addressParts = unit.primaryAddress?.street?.components(separatedBy: "\r\n")
            
            labelText = """
            \(namesPortion)
            \(addressParts?.first ?? "") Lot \(unit.name ?? "X-44")
            Box \(addressParts?.last! ?? "")
            \(unit.primaryAddress?.city ?? "xxxxx") \(unit.primaryAddress?.state ?? "FL"), \(unit.primaryAddress?.postalCode ?? "33025")
            """
        } else {
            labelText = """
            \(namesPortion)
            \(unit.primaryAddress?.street ?? "")
            \(unit.primaryAddress?.city ?? "xxxxx") \(unit.primaryAddress?.state ?? "FL"), \(unit.primaryAddress?.postalCode ?? "33009")
            """
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9),
            .foregroundColor: textColor,
            .paragraphStyle : paragraphStyle
        ]
        
        let textSize = labelText.size(withAttributes: attributes)
        
        let textRect = CGRect(x: rect.minX, y: rect.midY - textSize.height / 2, width: rect.width, height: rect.height)
        
        labelText.draw(in: textRect, withAttributes: attributes)
    }
    
    // New method to generate CSV file for all units
       func generateCSVFile(units: [RMUnit], tenants: [RMTenant], saveTo url: URL) {
           var csvText = "Unit Name, Tenant Name(s), Street Address, Box Number, City, State, Postal Code\n"
           
           for unit in units {
               // Get the tenant(s) for the unit
               let tenant = tenants.filter { $0.tenantID == unit.currentOccupants?.first?.tenantID }
               
               // Get unit name and address
               let tenantName = unit.currentOccupants?.first?.name ?? "Vacant"
               let unitName = unit.name ?? "N/A"
               let addressParts = unit.primaryAddress?.street?.components(separatedBy: "\r\n")
               let streetAddress = addressParts?.first ?? ""
               let boxNumber = addressParts?.last ?? ""
               let city = unit.primaryAddress?.city ?? "N/A"
               let state = unit.primaryAddress?.state ?? "N/A"
               let postalCode = unit.primaryAddress?.postalCode ?? "N/A"
               
               // Combine the values into a CSV row
               let row = "\"\(unitName)\",\"\(tenantName)\",\"\(streetAddress)\",\"\(boxNumber)\",\"\(city)\",\"\(state)\",\"\(postalCode)\"\n"
               csvText.append(row)
           }
           
           do {
               // Write the CSV text to the file at the specified URL
               try csvText.write(to: url, atomically: true, encoding: .utf8)
               print("CSV file created successfully at: \(url)")
           } catch {
               print("Failed to create CSV file: \(error.localizedDescription)")
           }
       }
}
