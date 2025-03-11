// Copyright 2024-2025 Lie Yan

import AppKit

public struct ParagraphProperty: PropertyAggregate {
  public let topMargin: Double
  public let bottomMargin: Double
  public let topPadding: Double
  public let bottomPadding: Double

  public func getProperties() -> PropertyDictionary {
    [
      ParagraphProperty.topMargin: .float(topMargin),
      ParagraphProperty.bottomMargin: .float(bottomMargin),
      ParagraphProperty.topPadding: .float(topPadding),
      ParagraphProperty.bottomPadding: .float(bottomMargin),
    ]
  }

  public func getAttributes() -> [NSAttributedString.Key: Any] {
    [:]
  }

  public static func resolve(
    _ properties: PropertyDictionary, _ fallback: PropertyMapping
  ) -> ParagraphProperty {
    func resolved(_ key: PropertyKey) -> PropertyValue {
      key.resolve(properties, fallback)
    }

    return ParagraphProperty(
      topMargin: resolved(topMargin).float()!,
      bottomMargin: resolved(bottomMargin).float()!,
      topPadding: resolved(topPadding).float()!,
      bottomPadding: resolved(bottomPadding).float()!
    )
  }

  // MARK: - Key

  public static let topMargin = PropertyKey(.paragraph, .topMargin)  // AbsLength
  public static let bottomMargin = PropertyKey(.paragraph, .bottomMargin)  // AbsLength
  public static let topPadding = PropertyKey(.paragraph, .topPadding)  // AbsLength
  public static let bottomPadding = PropertyKey(.paragraph, .bottomPadding)  // AbsLength

  public static let allKeys: [PropertyKey] = [
    topMargin,
    bottomMargin,
    topPadding,
    bottomPadding,
  ]
}
