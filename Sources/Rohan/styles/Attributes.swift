// Copyright 2024 Lie Yan

import Foundation

enum Attributes {
    enum Text {
        static let font = AttributeKey(.text, .fontFamily) // String
        static let size = AttributeKey(.text, .fontSize) // FontSize
        static let stretch = AttributeKey(.text, .fontStretch) // FontStretch
        static let style = AttributeKey(.text, .fontStyle) // FontStyle
        static let weight = AttributeKey(.text, .fontWeight) // FontWeight

        static let allCases: Set<AttributeKey> = [
            font, size, stretch, style, weight,
        ]
    }

    enum Equation {
        static let font = AttributeKey(.equation, .fontFamily) // String
        static let bold = AttributeKey(.equation, .bold) // Bool
        static let italic = AttributeKey(.equation, .italic) // { Bool | None }
        static let cramped = AttributeKey(.equation, .cramped) // Bool
        static let style = AttributeKey(.equation, .mathStyle) // MathStyle
        static let variant = AttributeKey(.equation, .mathVariant) // MathVariant

        static let allCases: Set<AttributeKey> = [
            font, bold, italic, cramped, style, variant,
        ]
    }

    enum Paragraph {
        static let topMargin = AttributeKey(.paragraph, .topMargin) // AbsLength
        static let bottomMargin = AttributeKey(.paragraph, .bottomMargin) // AbsLength
        static let topPadding = AttributeKey(.paragraph, .topPadding) // AbsLength
        static let bottomPadding = AttributeKey(.paragraph, .bottomPadding) // AbsLength

        static let allCases: Set<AttributeKey> = [
            topMargin, bottomMargin, topPadding, bottomPadding,
        ]
    }
}
