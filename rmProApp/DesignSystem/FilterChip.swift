//
//  FilterChip.swift
//  rmProApp
//
//  Pill-shaped toggle used in filter bars. Selected state uses the
//  accent color; unselected falls back to the surface token.
//

import SwiftUI

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DSTypography.subheadlineBold)
                .padding(.horizontal, DSSpacing.l)
                .padding(.vertical, DSSpacing.s)
                .background(isSelected ? DSColor.accent : DSColor.surface)
                .foregroundColor(isSelected ? .white : DSColor.primary)
                .clipShape(Capsule())
        }
    }
}
