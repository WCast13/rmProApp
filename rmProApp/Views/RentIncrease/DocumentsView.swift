//
//  DocumentsView.swift
//  rmProApp
//
//  Created by William Castellano on 9/3/24.
//

import SwiftUI
import PDFKit
import UIKit

struct DocumentsView: View {
    @Binding var navigationPath: NavigationPath
    @State private var documents: [URL] = []
    @State private var showingShareSheet = false
    @State private var documentToShare: URL?

    var body: some View {
        VStack {
            if documents.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No Documents Found")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Created documents will appear here")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(documents, id: \.self) { url in
                    HStack {
                        NavigationLink(value: AppDestination.documentViewer(url)) {
                            HStack {
                                Image(systemName: iconForFileExtension(url.pathExtension))
                                    .foregroundColor(.accentColor)
                                    .frame(width: 30)
                                VStack(alignment: .leading) {
                                    Text(url.lastPathComponent)
                                        .font(.headline)
                                        .lineLimit(1)
                                    if let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
                                       let fileSize = attributes[.size] as? Int64 {
                                        Text(formatFileSize(fileSize))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                            }
                        }

                        Button(action: {
                            shareDocument(url)
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.accentColor)
                                .font(.title2)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    .swipeActions(edge: .trailing) {
                        Button(action: {
                            shareDocument(url)
                        }) {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .tint(.blue)

                        Button(action: {
                            deleteDocument(url)
                        }) {
                            Image(systemName: "trash")
                        }
                        .tint(.red)
                    }
                }
            }
        }
        .onAppear {
            loadDocuments()
        }
        .navigationTitle("Documents")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: loadDocuments) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .sheet(isPresented: $showingShareSheet, content: {
            if let documentToShare = documentToShare {
                ShareSheet(activityItems: [documentToShare])
            }
        })
    }
    
    private func loadDocuments() {
        let fileManager = FileManager.default
        if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                let urls = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
                self.documents = urls.filter {
                    let ext = $0.pathExtension.lowercased()
                    return ext == "pdf" || ext == "csv" || ext == "txt"
                }.sorted { $0.lastPathComponent < $1.lastPathComponent }
            } catch {
                print("Error Loading Documents: \(error)")
            }
        }
    }

    private func shareDocument(_ url: URL) {
        documentToShare = url
        showingShareSheet = true
    }

    private func deleteDocument(_ url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
            loadDocuments() // Refresh the list
        } catch {
            print("Error deleting document: \(error)")
        }
    }
}

struct DocumentViewerView: View {
    let documentURL: URL
    @Binding var navigationPath: NavigationPath

    var body: some View {
        Group {
            if documentURL.pathExtension.lowercased() == "pdf" {
                PDFKitRepresentedView(url: documentURL)
                    .navigationTitle(documentURL.lastPathComponent)
                    .navigationBarItems(trailing: HStack {
                        Button("Share") { shareDocument() }
                        Button("Print") { printDocument() }
                    })
            } else if documentURL.pathExtension.lowercased() == "csv" || documentURL.pathExtension.lowercased() == "txt" {
                ScrollView {
                    if let content = try? String(contentsOf: documentURL) {
                        Text(content)
                            .font(.system(.body, design: .monospaced))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Text("Unable to load file contents")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
                .navigationTitle(documentURL.lastPathComponent)
                .navigationBarItems(trailing: Button("Share") {
                    shareDocument()
                })
            } else {
                VStack {
                    Image(systemName: "doc")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                        .padding()
                    Text("Preview not available for this file type")
                        .foregroundColor(.secondary)
                    Button("Share") {
                        shareDocument()
                    }
                    .padding()
                }
                .navigationTitle(documentURL.lastPathComponent)
            }
        }
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

    func shareDocument() {
        let activityViewController = UIActivityViewController(activityItems: [documentURL], applicationActivities: nil)

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityViewController, animated: true, completion: nil)
        }
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

private func iconForFileExtension(_ ext: String) -> String {
    switch ext.lowercased() {
    case "pdf":
        return "doc.fill"
    case "csv":
        return "tablecells"
    case "txt":
        return "doc.text"
    default:
        return "doc"
    }
}

private func formatFileSize(_ bytes: Int64) -> String {
    let formatter = ByteCountFormatter()
    formatter.countStyle = .file
    return formatter.string(fromByteCount: bytes)
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

