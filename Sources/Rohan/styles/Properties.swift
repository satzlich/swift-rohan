// Copyright 2024 Lie Yan

import Foundation

/// Extrinsic properties
enum Properties {
    enum Text {
        static let font = PropertyKey(.text, .fontFamily) // String
        static let size = PropertyKey(.text, .fontSize) // FontSize
        static let stretch = PropertyKey(.text, .fontStretch) // FontStretch
        static let style = PropertyKey(.text, .fontStyle) // FontStyle
        static let weight = PropertyKey(.text, .fontWeight) // FontWeight

        static let allCases: Set<PropertyKey> = [
            font, size, stretch, style, weight,
        ]
    }

    enum Equation {
        static let font = PropertyKey(.equation, .fontFamily) // String
        static let bold = PropertyKey(.equation, .bold) // Bool
        static let italic = PropertyKey(.equation, .italic) // { Bool | None }
        static let cramped = PropertyKey(.equation, .cramped) // Bool
        static let style = PropertyKey(.equation, .mathStyle) // MathStyle
        static let variant = PropertyKey(.equation, .mathVariant) // MathVariant

        static let allCases: Set<PropertyKey> = [
            font, bold, italic, cramped, style, variant,
        ]
    }

    enum Paragraph {
        static let topMargin = PropertyKey(.paragraph, .topMargin) // AbsLength
        static let bottomMargin = PropertyKey(.paragraph, .bottomMargin) // AbsLength
        static let topPadding = PropertyKey(.paragraph, .topPadding) // AbsLength
        static let bottomPadding = PropertyKey(.paragraph, .bottomPadding) // AbsLength

        static let allCases: Set<PropertyKey> = [
            topMargin, bottomMargin, topPadding, bottomPadding,
        ]
    }
}
