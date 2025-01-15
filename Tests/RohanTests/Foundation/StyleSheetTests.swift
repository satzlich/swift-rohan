// Copyright 2024-2025 Lie Yan

import Rohan
import Testing

struct StyleSheetTests {
    @Test
    static func testStyleSheet() {
        let styleSheet = StyleSheet(styleRules, defaultProperties)

        let defaultProperties = styleSheet.defaultProperties
        let properties = styleSheet.getProperties(for: Heading.selector(level: 1))!

        #expect(defaultProperties[TextProperty.font] == .string(textFont))
        #expect(defaultProperties[TextProperty.size] == .fontSize(FontSize(12)))

        #expect(properties[TextProperty.font] == .string(h1Font))
        #expect(properties[TextProperty.size] == .fontSize(FontSize(20)))
    }

//    @Test
//    static func test_getProperties() {
//        let content = NodeTests.sampleContentNode()
//        let styleSheet = StyleSheet(styleRules, defaultProperties)
//
//        do {
//            let heading = (content.getChild(0) as! HeadingNode)
//            let emphasis = heading.getChild(1) as! EmphasisNode
//
//            let headingProperties = heading.getProperties(with: styleSheet)
//            let emphasisProperties = emphasis.getProperties(with: styleSheet)
//
//            #expect(headingProperties[TextProperty.style] == .fontStyle(.italic))
//            #expect(emphasisProperties[TextProperty.style] == .fontStyle(.normal))
//        }
//
//        do {
//            let paragraph = (content.getChild(1) as! ParagraphNode)
//            let emphasis = paragraph.getChild(1) as! EmphasisNode
//            let equation = paragraph.getChild(2) as! EquationNode
//
//            let paragraphProperties = paragraph.getProperties(with: styleSheet)
//            let emphasisProperties = emphasis.getProperties(with: styleSheet)
//            let equationProperties = equation.getProperties(with: styleSheet)
//
//            #expect(paragraphProperties.isEmpty)
//
//            #expect(emphasisProperties[TextProperty.font] == nil)
//            #expect(emphasisProperties[TextProperty.style] == .fontStyle(.italic))
//            #expect(emphasisProperties[RootProperty.layoutMode] == nil)
//
//            #expect(equationProperties[MathProperty.font] == nil)
//            #expect(equationProperties[MathProperty.style] == .mathStyle(.text))
//            #expect(equationProperties[RootProperty.layoutMode] == .layoutMode(.math))
//        }
//    }

    static func sampleStyleSheet() -> StyleSheet {
        StyleSheet(styleRules, defaultProperties)
    }

    private static let h1Font = "Latin Modern Sans"
    private static let textFont = "Latin Modern Roman"
    private static let mathFont = "Latin Modern Math"

    private static let styleRules: StyleRules = [
        // H1
        Heading.selector(level: 1): [
            TextProperty.font: .string(h1Font),
            TextProperty.size: .fontSize(FontSize(20)),
            TextProperty.style: .fontStyle(.italic),
            TextProperty.foregroundColor: .color(.blue),
        ],

        // inline equation
        Equation.selector(isBlock: false): [
            MathProperty.style: .mathStyle(.text),
        ],
    ]

    private static let defaultProperties: PropertyMapping =
        [
            // root
            RootProperty.layoutMode: .layoutMode(.horizontal),
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
            ParagraphProperty.topMargin: .absLength(.zero),
            ParagraphProperty.bottomMargin: .absLength(.zero),
            ParagraphProperty.topPadding: .absLength(.zero),
            ParagraphProperty.bottomPadding: .absLength(.zero),
        ]
}
