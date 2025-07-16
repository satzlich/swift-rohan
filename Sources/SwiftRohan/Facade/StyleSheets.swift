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

  nonisolated(unsafe) public static let defaultRecord =
    allRecords.first(where: { $0.name == "New Computer Modern" }) ?? allRecords[0]

  public static let defaultTextSize = textSizes[2]  // 12pt

  nonisolated(unsafe) public static let testingRecord =
    Record(
      "Testing",
      { textSize in
        styleSheet(
          for: textSize,
          textFont: "NewComputerModern10",
          mathFont: "NewComputerModernMath",
          headerFont: "NewComputerModernSans10",
          monoFont: "NewComputerModernMono10")
      }
    )

  nonisolated(unsafe) public static let allRecords: Array<Record> =
    [
      // (name, textFont, mathFont, headerFont, monoFont)
      (
        "Libertinus", "Libertinus Serif", "Libertinus Math", "Libertinus Sans", "PT Mono"
      ),
      (
        "New Computer Modern", "NewComputerModern10", "NewComputerModernMath",
        "NewComputerModernSans10", "NewComputerModernMono10"
      ),
      ("Noto", "Noto Serif", "Noto Sans Math", "Noto Sans", "Noto Sans Mono"),
      ("STIX Two", "STIX Two Text", "STIX Two Math", "Arial", "PT Mono"),
    ]
    .map { name, textFont, mathFont, headerFont, monoFont in
      Record(
        name,
        { textSize in
          styleSheet(
            for: textSize,
            textFont: textFont,
            mathFont: mathFont,
            headerFont: headerFont,
            monoFont: monoFont)
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
    headerFont: String,
    monoFont: String
  ) -> StyleSheet {
    let styleRules = commonStyleRules(textFont, textSize, headerFont, monoFont)
    let defaultProperties = defaultProperties(textFont, textSize, mathFont)
    return StyleSheet(styleRules, defaultProperties)
  }

  private static func commonStyleRules(
    _ textFont: String, _ textSize: FontSize, _ headerFont: String, _ monoFont: String
  ) -> StyleRules {
    let h1Size = FontSize(textSize.floatValue + 8)
    let h2Size = FontSize(textSize.floatValue + 4)
    let h3Size = FontSize(textSize.floatValue + 2)

    let emphasisColor = Color.brown

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
      // emph
      TextStylesNode.selector(command: TextStyles.emph.command): [
        TextProperty.foregroundColor: .color(emphasisColor)
      ],
      // texttt
      TextStylesNode.selector(command: TextStyles.texttt.command): [
        TextProperty.font: .string(monoFont)
      ],
      // equation
      EquationNode.selector(isBlock: true): [
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
      ParagraphProperty.firstLineHeadIndent: .float(0),
      ParagraphProperty.headIndent: .float(0),
      ParagraphProperty.listLevel: .integer(0),
      ParagraphProperty.paragraphSpacing: .float(0.5 * textSize.floatValue),
      ParagraphProperty.textAlignment: .textAlignment(.justified),
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
