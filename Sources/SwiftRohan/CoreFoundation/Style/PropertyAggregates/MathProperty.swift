// Copyright 2024-2025 Lie Yan

import AppKit

public struct MathProperty: PropertyAggregate {
  // MARK: - PropertyAggregate

  public static func resolveAggregate(
    _ properties: PropertyDictionary,
    _ fallback: PropertyMapping
  ) -> MathProperty {
    func resolved(_ key: PropertyKey) -> PropertyValue {
      key.resolveValue(properties, fallback)
    }

    return MathProperty(
      font: resolved(font).string()!,
      bold: resolved(bold).bool()!,
      italic: resolved(italic).bool(),  // no force unwrap
      cramped: resolved(cramped).bool()!,
      style: resolved(style).mathStyle()!,
      variant: resolved(variant).mathVariant()!
    )
  }

  public static let allKeys: [PropertyKey] = [
    font,
    bold,
    italic,
    cramped,
    style,
    variant,
  ]

  // MARK: - Implementation

  public let font: String
  public let bold: Bool
  public let italic: Bool?
  public let cramped: Bool
  public let style: MathStyle
  public let variant: MathVariant

  /// Resolve NSAttributedString attributes together with text properties and math context.
  internal func getAttributes(
    isFlipped: Bool, _ textProperty: TextProperty, _ mathContext: MathContext
  ) -> [NSAttributedString.Key: Any] {
    let italic = italic ?? Rohan.autoItalic
    let style = italic ? FontStyle.italic : FontStyle.normal
    let weight = bold ? FontWeight.bold : FontWeight.regular

    switch variant {
    case .bb, .cal, .frak, .mono, .sans:
      // user math font
      let size = FontSize(rawValue: mathContext.getFontSize())
      // for math font, stretch, style, weight should be normal
      let property = TextProperty(
        font: font, size: size, stretch: .normal, style: .normal, weight: .regular,
        foregroundColor: mathContext.textColor)
      return property.getAttributes(isFlipped: isFlipped)

    case .serif:
      // use text font
      let size = FontSize(rawValue: mathContext.getFontSize())
      let property = TextProperty(
        font: textProperty.font, size: size, stretch: textProperty.stretch, style: style,
        weight: weight, foregroundColor: mathContext.textColor)
      return property.getAttributes(isFlipped: isFlipped)
    }
  }

  // MARK: - Key

  public static let font = PropertyKey(.equation, .fontFamily)  // String
  public static let bold = PropertyKey(.equation, .bold)  // Bool
  public static let italic = PropertyKey(.equation, .italic)  // { Bool | None }
  public static let cramped = PropertyKey(.equation, .cramped)  // Bool
  public static let style = PropertyKey(.equation, .mathStyle)  // MathStyle
  public static let variant = PropertyKey(.equation, .mathVariant)  // MathVariant
}
