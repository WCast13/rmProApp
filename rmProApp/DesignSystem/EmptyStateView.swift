//
//  EmptyStateView.swift
//  rmProApp
//
//  Large-format empty state for lists and detail screens. Fills the
//  enclosing container; use inside a ScrollView only when the caller
//  provides a frame. For inline "no data" messages prefer plain text.
//

import SwiftUI

struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let message: String?

    init(systemImage: String, title: String, message: String? = nil) {
        self.systemImage = systemImage
        self.title = title
        self.message = message
    }

    var body: some View {
        VStack(spacing: DSSpacing.m) {
            Image(systemName: systemImage)
                .font(.system(size: 60))
                .foregroundColor(DSColor.secondary)
            Text(title)
                .font(DSTypography.cardTitle)
                .foregroundColor(DSColor.secondary)
            if let message {
                Text(message)
                    .font(DSTypography.subheadline)
                    .foregroundColor(DSColor.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(DSSpacing.xl)
    }
}
