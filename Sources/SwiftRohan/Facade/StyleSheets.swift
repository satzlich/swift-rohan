// Copyright 2024-2025 Lie Yan

import Foundation

public enum StyleSheets {
  public typealias StyleSheetProvider = (FontSize) -> StyleSheet

  public static let allCases: [String: StyleSheetProvider] = [
    "Euler Math": eulerMath,
    "Latin Modern": latinModern,
    "Libertinus": libertinus,
    "STIX Two Math": stixTwoMath,
  ]

  public static func eulerMath(_ textSize: FontSize) -> StyleSheet {
    styleSheet(
      for: textSize,
      textFont: "Palatino",
      mathFont: "Euler Math",
      headerFont: "Arial")
  }

  public static func latinModern(_ textSize: FontSize) -> StyleSheet {
    styleSheet(
      for: textSize,
      textFont: "Latin Modern Roman",
      mathFont: "Latin Modern Math",
      headerFont: "Latin Modern Sans")
  }

  public static func libertinus(_ textSize: FontSize) -> StyleSheet {
    styleSheet(
      for: textSize,
      textFont: "Libertinus Serif",
      mathFont: "Libertinus Math",
      headerFont: "Libertinus Sans")
  }

  public static func stixTwoMath(_ textSize: FontSize) -> StyleSheet {
    styleSheet(
      for: textSize,
      textFont: "Palatino",
      mathFont: "STIX Two Math",
      headerFont: "Arial")
  }

  private static func styleSheet(
    for textSize: FontSize,
    textFont: String,
    mathFont: String,
    headerFont: String
  ) -> StyleSheet {

    let h1Size = FontSize(textSize.floatValue + 8)
    let h2Size = FontSize(textSize.floatValue + 4)
    let h3Size = FontSize(textSize.floatValue + 2)
    let headerColor = Color.blue

    let styleRules: StyleRules = [
      // H1
      HeadingNode.selector(level: 1): [
        TextProperty.font: .string(headerFont),
        TextProperty.size: .fontSize(h1Size),
        TextProperty.foregroundColor: .color(headerColor),
      ],
      // H2
      HeadingNode.selector(level: 2): [
        TextProperty.font: .string(headerFont),
        TextProperty.size: .fontSize(h2Size),
        TextProperty.foregroundColor: .color(headerColor),
      ],
      // H3
      HeadingNode.selector(level: 3): [
        TextProperty.font: .string(headerFont),
        TextProperty.size: .fontSize(h3Size),
        TextProperty.foregroundColor: .color(headerColor),
      ],
      // H4 (textSize + italic)
      HeadingNode.selector(level: 4): [
        TextProperty.font: .string(headerFont),
        TextProperty.size: .fontSize(textSize),
        TextProperty.style: .fontStyle(.italic),
        TextProperty.foregroundColor: .color(headerColor),
      ],
      // H5 (textSize)
      HeadingNode.selector(level: 5): [
        TextProperty.font: .string(headerFont),
        TextProperty.size: .fontSize(textSize),
        TextProperty.foregroundColor: .color(headerColor),
      ],
      // H6 (textSize + darkGray)
      HeadingNode.selector(level: 6): [
        TextProperty.font: .string(headerFont),
        TextProperty.size: .fontSize(textSize),
        TextProperty.foregroundColor: .color(.darkGray),
      ],
      // equation
      EquationNode.selector(isBlock: true): [
        ParagraphProperty.textAlignment: .textAlignment(.center)
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
        ParagraphProperty.textAlignment: .textAlignment(.justified),
        // page (a4)
        PageProperty.width: .absLength(.mm(210)),
        PageProperty.height: .absLength(.mm(297)),
        PageProperty.topMargin: .absLength(.mm(25)),
        PageProperty.bottomMargin: .absLength(.mm(25)),
        PageProperty.leftMargin: .absLength(.mm(25)),
        PageProperty.rightMargin: .absLength(.mm(25)),
      ]

    return StyleSheet(styleRules, defaultProperties)
  }
}
