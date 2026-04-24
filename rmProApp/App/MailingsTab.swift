//
//  MailingsTab.swift
//  rmProApp
//
//  Mailings tab: hosts the rent-increase builder (Avery 5160 labels +
//  PS Form 3877) and the Documents / DocumentViewer sub-surface.
//

import SwiftUI

enum MailingsDestination: Hashable {
    case documents
    case documentViewer(URL)
}

struct MailingsTab: View {
    @Binding var path: NavigationPath

    var body: some View {
        NavigationStack(path: $path) {
            MailingsHomeView(navigationPath: $path)
                .navigationDestination(for: MailingsDestination.self) { destination in
                    switch destination {
                    case .documents:
                        DocumentsView(navigationPath: $path)
                    case .documentViewer(let url):
                        DocumentViewerView(documentURL: url, navigationPath: $path)
                    }
                }
        }
    }
}
