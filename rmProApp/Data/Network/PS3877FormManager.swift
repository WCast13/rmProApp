//
//  PS3877FormManager.swift
//  rmProApp
//
//  Created by William Castellano on 9/5/24.
//

import Foundation
import PDFKit
#if canImport(UIKit)
import UIKit
#endif

class PS3877FormManager {
    static let shared = PS3877FormManager()
    private init() {}
    
    func create3877Form(units: [RMUnit], tenants: [RMTenant], saveTo url: URL, templatePDF: URL) {
        
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 792, height: 612)) // 11 x 8.5 inches
        
        do {
            try pdfRenderer.writePDF(to: url) { context in
                
                var currentPageIndex = 0
                var currentY: CGFloat = 163  // Starting Y position for first page (adjust this based on the form)
                
                let leftColumnX: CGFloat = 48  // X position for the unit name
                let secondColumnX: CGFloat = 183  // X position for the address
                let lineHeight: CGFloat = 48  // Spacing between rows
                let unitsPerPage = 8  // Number of rows (units) per page
                
                // Box dimensions
                let unitNameBoxWidth: CGFloat = 100
                let unitNameBoxHeight: CGFloat = 47
                let addressBoxWidth: CGFloat = 210
                let addressBoxHeight: CGFloat = 47
                
                context.beginPage()
                
                // Loop through the units and add their data to the PDF
                for (index, unit) in units.enumerated() {
                   
                    // Start a new page every 8 units
                    if index % unitsPerPage == 0 {
                        if index != 0 {
                            context.beginPage()
                        }
                        
                        // Reset the Y position and add the template to the new page
                        currentY = 163  // Adjust starting Y position for each new page
                        
                        currentPageIndex += 1
                    }
                    
                    
                    let tenant = tenants.filter { $0.tenantID == unit.currentOccupants?.first?.tenantID }
                    
                    let unitName = unit.name ?? "** No Name **"
                    
                    
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
                        \(unit.currentOccupants?.first?.name ?? "")
                        \(addressParts?.first ?? "") Lot \(unit.name ?? "X-44")
                        Box \(addressParts?.last! ?? "")
                        \(unit.primaryAddress?.city ?? "xxxxx") \(unit.primaryAddress?.state ?? "FL"), \(unit.primaryAddress?.postalCode ?? "33025")
                        """
                    } else {
                        labelText = """
                        \(unit.currentOccupants?.first?.name ?? "")
                        \(unit.primaryAddress?.street ?? "")
                        \(unit.primaryAddress?.city ?? "xxxxx") \(unit.primaryAddress?.state ?? "FL"), \(unit.primaryAddress?.postalCode ?? "33009")
                        """
                    }
                    
                    let currentOccupant = unit.currentOccupants?.first?.name ?? "** No Name ** "
                    
                    // Draw the unit name box
                    let nameBoxRect = CGRect(x: leftColumnX, y: currentY, width: unitNameBoxWidth, height: unitNameBoxHeight)
//                    context.cgContext.stroke(nameBoxRect)
                    
                    drawText(text: unitName, in: nameBoxRect, context: context)
                    
                    let addresssBoxRect = CGRect(x: secondColumnX, y: currentY, width: addressBoxWidth, height: addressBoxHeight)
//                    context.cgContext.stroke(addresssBoxRect)
                    
                    drawText(text: labelText, in: addresssBoxRect, context: context)
                    
                    // Move to the next row
                    currentY += lineHeight
                
                }
            }
            
            print("PDF generated at: \(url)")
        } catch {
            print("Failed to generate PDF: \(error.localizedDescription)")
        }
    }
    
    // Function to left-align text in a given box with some padding
    private func drawText(text: String, in rect: CGRect, context: UIGraphicsPDFRendererContext) {
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9),
            .foregroundColor: UIColor.black
        ]
        let attributedText = NSAttributedString(string: text, attributes: textAttributes)
        
        // Calculate the point to start drawing the text so that it is vertically centered and left-aligned with padding
        let textX = rect.minX + 10  // 5-point padding from the left
        let textY = rect.midY - attributedText.size().height / 2  // Vertically centered
        
        // Draw the text at the calculated position
        attributedText.draw(at: CGPoint(x: textX, y: textY))
    }
}
