//
//  DSTokens.swift
//  rmProApp
//
//  Centralized design tokens. Use these everywhere instead of ad-hoc
//  fonts, colors, and paddings so the app has one place to change look
//  and feel. Namespaced as DSTypography / DSColor / DSSpacing / DSRadius.
//

import SwiftUI

enum DSTypography {
    static let largeTitle: Font = .largeTitle.bold()
    static let title: Font = .title.bold()
    static let sectionTitle: Font = .title3.bold()
    static let cardTitle: Font = .headline
    static let body: Font = .body
    static let bodyBold: Font = .body.bold()
    static let subheadline: Font = .subheadline
    static let subheadlineBold: Font = .subheadline.bold()
    static let caption: Font = .caption
    static let captionBold: Font = .caption.bold()
}

enum DSColor {
    /// Primary text and icons on default backgrounds.
    static let primary: Color = .primary
    /// Secondary text: metadata, captions, hint text.
    static let secondary: Color = .secondary
    /// Tertiary backgrounds (cards, inset rows).
    static let surface: Color = Color(.systemGray6)
    /// Border / separator above surface.
    static let divider: Color = Color(.systemGray5)
    /// Interactive accents (buttons, active filter chips).
    static let accent: Color = .accentColor
    /// Destructive / error state.
    static let destructive: Color = .red
    /// Confirming / positive state.
    static let positive: Color = .green
}

enum DSSpacing {
    /// 4pt — hairline gap between tightly coupled elements.
    static let xs: CGFloat = 4
    /// 8pt — default spacing inside a component.
    static let s: CGFloat = 8
    /// 12pt — row / list item padding.
    static let m: CGFloat = 12
    /// 16pt — standard card padding.
    static let l: CGFloat = 16
    /// 20pt — section spacing.
    static let xl: CGFloat = 20
    /// 32pt — page-level margins.
    static let xxl: CGFloat = 32
}

enum DSRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let pill: CGFloat = 999
}
