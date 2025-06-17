// Copyright 2024-2025 Lie Yan

import Cocoa
import Foundation

public enum StyleSheets {
  public typealias StyleSheetProvider = (FontSize) -> StyleSheet

  public struct Record {
    public let name: String
    public let provider: StyleSheetProvider

    public init(_ name: String, _ provider: @escaping StyleSheetProvider) {
      self.name = name
      self.provider = provider
    }
  }

  public static let defaultRecord = allRecords[2]  // "New Computer Modern"
  public static let defaultTextSize = textSizes[2]  // 12pt
  public static let testingRecord =
    Record(
      "Testing",
      { textSize in
        styleSheet(
          for: textSize,
          textFont: "NewComputerModern10", mathFont: "NewComputerModernMath",
          headerFont: "NewComputerModernSans10")
      }
    )

  public static let allRecords: Array<Record> =
    [
      // (name, textFont, mathFont, headerFont)
      ("Concrete", "CMU Concrete", "Concrete Math", "NewComputerModern10"),
      ("Libertinus", "Libertinus Serif", "Libertinus Math", "Libertinus Sans"),
      (
        "New Computer Modern", "NewComputerModern10", "NewComputerModernMath",
        "NewComputerModernSans10"
      ),
      ("Noto", "Noto Serif", "Noto Sans Math", "Noto Sans"),
      ("STIX Two", "STIX Two Text", "STIX Two Math", "Arial"),
    ]
    .map { name, textFont, mathFont, headerFont in
      Record(
        name,
        { textSize in
          styleSheet(
            for: textSize,
            textFont: textFont,
            mathFont: mathFont,
            headerFont: headerFont)
        })
    }

  public static let textSizes: Array<FontSize> = [
    FontSize(10),
    FontSize(11),
    FontSize(12),
    FontSize(13),
    FontSize(14),
  ]

  // MARK: - Create StyleSheet

  internal static func styleSheet(
    for textSize: FontSize,
    textFont: String,
    mathFont: String,
    headerFont: String
  ) -> StyleSheet {
    let styleRules = commonStyleRules(textFont, textSize, headerFont)
    let defaultProperties = defaultProperties(textFont, textSize, mathFont)
    return StyleSheet(styleRules, defaultProperties)
  }

  private static func commonStyleRules(
    _ textFont: String, _ textSize: FontSize, _ headerFont: String
  ) -> StyleRules {
    let h1Size = FontSize(textSize.floatValue + 8)
    let h2Size = FontSize(textSize.floatValue + 4)
    let h3Size = FontSize(textSize.floatValue + 2)

    let emphasisColor = Color.brown
    let strongColor = Color.brown

    let styleRules: StyleRules = [
      // H1
      HeadingNode.selector(level: 1): [
        TextProperty.font: .string(headerFont),
        TextProperty.size: .fontSize(h1Size),
        TextProperty.weight: .fontWeight(.bold),
      ],
      // H2
      HeadingNode.selector(level: 2): [
        TextProperty.font: .string(headerFont),
        TextProperty.size: .fontSize(h2Size),
        TextProperty.weight: .fontWeight(.bold),
      ],
      // H3
      HeadingNode.selector(level: 3): [
        TextProperty.font: .string(headerFont),
        TextProperty.size: .fontSize(h3Size),
        TextProperty.weight: .fontWeight(.bold),
      ],
      // H4 (textSize + italic)
      HeadingNode.selector(level: 4): [
        TextProperty.font: .string(headerFont),
        TextProperty.size: .fontSize(textSize),
        TextProperty.style: .fontStyle(.italic),
      ],
      // H5 (textSize)
      HeadingNode.selector(level: 5): [
        TextProperty.font: .string(headerFont),
        TextProperty.size: .fontSize(textSize),
      ],
      // emphasis
      TextStylesNode.selector(command: TextStyles.emph.command): [
        TextProperty.foregroundColor: .color(emphasisColor)
      ],
      // strong
      TextStylesNode.selector(command: TextStyles.textbf.command): [
        TextProperty.foregroundColor: .color(strongColor)
      ],
      // equation
      EquationNode.selector(isBlock: true): [
        ParagraphProperty.textAlignment: .textAlignment(.center)
      ],
      // multiline
      MultilineNode.selector(isMultline: true): [
        ParagraphProperty.textAlignment: .textAlignment(.right)
      ],
      MultilineNode.selector(isMultline: false): [
        ParagraphProperty.textAlignment: .textAlignment(.center)
      ],
    ]

    return styleRules
  }

  private static func defaultProperties(
    _ textFont: String,
    _ textSize: FontSize,
    _ mathFont: String
  ) -> PropertyMapping {
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
      ParagraphProperty.textAlignment: .textAlignment(.justified),
      ParagraphProperty.paragraphSpacing: .float(0.5 * textSize.floatValue),
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
  }
}
