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

    public static var defaultValue: Record { newComputerModern }

    static var concrete: Record { .init("Concrete", StyleSheets.concrete) }
    static var libertinus: Record { .init("Libertinus", StyleSheets.libertinus) }
    static var newComputerModern: Record {
      .init("New Computer Modern", StyleSheets.newComputerModern)
    }
    static var noto: Record { .init("Noto", StyleSheets.noto) }
    static var stixTwo: Record { .init("STIX Two", StyleSheets.stixTwo) }

    static var allCases: Array<Record> {
      [concrete, libertinus, newComputerModern, noto, stixTwo]
    }
  }

  public static let allCases: Array<Record> = Record.allCases

  public static let textSizes: Array<FontSize> = [
    .init(10),
    .init(11),
    .init(12),
    .init(13),
    .init(14),
  ]

  /// Concrete Math (Knuth)
  private static func concrete(_ textSize: FontSize) -> StyleSheet {
    styleSheet(
      for: textSize,
      textFont: "CMU Concrete",
      mathFont: "Concrete Math",
      headerFont: "NewComputerModern10")
  }

  internal static func libertinus(_ textSize: FontSize) -> StyleSheet {
    styleSheet(
      for: textSize,
      textFont: "Libertinus Serif",
      mathFont: "Libertinus Math",
      headerFont: "Libertinus Sans")
  }

  internal static func newComputerModern(_ textSize: FontSize) -> StyleSheet {
    styleSheet(
      for: textSize,
      textFont: "NewComputerModern10",
      mathFont: "NewComputerModernMath",
      headerFont: "NewComputerModernSans10")
  }

  internal static func noto(_ textSize: FontSize) -> StyleSheet {
    styleSheet(
      for: textSize,
      textFont: "Noto Serif",
      mathFont: "Noto Sans Math",
      headerFont: "Noto Sans")
  }

  internal static func stixTwo(_ textSize: FontSize) -> StyleSheet {
    styleSheet(
      for: textSize,
      textFont: "STIX Two Text",
      mathFont: "STIX Two Math",
      headerFont: "Arial")
  }

  private static func styleSheet(
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
    let strongColor = emphasisColor

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
      EmphasisNode.selector(): [
        TextProperty.foregroundColor: .color(emphasisColor)
      ],
      // strong
      StrongNode.selector(): [
        TextProperty.foregroundColor: .color(strongColor)
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
