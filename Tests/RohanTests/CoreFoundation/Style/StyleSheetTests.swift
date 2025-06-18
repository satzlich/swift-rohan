// Copyright 2024-2025 Lie Yan

import Testing

@testable import SwiftRohan

struct StyleSheetTests {
  @Test
  static func getProperties() {
    let styleSheet = testingStyleSheet()

    let defaultProperties = styleSheet.defaultProperties
    let properties = styleSheet.getProperties(for: HeadingNode.selector(level: 1))!

    #expect(defaultProperties[TextProperty.font] == .string(textFont))
    #expect(defaultProperties[TextProperty.size] == .fontSize(FontSize(12)))

    #expect(properties[TextProperty.font] == .string(headingFont))
    #expect(properties[TextProperty.size] == .fontSize(FontSize(20)))
  }

  @Test
  static func coverage() {
    let styleSheet = testingStyleSheet()

    let font = styleSheet.resolveDefault(TextProperty.font).string()
    #expect(font == textFont)

    _ = styleSheet.resolveDefault() as TextProperty
  }

  private static let headingFont = "Latin Modern Sans"
  private static let textFont = "Latin Modern Roman"
  private static let mathFont = "Latin Modern Math"

  internal static func testingStyleSheet() -> StyleSheet {
    let textSize = FontSize(12)
    let h1Size = FontSize(textSize.floatValue + 8)
    let h2Size = FontSize(textSize.floatValue + 6)
    let h3Size = FontSize(textSize.floatValue + 4)
    let h4Size = FontSize(textSize.floatValue + 2)
    let h5Size = FontSize(textSize.floatValue + 1)

    let styleRules: StyleRules = [
      // H1
      HeadingNode.selector(level: 1): [
        TextProperty.font: .string(headingFont),
        TextProperty.size: .fontSize(h1Size),
        TextProperty.foregroundColor: .color(.blue),
      ],
      // H2
      HeadingNode.selector(level: 2): [
        TextProperty.font: .string(headingFont),
        TextProperty.size: .fontSize(h2Size),
        TextProperty.foregroundColor: .color(.blue),
      ],
      // H3
      HeadingNode.selector(level: 3): [
        TextProperty.font: .string(headingFont),
        TextProperty.size: .fontSize(h3Size),
        TextProperty.foregroundColor: .color(.blue),
      ],
      // H4
      HeadingNode.selector(level: 4): [
        TextProperty.font: .string(headingFont),
        TextProperty.size: .fontSize(h4Size),
        TextProperty.foregroundColor: .color(.blue),
      ],
      // H5
      HeadingNode.selector(level: 5): [
        TextProperty.font: .string(headingFont),
        TextProperty.size: .fontSize(h5Size),
        TextProperty.foregroundColor: .color(.blue),
      ],
    ]

    let defaultProperties: PropertyMapping =
      [

        // text
        TextProperty.font: .string(textFont),
        TextProperty.size: .fontSize(textSize),
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
        ParagraphProperty.listLevel: .integer(0),
        ParagraphProperty.paragraphSpacing: .float(0),
        ParagraphProperty.textAlignment: .textAlignment(.left),
        // page (a4)
        PageProperty.width: .absLength(.mm(210)),
        PageProperty.height: .absLength(.mm(297)),
        PageProperty.topMargin: .absLength(.mm(25)),
        PageProperty.bottomMargin: .absLength(.mm(25)),
        PageProperty.leftMargin: .absLength(.mm(25)),
        PageProperty.rightMargin: .absLength(.mm(25)),
        // internal
        InternalProperty.nestedLevel: .integer(0),
      ]
    return StyleSheet(styleRules, defaultProperties)
  }
}
