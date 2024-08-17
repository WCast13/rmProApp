//
//  LabelManager.swift
//  rmProApp
//
//  Created by William Castellano on 8/17/24.
//

import PDFKit
import UIKit

class LabelGeneratorManager {
    static let shared = LabelGeneratorManager() // Singleton for Label Manager
    private init() {}
    
    // Constants for Avery 5160 label template
    private let pageWidth: CGFloat = 8.5 * 72 // 8.5 inches
    private let pageHeight: CGFloat = 11 * 72 // 11 inches
    
    private let labelWidth: CGFloat = 2.625 * 72 // 2.625 inches
    private let labelHeight: CGFloat = 1 * 72 // 1 inch
    
    private let topMargin: CGFloat = 0.5 * 72 // 0.5 inches
    private let leftMargin: CGFloat = 0.19 * 72 // 0.19 inches
    
    private let verticalSpacing: CGFloat = 0.15 * 72 // 0.15 inches
    private let horizontalSpacing: CGFloat = 0.125 * 72 // 0.125 inches
    
    func generatePDFLabels(units: [RMUnit], saveTo url: URL, templatePDF: URL) {
        guard let templateDocument = PDFDocument(url: templatePDF) else {
            print("Failed to load template PDF.")
            return
        }
        
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))
        
        do {
            try pdfRenderer.writePDF(to: url) { context in
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
                    drawLabel(for: unit, in: labelRect)
                    
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
    private func drawLabel(for unit: RMUnit, in rect: CGRect) {
        let labelText = """
        \(unit.currentOccupants?.first?.name ?? "VACANT")
        11201 SW 55th St
        """
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10)
        ]
        
        labelText.draw(in: rect, withAttributes: attributes)
    }
}



