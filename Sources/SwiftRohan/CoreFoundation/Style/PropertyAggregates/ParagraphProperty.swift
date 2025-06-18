// Copyright 2024-2025 Lie Yan

import AppKit

internal struct ParagraphProperty: PropertyAggregate, Equatable, Hashable, Sendable {
  // MARK: - PropertyAggregate

  public func getAttributes() -> Dictionary<NSAttributedString.Key, Any> {
    Self._attributesCache.getOrCreate(self, self._createAttributes)
  }

  public static func resolveAggregate(
    _ properties: PropertyDictionary, _ fallback: PropertyMapping
  ) -> ParagraphProperty {
    func resolved(_ key: PropertyKey) -> PropertyValue {
      key.resolveValue(properties, fallback)
    }

    return ParagraphProperty(
      textAlignment: resolved(textAlignment).textAlignment()!,
      paragraphSpacing: resolved(paragraphSpacing).float()!)
  }

  public static let allKeys: Array<PropertyKey> = [
    textAlignment,
    paragraphSpacing,
  ]

  // MARK: - Implementation

  public let textAlignment: NSTextAlignment
  public let paragraphSpacing: CGFloat

  private typealias _AttributesCache =
    ConcurrentCache<ParagraphProperty, Dictionary<NSAttributedString.Key, Any>>

  nonisolated(unsafe) private static let _attributesCache = _AttributesCache()

  private func _createAttributes() -> Dictionary<NSAttributedString.Key, Any> {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = textAlignment
    paragraphStyle.paragraphSpacing = paragraphSpacing
    paragraphStyle.hyphenationFactor = 0.9
    return [.paragraphStyle: paragraphStyle]
  }

  // MARK: - Key

  public static let textAlignment = PropertyKey(.paragraph, .textAlignment)  // NSTextAlignment
  public static let paragraphSpacing = PropertyKey(.paragraph, .paragraphSpacing)  // CGFloat
}
