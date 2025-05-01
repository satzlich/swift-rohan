// Copyright 2024-2025 Lie Yan

import AppKit

public struct ParagraphProperty: PropertyAggregate, Equatable, Hashable, Sendable {
  public let textAlignment: NSTextAlignment

  public func getProperties() -> PropertyDictionary {
    [
      ParagraphProperty.textAlignment: .textAlignment(textAlignment)
    ]
  }

  public func getAttributes() -> [NSAttributedString.Key: Any] {
    Self._attributesCache.getOrCreate(self, self._createAttributes)
  }

  private typealias _AttributesCache =
    ConcurrentCache<ParagraphProperty, [NSAttributedString.Key: Any]>

  private static let _attributesCache = _AttributesCache()

  private func _createAttributes() -> [NSAttributedString.Key: Any] {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = textAlignment
    return [.paragraphStyle: paragraphStyle]
  }

  public static func resolve(
    _ properties: PropertyDictionary, _ fallback: PropertyMapping
  ) -> ParagraphProperty {
    func resolved(_ key: PropertyKey) -> PropertyValue {
      key.resolve(properties, fallback)
    }

    return ParagraphProperty(textAlignment: resolved(textAlignment).textAlignment()!)
  }

  // MARK: - Key

  public static let textAlignment = PropertyKey(.paragraph, .textAlignment)  // NSTextAlignment

  public static let allKeys: [PropertyKey] = [
    textAlignment
  ]
}
