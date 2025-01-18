// Copyright 2024-2025 Lie Yan

import AppKit

public struct MathProperty: PropertyAggregate {
    public let font: String
    public let bold: Bool
    public let italic: Bool?
    public let cramped: Bool
    public let style: MathStyle
    public let variant: MathVariant

    public func properties() -> PropertyDictionary {
        [
            MathProperty.font: .string(font),
            MathProperty.bold: .bool(bold),
            MathProperty.italic: italic.map { .bool($0) } ?? .none,
            MathProperty.cramped: .bool(cramped),
            MathProperty.style: .mathStyle(style),
            MathProperty.variant: .mathVariant(variant),
        ]
    }

    public func attributes() -> [NSAttributedString.Key: Any] {
        [:]
    }

    public static func resolve(_ properties: PropertyDictionary,
                               _ fallback: PropertyMapping) -> MathProperty
    {
        func resolved(_ key: PropertyKey) -> PropertyValue {
            key.resolve(properties, fallback)
        }

        return MathProperty(
            font: resolved(font).string()!,
            bold: resolved(bold).bool()!,
            italic: resolved(italic).bool(),
            cramped: resolved(cramped).bool()!,
            style: resolved(style).mathStyle()!,
            variant: resolved(variant).mathVariant()!
        )
    }

    // MARK: - Key

    public static let font = PropertyKey(.equation, .fontFamily) // String
    public static let bold = PropertyKey(.equation, .bold) // Bool
    public static let italic = PropertyKey(.equation, .italic) // { Bool | None }
    public static let cramped = PropertyKey(.equation, .cramped) // Bool
    public static let style = PropertyKey(.equation, .mathStyle) // MathStyle
    public static let variant = PropertyKey(.equation, .mathVariant) // MathVariant

    public static let typeRegistry: PropertyTypeRegistry = [
        font: .string,
        bold: .bool,
        italic: .sum([.bool, .none]),
        cramped: .bool,
        style: .mathStyle,
        variant: .mathVariant,
    ]

    public static let allKeys: [PropertyKey] = typeRegistry.keys.map { $0 }
}
