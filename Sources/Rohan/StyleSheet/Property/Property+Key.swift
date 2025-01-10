// Copyright 2024-2025 Lie Yan

import Foundation

extension Property {
    // MARK: - Key

    public struct Key: Equatable, Hashable, Codable {
        let nodeType: NodeType
        let propertyName: Name

        init(_ nodeType: NodeType, _ propertyName: Name) {
            self.nodeType = nodeType
            self.propertyName = propertyName
        }
    }
}

// MARK: - Property Keys

extension Text {
    public static let font = PropertyKey(.text, .fontFamily) // String
    public static let size = PropertyKey(.text, .fontSize) // FontSize
    public static let stretch = PropertyKey(.text, .fontStretch) // FontStretch
    public static let style = PropertyKey(.text, .fontStyle) // FontStyle
    public static let weight = PropertyKey(.text, .fontWeight) // FontWeight
}

extension Equation {
    public static let font = PropertyKey(.equation, .fontFamily) // String
    public static let bold = PropertyKey(.equation, .bold) // Bool
    public static let italic = PropertyKey(.equation, .italic) // { Bool | None }
    public static let cramped = PropertyKey(.equation, .cramped) // Bool
    public static let style = PropertyKey(.equation, .mathStyle) // MathStyle
    public static let variant = PropertyKey(.equation, .mathVariant) // MathVariant
}

extension Paragraph {
    public static let topMargin = PropertyKey(.paragraph, .topMargin) // AbsLength
    public static let bottomMargin = PropertyKey(.paragraph, .bottomMargin) // AbsLength
    public static let topPadding = PropertyKey(.paragraph, .topPadding) // AbsLength
    public static let bottomPadding = PropertyKey(.paragraph, .bottomPadding) // AbsLength
}

extension PropertyKey: CaseIterable {
    public static var allCases: [PropertyKey] {
        [
            Text.font,
            Text.size,
            Text.stretch,
            Text.style,
            Text.weight,
            Equation.font,
            Equation.bold,
            Equation.italic,
            Equation.cramped,
            Equation.style,
            Equation.variant,
            Paragraph.topMargin,
            Paragraph.bottomMargin,
            Paragraph.topPadding,
            Paragraph.bottomPadding,
        ]
    }
}
