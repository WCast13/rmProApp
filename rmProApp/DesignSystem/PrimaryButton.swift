//
//  PrimaryButton.swift
//  rmProApp
//
//  Full-width primary action. Pushes the given destination onto the
//  enclosing NavigationStack. Replaces the ad-hoc HomeButton.
//

import SwiftUI

struct PrimaryButton<Destination: Hashable>: View {
    let title: String
    let destination: Destination

    var body: some View {
        NavigationLink(value: destination) {
            Text(title)
                .font(DSTypography.bodyBold)
                .frame(maxWidth: .infinity)
                .padding(DSSpacing.l)
                .background(DSColor.accent)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: DSRadius.medium, style: .continuous))
        }
        .padding(.horizontal, DSSpacing.l)
    }
}
