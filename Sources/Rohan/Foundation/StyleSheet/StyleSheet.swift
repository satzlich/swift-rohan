// Copyright 2024-2025 Lie Yan

import Foundation

public typealias StyleRules = [TargetSelector: PropertyDictionary]

public final class StyleSheet {
    private let styleRules: StyleRules
    public let defaultProperties: PropertyMapping

    public init(_ styleRules: StyleRules, _ defaultProperties: PropertyMapping) {
        self.styleRules = styleRules
        self.defaultProperties = defaultProperties
    }

    /** Styles for the given selector */
    public func getProperties(for selector: TargetSelector) -> PropertyDictionary? {
        styleRules[selector]
    }

    public static func defaultStyleSheet(_ textSize: FontSize) -> StyleSheet {
        let h1Size = FontSize(textSize.floatValue + 8)
        let styleRules: StyleRules = [
            // H1
            HeadingNode.selector(level: 1): [
                TextProperty.font: .string("Latin Modern Sans"),
                TextProperty.size: .fontSize(h1Size),
                TextProperty.style: .fontStyle(.italic),
                TextProperty.foregroundColor: .color(.blue),
            ],
        ]

        let defaultProperties: PropertyMapping =
            [
                // text
                TextProperty.font: .string("Latin Modern Roman"),
                TextProperty.size: .fontSize(textSize),
                TextProperty.stretch: .fontStretch(.normal),
                TextProperty.style: .fontStyle(.normal),
                TextProperty.weight: .fontWeight(.regular),
                TextProperty.foregroundColor: .color(.black),
                // equation
                MathProperty.font: .string("Latin Modern Math"),
                MathProperty.bold: .bool(false),
                MathProperty.italic: .none,
                MathProperty.cramped: .bool(false),
                MathProperty.style: .mathStyle(.display),
                MathProperty.variant: .mathVariant(.serif),
                // paragraph
                ParagraphProperty.topMargin: .float(.zero),
                ParagraphProperty.bottomMargin: .float(.zero),
                ParagraphProperty.topPadding: .float(.zero),
                ParagraphProperty.bottomPadding: .float(.zero),
            ]

        return StyleSheet(styleRules, defaultProperties)
    }
}
