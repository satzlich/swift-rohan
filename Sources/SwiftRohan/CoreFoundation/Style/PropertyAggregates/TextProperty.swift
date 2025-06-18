// Copyright 2024-2025 Lie Yan

import AppKit

internal struct TextProperty: PropertyAggregate, Equatable, Hashable, Sendable {

  public func getAttributes() -> Dictionary<NSAttributedString.Key, Any> {
    self.getAttributes(isFlipped: false)
  }

  public static func resolveAggregate(
    _ properties: PropertyDictionary, _ fallback: PropertyMapping
  ) -> TextProperty {
    func resolved(_ key: PropertyKey) -> PropertyValue {
      key.resolveValue(properties, fallback)
    }

    return TextProperty(
      font: resolved(font).string()!,
      size: resolved(size).fontSize()!,
      stretch: resolved(stretch).fontStretch()!,
      style: resolved(style).fontStyle()!,
      weight: resolved(weight).fontWeight()!,
      foregroundColor: resolved(foregroundColor).color()!)
  }

  public static let allKeys: Array<PropertyKey> = [
    font,
    size,
    stretch,
    style,
    weight,
    foregroundColor,
  ]

  // MARK: - Implementation

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

  internal func getAttributes(isFlipped: Bool) -> Dictionary<NSAttributedString.Key, Any>
  {
    let key = _AttributesKey(self, isFlipped)
    func create() -> Dictionary<NSAttributedString.Key, Any> {
      _createAttributes(isFlipped: isFlipped)
    }
    return TextProperty._attributesCache.getOrCreate(key, create)
  }

  // MARK: - Cache

  private struct _AttributesKey: Hashable {
    let textProperty: TextProperty
    let isFlipped: Bool

    init(_ textProperty: TextProperty, _ isFlipped: Bool) {
      self.textProperty = textProperty
      self.isFlipped = isFlipped
    }
  }

  private typealias _AttributesCache =
    ConcurrentCache<_AttributesKey, Dictionary<NSAttributedString.Key, Any>>

  nonisolated(unsafe) private static let _attributesCache = _AttributesCache()

  private func _createAttributes(
    isFlipped: Bool
  ) -> Dictionary<NSAttributedString.Key, Any> {
    let descriptor = _getFontDescriptor()
    let size = size.floatValue
    let font = NSFont(descriptor: descriptor, size: size, isFlipped: isFlipped)
    if let font = font {
      return [.font: font, .foregroundColor: foregroundColor.nsColor]
    }
    // fallback
    return [.foregroundColor: foregroundColor.nsColor]
  }

  private func _getFontDescriptor() -> NSFontDescriptor {
    NSFontDescriptor(name: font, size: size.floatValue)
      .withSymbolicTraits([
        stretch.symbolicTraits(),
        style.symbolicTraits(),
        weight.symbolicTraits(),
      ])
  }

  public static let font = PropertyKey(.text, .fontFamily)  // String
  public static let size = PropertyKey(.text, .fontSize)  // FontSize
  public static let stretch = PropertyKey(.text, .fontStretch)  // FontStretch
  public static let style = PropertyKey(.text, .fontStyle)  // FontStyle
  public static let weight = PropertyKey(.text, .fontWeight)  // FontWeight
  public static let foregroundColor = PropertyKey(.text, .foregroundColor)  // Color

}
