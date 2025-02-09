// Copyright 2024-2025 Lie Yan

import Rohan
import Testing

struct StyleSheetTests {
    @Test
    static func testStyleSheet() {
        let styleSheet = sampleStyleSheet()

        let defaultProperties = styleSheet.defaultProperties
        let properties = styleSheet.getProperties(for: HeadingNode.selector(level: 1))!

        #expect(defaultProperties[TextProperty.font] == .string(textFont))
        #expect(defaultProperties[TextProperty.size] == .fontSize(FontSize(12)))

        #expect(properties[TextProperty.font] == .string(headingFont))
        #expect(properties[TextProperty.size] == .fontSize(FontSize(20)))
    }

    private static let headingFont = "Latin Modern Sans"
    private static let textFont = "Latin Modern Roman"
    private static let mathFont = "Latin Modern Math"

    static func sampleStyleSheet() -> StyleSheet {
        let styleRules: StyleRules = [
            // H1
            HeadingNode.selector(level: 1): [
                TextProperty.font: .string(headingFont),
                TextProperty.size: .fontSize(FontSize(20)),
                TextProperty.foregroundColor: .color(.blue),
            ],
        ]

        let defaultProperties: PropertyMapping =
            [
                // text
                TextProperty.font: .string(textFont),
                TextProperty.size: .fontSize(FontSize(12)),
                TextProperty.stretch: .fontStretch(.normal),
                TextProperty.style: .fontStyle(.normal),
                TextProperty.weight: .fontWeight(.regular),
                TextProperty.foregroundColor: .color(.black),
                // equation
                MathProperty.font: .string(mathFont),
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
