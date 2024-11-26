// Copyright 2024 Lie Yan

import Foundation

protocol NodeAttributeSubspace: CaseIterable {
    static var attributeTypes: [AttributeKey: ValueType] { get }
}

enum NodeAttributes {
    enum Text: NodeAttributeSubspace {
        static let font = AttributeKey(.text, .fontFamily)
        static let size = AttributeKey(.text, .fontSize)
        static let stretch = AttributeKey(.text, .fontStretch)
        static let style = AttributeKey(.text, .fontStyle)
        static let weight = AttributeKey(.text, .fontWeight)

        static let allCases: Set<AttributeKey> = [
            font, size, stretch, style, weight,
        ]

        static let attributeTypes: [AttributeKey: ValueType] = [
            Text.font: .string,
            Text.size: .fontSize,
            Text.stretch: .fontStretch,
            Text.style: .fontStyle,
            Text.weight: .fontWeight,
        ]
    }

    enum Math: NodeAttributeSubspace {
        static let font = AttributeKey(.equation, .fontFamily)
        static let bold = AttributeKey(.equation, .bold)
        static let italic = AttributeKey(.equation, .italic)
        static let autoItalic = AttributeKey(.equation, .autoItalic)
        static let cramped = AttributeKey(.equation, .cramped)
        static let style = AttributeKey(.equation, .mathStyle)
        static let variant = AttributeKey(.equation, .mathVariant)

        static let allCases: Set<AttributeKey> = [
            font, bold, italic, autoItalic, cramped, style, variant,
        ]

        static let attributeTypes: [AttributeKey: ValueType] = [
            Math.font: .string,
            Math.bold: .bool,
            Math.italic: .sum([.bool, .none]),
            Math.autoItalic: .bool,
            Math.cramped: .bool,
            Math.style: .mathStyle,
            Math.variant: .mathVariant,
        ]
    }

    enum Paragraph: NodeAttributeSubspace {
        static let topMargin = AttributeKey(.paragraph, .topMargin)
        static let bottomMargin = AttributeKey(.paragraph, .bottomMargin)
        static let topPadding = AttributeKey(.paragraph, .topPadding)
        static let bottomPadding = AttributeKey(.paragraph, .bottomPadding)

        static var allCases: Set<AttributeKey> = [
            topMargin, bottomMargin, topPadding, bottomPadding,
        ]

        static let attributeTypes: [AttributeKey: ValueType] = [
            Paragraph.topMargin: .absLength,
            Paragraph.bottomMargin: .absLength,
            Paragraph.topPadding: .absLength,
            Paragraph.bottomPadding: .absLength,
        ]
    }
}
