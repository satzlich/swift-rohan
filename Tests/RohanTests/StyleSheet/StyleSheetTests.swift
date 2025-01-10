// Copyright 2024-2025 Lie Yan

import Rohan
import Testing

struct StyleSheetTests {
    @Test
    static func testStyleSheet() {
        let styleSheet = StyleSheet(styleRules, defaultProperties)

        let defaultProperties = styleSheet.defaultProperties
        let properties = styleSheet.getProperties(for: Heading.selector(level: 1))!

        #expect(defaultProperties[Text.font] == .string("Latin Modern Roman"))
        #expect(defaultProperties[Text.size] == .fontSize(FontSize(12)))

        #expect(properties[Text.font] == .string("Latin Modern Sans"))
        #expect(properties[Text.size] == .fontSize(FontSize(20)))
    }

    @Test
    static func test_getProperties() {
        let content = NodeTests.sampleContent()
        let styleSheet = StyleSheet(styleRules, defaultProperties)

        do {
            let heading = (content.getChild(0) as! HeadingNode)
            let emphasis = heading.getChild(1) as! EmphasisNode

            let headingProperties = heading.getProperties(with: styleSheet)
            let emphasisProperties = emphasis.getProperties(with: styleSheet)

            #expect(headingProperties[Text.style] == .fontStyle(.italic))
            #expect(emphasisProperties[Text.style] == .fontStyle(.normal))
        }

        do {
            let paragraph = (content.getChild(1) as! ParagraphNode)
            let emphasis = paragraph.getChild(1) as! EmphasisNode
            let equation = paragraph.getChild(2) as! EquationNode

            let paragraphProperties = paragraph.getProperties(with: styleSheet)
            let emphasisProperties = emphasis.getProperties(with: styleSheet)
            let equationProperties = equation.getProperties(with: styleSheet)

            #expect(paragraphProperties.isEmpty)
            #expect(emphasisProperties[Text.style] == .fontStyle(.italic))
            #expect(equationProperties[Equation.style] == .mathStyle(.text))
        }
    }

    static let styleRules: StyleRules = [
        // H1
        Heading.selector(level: 1): [
            Text.font: .string("Latin Modern Sans"),
            Text.size: .fontSize(FontSize(20)),
            Text.style: .fontStyle(.italic),
        ],

        // inline equation
        Equation.selector(isBlock: false): [
            Equation.style: .mathStyle(.text),
        ],
    ]

    static let defaultProperties: PropertyMap =
        [
            // text
            Text.font: .string("Latin Modern Roman"),
            Text.size: .fontSize(FontSize(12)),
            Text.stretch: .fontStretch(.normal),
            Text.style: .fontStyle(.normal),
            Text.weight: .fontWeight(.regular),
            // equation
            Equation.font: .string("Latin Modern Math"),
            Equation.bold: .bool(false),
            Equation.italic: .none,
            Equation.cramped: .bool(false),
            Equation.style: .mathStyle(.display),
            Equation.variant: .mathVariant(.serif),
            // paragraph
            Paragraph.topMargin: .absLength(.zero),
            Paragraph.bottomMargin: .absLength(.zero),
            Paragraph.topPadding: .absLength(.zero),
            Paragraph.bottomPadding: .absLength(.zero),
        ]
}
