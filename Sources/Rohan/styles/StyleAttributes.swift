// Copyright 2024 Lie Yan

import Foundation

enum StyleAttributes {
    static let allCases: Set<AttributeKey> =
        [
            Text.allCases,
            Math.allCases,
            Paragraph.allCases,
        ]
        .reduce(into: Set<AttributeKey>()) {
            $0.formUnion($1)
        }

    static let typeMap: [AttributeKey: ValueType] =
        [
            Text.typeMap,
            Math.typeMap,
            Paragraph.typeMap,
        ]
        .reduce(into: [AttributeKey: ValueType]()) {
            $0.merge($1, uniquingKeysWith: { _, _ in fatalError("duplicate key") })
        }
}

enum Text {
    static let font = AttributeKey(.text, .fontFamily)
    static let size = AttributeKey(.text, .fontSize)
    static let stretch = AttributeKey(.text, .fontStretch)
    static let style = AttributeKey(.text, .fontStyle)
    static let weight = AttributeKey(.text, .fontWeight)

    static let allCases: Set<AttributeKey> = [
        font, size, stretch, style, weight,
    ]

    static let typeMap: [AttributeKey: ValueType] = [
        Text.font: .string,
        Text.size: .fontSize,
        Text.stretch: .fontStretch,
        Text.style: .fontStyle,
        Text.weight: .fontWeight,
    ]
}

enum Math {
    static let font = AttributeKey(.equation, .fontFamily)
    static let bold = AttributeKey(.equation, .bold)
    static let italic = AttributeKey(.equation, .italic)
    static let cramped = AttributeKey(.equation, .cramped)
    static let style = AttributeKey(.equation, .mathStyle)
    static let variant = AttributeKey(.equation, .mathVariant)

    static let allCases: Set<AttributeKey> = [
        font, bold, italic, cramped, style, variant,
    ]

    static let typeMap: [AttributeKey: ValueType] = [
        Math.font: .string,
        Math.bold: .bool,
        Math.italic: .sum([.bool, .none]),
        Math.cramped: .bool,
        Math.style: .mathStyle,
        Math.variant: .mathVariant,
    ]
}

enum Paragraph {
    static let topMargin = AttributeKey(.paragraph, .topMargin)
    static let bottomMargin = AttributeKey(.paragraph, .bottomMargin)
    static let topPadding = AttributeKey(.paragraph, .topPadding)
    static let bottomPadding = AttributeKey(.paragraph, .bottomPadding)

    static let allCases: Set<AttributeKey> = [
        topMargin, bottomMargin, topPadding, bottomPadding,
    ]

    static let typeMap: [AttributeKey: ValueType] = [
        Paragraph.topMargin: .absLength,
        Paragraph.bottomMargin: .absLength,
        Paragraph.topPadding: .absLength,
        Paragraph.bottomPadding: .absLength,
    ]
}
