//
//  SectionHeader.swift
//  rmProApp
//
//  Standard "Name of Card" header text used above every grouped card.
//  Keeps weight, horizontal padding, and color consistent.
//

import SwiftUI

struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(DSTypography.sectionTitle)
            .foregroundColor(DSColor.primary)
            .padding(.horizontal, DSSpacing.l)
    }
}
