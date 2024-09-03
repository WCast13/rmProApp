//
//  DocumentsView.swift
//  rmProApp
//
//  Created by William Castellano on 9/3/24.
//

import SwiftUI
import PDFKit

struct DocumentsView: View {
    @State private var documentURLs: [URL] = []
    
    var body: some View {
        
        VStack {
            List(documentURLs, id: \.self) { url in
                NavigationLink(destination: PDFViewerView(pdfURL: url)) {
                    Text(url.lastPathComponent)
                }
            }
            .onAppear {
                loadDocuments()
            }
        }
        .navigationTitle("Documents")
    }
    
    private func loadDocuments() {
        let fileManager = FileManager.default
        if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                let urls = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
                self.documentURLs = urls.filter { $0.pathExtension == "pdf" }
            } catch {
                print("Error Loading Documents: \(error)")
            }
        }
    }
}



struct PDFViewerView: View {
    let pdfURL: URL
    
    var body: some View {
        PDFKitView(url: pdfURL)
            .navigationTitle(pdfURL.lastPathComponent)
    }
}

struct PDFKitView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: url)
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {}
}

#Preview {
    DocumentsView()
}
