// Copyright 2024-2025 Lie Yan

import Cocoa
import Foundation

public enum StyleSheets {
  public typealias StyleSheetProvider = (FontSize) -> StyleSheet

  public static let setA: [(String, StyleSheetProvider)] = [
    ("CMU Concrete", concreteMath),
    ("Latin Modern", taocpKnuth),
    ("Libertinus", libertinus),
    ("STIX Two", stixTwo),
  ]

  public static let setB: [(String, StyleSheetProvider)] = [
    ("Latin Modern #2", geometrieAudin),
    ("Latin Modern #3", latinModern),
  ]

  public static func latinModern(_ textSize: FontSize) -> StyleSheet {
    styleSheet(
      for: textSize,
      textFont: "Latin Modern Roman",
      mathFont: "Latin Modern Math",
      headerFont: "Latin Modern Roman")
  }

  public static func libertinus(_ textSize: FontSize) -> StyleSheet {
    styleSheet(
      for: textSize,
      textFont: "Libertinus Serif",
      mathFont: "Libertinus Math",
      headerFont: "Libertinus Sans")
  }

  public static func stixTwo(_ textSize: FontSize) -> StyleSheet {
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

    let h1Size = FontSize(textSize.floatValue + 8)
    let h2Size = FontSize(textSize.floatValue + 4)
    let h3Size = FontSize(textSize.floatValue + 2)

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
      // equation
      EquationNode.selector(isBlock: true): [
        ParagraphProperty.textAlignment: .textAlignment(.center)
      ],
    ]

    let defaultProperties = defaultProperties(textFont, textSize, mathFont)

    return StyleSheet(styleRules, defaultProperties)
  }

  /// Concrete Math (Knuth)
  private static func concreteMath(_ textSize: FontSize) -> StyleSheet {
    let textFont = "CMU Concrete"
    let mathFont = "Euler Math"
    let headerFont = "Latin Modern Roman"

    let styleRules = commonStyleRules(textFont, textSize, headerFont)
    let defaultProperties = defaultProperties(textFont, textSize, mathFont)

    return StyleSheet(styleRules, defaultProperties)
  }

  /// Géométrie (Audin)
  private static func geometrieAudin(_ textSize: FontSize) -> StyleSheet {
    let textFont = "Latin Modern Roman"
    let mathFont = "Latin Modern Math"

    let headerFont = "Latin Modern Roman"
    let h1Size = FontSize(textSize.floatValue + 8)
    let h2Size = FontSize(textSize.floatValue + 4)
    let h3Size = FontSize(textSize.floatValue + 2)
    let headerColor = Color.blue
    let headerAlignment = NSTextAlignment.right

    let styleRules: StyleRules = [
      // H1
      HeadingNode.selector(level: 1): [
        TextProperty.font: .string(headerFont),
        TextProperty.size: .fontSize(h1Size),
        TextProperty.weight: .fontWeight(.bold),
        TextProperty.foregroundColor: .color(headerColor),
        ParagraphProperty.textAlignment: .textAlignment(headerAlignment),
      ],
      // H2
      HeadingNode.selector(level: 2): [
        TextProperty.font: .string(headerFont),
        TextProperty.size: .fontSize(h2Size),
        TextProperty.weight: .fontWeight(.bold),
        TextProperty.foregroundColor: .color(headerColor),
        ParagraphProperty.textAlignment: .textAlignment(headerAlignment),
      ],
      // H3
      HeadingNode.selector(level: 3): [
        TextProperty.font: .string(headerFont),
        TextProperty.size: .fontSize(h3Size),
        TextProperty.weight: .fontWeight(.bold),
        TextProperty.foregroundColor: .color(headerColor),
        ParagraphProperty.textAlignment: .textAlignment(headerAlignment),
      ],
      // H4 (textSize + italic)
      HeadingNode.selector(level: 4): [
        TextProperty.font: .string(headerFont),
        TextProperty.size: .fontSize(textSize),
        TextProperty.style: .fontStyle(.italic),
        TextProperty.foregroundColor: .color(headerColor),
        ParagraphProperty.textAlignment: .textAlignment(headerAlignment),
      ],
      // H5 (textSize)
      HeadingNode.selector(level: 5): [
        TextProperty.font: .string(headerFont),
        TextProperty.size: .fontSize(textSize),
        TextProperty.foregroundColor: .color(headerColor),
        ParagraphProperty.textAlignment: .textAlignment(headerAlignment),
      ],
      // equation
      EquationNode.selector(isBlock: true): [
        ParagraphProperty.textAlignment: .textAlignment(.center)
      ],
    ]

    let defaultProperties = defaultProperties(textFont, textSize, mathFont)
    return StyleSheet(styleRules, defaultProperties)
  }

  /// The Art of Computer Programming (Knuth)
  /// Matrix Computations (Golub et Van Loan)
  static func taocpKnuth(_ textSize: FontSize) -> StyleSheet {
    let textFont = "Latin Modern Roman"
    let mathFont = "Latin Modern Math"
    let headerFont = "Latin Modern Sans"

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
      ParagraphProperty.textAlignment: .textAlignment(.natural),
      ParagraphProperty.paragraphSpacing: .float(0.5 * textSize.floatValue),
      // page (a4)
      PageProperty.width: .absLength(.mm(210)),
      PageProperty.height: .absLength(.mm(297)),
      PageProperty.topMargin: .absLength(.mm(25)),
      PageProperty.bottomMargin: .absLength(.mm(25)),
      PageProperty.leftMargin: .absLength(.mm(25)),
      PageProperty.rightMargin: .absLength(.mm(25)),
    ]
  }
}
