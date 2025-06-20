// Copyright 2024-2025 Lie Yan

import AppKit

internal struct ParagraphProperty: PropertyAggregate, Equatable, Hashable, Sendable {
  // MARK: - PropertyAggregate

  public func getAttributes() -> Dictionary<NSAttributedString.Key, Any> {
    let paragraphStyle = self.getParagraphStyle()
    return [.paragraphStyle: paragraphStyle]
  }

  internal func getParagraphStyle() -> NSParagraphStyle {
    Self._cache.getOrCreate(self, self._createParagraphStyle)
  }

  public static func resolveAggregate(
    _ properties: PropertyDictionary, _ fallback: PropertyMapping
  ) -> ParagraphProperty {
    func resolved(_ key: PropertyKey) -> PropertyValue {
      key.resolveValue(properties, fallback)
    }

    return ParagraphProperty(
      listLevel: resolved(listLevel).integer()!,
      paragraphSpacing: resolved(paragraphSpacing).float()!,
      textAlignment: resolved(textAlignment).textAlignment()!)
  }

  public static let allKeys: Array<PropertyKey> = [
    listLevel,
    paragraphSpacing,
    textAlignment,
  ]

  // MARK: - Implementation

  internal let listLevel: Int  // "0" indicates not in an item list.
  internal let paragraphSpacing: CGFloat
  internal let textAlignment: NSTextAlignment

  private typealias _Cache = ConcurrentCache<ParagraphProperty, NSMutableParagraphStyle>

  nonisolated(unsafe) private static let _cache = _Cache()

  private func _createParagraphStyle() -> NSMutableParagraphStyle {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = textAlignment
    paragraphStyle.paragraphSpacing = paragraphSpacing
    paragraphStyle.hyphenationFactor = 0.9
    return paragraphStyle
  }

  // MARK: - Key

  static let listLevel = PropertyKey(.itemList, .level)  // Int
  static let paragraphSpacing = PropertyKey(.paragraph, .paragraphSpacing)  // CGFloat
  static let textAlignment = PropertyKey(.paragraph, .textAlignment)  // NSTextAlignment
}
