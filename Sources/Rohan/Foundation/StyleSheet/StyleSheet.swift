// Copyright 2024-2025 Lie Yan

import Foundation

public typealias StyleRules = [TargetSelector: PropertyDictionary]

public final class StyleSheet: Sendable {
  private let styleRules: StyleRules
  public let defaultProperties: PropertyMapping

  public init(_ styleRules: StyleRules, _ defaultProperties: PropertyMapping) {
    self.styleRules = styleRules
    self.defaultProperties = defaultProperties
  }

  /// Styles for the given selector
  public func getProperties(for selector: TargetSelector) -> PropertyDictionary? {
    styleRules[selector]
  }

  public static func latinModern(_ textSize: FontSize) -> StyleSheet {
    predefined(
      textSize, textFont: "Latin Modern Roman",
      mathFont: "Latin Modern Math", headerFont: "Latin Modern Sans")
  }

  public static func eulerMath(_ textSize: FontSize) -> StyleSheet {
    predefined(
      textSize, textFont: "Palatino", mathFont: "Euler Math", headerFont: "Arial")
  }

  private static func predefined(
    _ textSize: FontSize, textFont: String, mathFont: String, headerFont: String
  ) -> StyleSheet {

    let h1Size = FontSize(textSize.floatValue + 8)
    let h2Size = FontSize(textSize.floatValue + 6)
    let h3Size = FontSize(textSize.floatValue + 4)
    let h4Size = FontSize(textSize.floatValue + 2)
    let h5Size = FontSize(textSize.floatValue + 1)

    let styleRules: StyleRules = [
      // H1
      HeadingNode.selector(level: 1): [
        TextProperty.font: .string(headerFont),
        TextProperty.size: .fontSize(h1Size),
        TextProperty.style: .fontStyle(.italic),
        TextProperty.foregroundColor: .color(.blue),
      ],
      // H2
      HeadingNode.selector(level: 2): [
        TextProperty.font: .string(headerFont),
        TextProperty.size: .fontSize(h2Size),
        TextProperty.foregroundColor: .color(.blue),
      ],
      // H3
      HeadingNode.selector(level: 3): [
        TextProperty.font: .string(headerFont),
        TextProperty.size: .fontSize(h3Size),
        TextProperty.foregroundColor: .color(.blue),
      ],
      // H4
      HeadingNode.selector(level: 4): [
        TextProperty.font: .string(headerFont),
        TextProperty.size: .fontSize(h4Size),
        TextProperty.foregroundColor: .color(.blue),
      ],
      // H5
      HeadingNode.selector(level: 5): [
        TextProperty.font: .string(headerFont),
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
        ParagraphProperty.topMargin: .float(textSize.floatValue * 1.5),
        ParagraphProperty.bottomMargin: .float(textSize.floatValue * 1.5),
        ParagraphProperty.topPadding: .float(.zero),
        ParagraphProperty.bottomPadding: .float(.zero),
      ]

    return StyleSheet(styleRules, defaultProperties)
  }
}
