// Copyright 2024-2025 Lie Yan

import AppKit

public struct TextProperty: PropertyAggregate {
  public let font: String
  public let size: FontSize
  public let stretch: FontStretch
  public let style: FontStyle
  public let weight: FontWeight

  public let foregroundColor: Color

  public init(
    font: String,
    size: FontSize,
    stretch: FontStretch,
    style: FontStyle,
    weight: FontWeight,
    foregroundColor: Color
  ) {
    self.font = font
    self.size = size
    self.stretch = stretch
    self.style = style
    self.weight = weight
    self.foregroundColor = foregroundColor
  }

  public func properties() -> PropertyDictionary {
    [
      TextProperty.font: .string(font),
      TextProperty.size: .fontSize(size),
      TextProperty.stretch: .fontStretch(stretch),
      TextProperty.style: .fontStyle(style),
      TextProperty.weight: .fontWeight(weight),
      TextProperty.foregroundColor: .color(foregroundColor),
    ]
  }

  public func attributes() -> [NSAttributedString.Key: Any] {
    guard let font = NSFont(descriptor: fontDescriptor(), size: size.floatValue)
    else { return [.foregroundColor: foregroundColor.nsColor] }
    return [.font: font, .foregroundColor: foregroundColor.nsColor]
  }

  public func fontDescriptor() -> NSFontDescriptor {
    NSFontDescriptor(name: font, size: size.floatValue)
      .withSymbolicTraits([
        stretch.symbolicTraits(),
        style.symbolicTraits(),
        weight.symbolicTraits(),
      ])
  }

  public static func resolve(
    _ properties: PropertyDictionary,
    _ fallback: PropertyMapping
  ) -> TextProperty {
    func resolved(_ key: PropertyKey) -> PropertyValue {
      key.resolve(properties, fallback)
    }

    return TextProperty(
      font: resolved(font).string()!,
      size: resolved(size).fontSize()!,
      stretch: resolved(stretch).fontStretch()!,
      style: resolved(style).fontStyle()!,
      weight: resolved(weight).fontWeight()!,
      foregroundColor: resolved(foregroundColor).color()!
    )
  }

  // MARK: - Key

  public static let font = PropertyKey(.text, .fontFamily)  // String
  public static let size = PropertyKey(.text, .fontSize)  // FontSize
  public static let stretch = PropertyKey(.text, .fontStretch)  // FontStretch
  public static let style = PropertyKey(.text, .fontStyle)  // FontStyle
  public static let weight = PropertyKey(.text, .fontWeight)  // FontWeight
  public static let foregroundColor = PropertyKey(.text, .foregroundColor)  // Color

  public static let typeRegistry: PropertyTypeRegistry = [
    font: .string,
    size: .fontSize,
    stretch: .fontStretch,
    style: .fontStyle,
    weight: .fontWeight,
    foregroundColor: .color,
  ]

  public static let allKeys: [PropertyKey] = typeRegistry.keys.map { $0 }
}
