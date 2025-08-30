//
//  DocumentsView.swift
//  rmProApp
//
//  Created by William Castellano on 9/3/24.
//

import SwiftUI
import PDFKit

struct DocumentsView: View {
    @Binding var navigationPath: NavigationPath
    @State private var documents: [URL] = []
    
    var body: some View {
        
        VStack {
            List(documents, id: \.self) { url in
                NavigationLink(value: AppDestination.documentViewer(url)) {
                    Text(url.lastPathComponent)
                }
            }
            .onAppear {
                loadDocuments()
            }
            .navigationTitle("Documents")
        }
    }
    
    private func loadDocuments() {
        let fileManager = FileManager.default
        if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                let urls = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
                self.documents = urls.filter { $0.pathExtension == "pdf" }
            } catch {
                print("Error Loading Documents: \(error)")
            }
        }
    }
}

struct DocumentViewerView: View {
    let documentURL: URL
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        PDFKitRepresentedView(url: documentURL)
            .navigationTitle(documentURL.lastPathComponent)
            .navigationBarItems(trailing: Button("Print") {
                printDocument()
            })
    }
    
    func printDocument() {
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.jobName = documentURL.lastPathComponent
        
        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        
        if let pdfDocument = PDFDocument(url: documentURL) {
            printController.printingItem = pdfDocument
        }
        printController.present(animated: true, completionHandler: nil)
    }
}

struct PDFKitRepresentedView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: url)
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {}
}

