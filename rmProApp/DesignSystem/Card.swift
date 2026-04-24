//
//  Card.swift
//  rmProApp
//
//  Grouped content surface: titled section header above a rounded
//  surface-colored container with a hairline stroke and soft shadow.
//  Replaces the hand-rolled pattern that was copy-pasted across every
//  card in the resident detail view.
//

import SwiftUI

struct Card<Content: View>: View {
    let title: String
    let content: Content

    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            SectionHeader(title: title)

            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(DSSpacing.l)
                .background(DSColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: DSRadius.medium, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.medium)
                        .stroke(DSColor.divider, lineWidth: 1)
                )
        }
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
