import AppKit

internal struct ParagraphProperty: PropertyAggregate, Equatable, Hashable, Sendable {
  // MARK: - PropertyAggregate

  public func getAttributes() -> Dictionary<NSAttributedString.Key, Any> {
    let paragraphStyle = self.getParagraphStyle()

    var results: Dictionary<NSAttributedString.Key, Any> = [
      .paragraphStyle: paragraphStyle,
      .rhFirstLineHeadIndent: firstLineHeadIndent,
      .rhHeadIndent: headIndent,
      .rhListLevel: listLevel,
      .rhTextAlignment: textAlignment,
    ]

    if let verticalRibbon = verticalRibbon {
      results[.rhVerticalRibbon] = verticalRibbon.nsColor
    }

    return results
  }

  internal func getParagraphStyle() -> NSParagraphStyle {
    Self._cache.getOrCreate(self, self._createParagraphStyle)
  }

  static func resolveAggregate(
    _ properties: PropertyDictionary, _ styleSheet: StyleSheet
  ) -> ParagraphProperty {
    @inline(__always)
    func resolved(_ key: PropertyKey) -> PropertyValue {
      key.resolveValue(properties, styleSheet)
    }

    return ParagraphProperty(
      firstLineHeadIndent: resolved(firstLineHeadIndent).float()!,
      headIndent: resolved(headIndent).float()!,
      listLevel: resolved(listLevel).integer()!,
      paragraphSpacing: resolved(paragraphSpacing).float()!,
      textAlignment: resolved(textAlignment).textAlignment()!,
      verticalRibbon: resolved(verticalRibbon).color())
  }

  public static let allKeys: Array<PropertyKey> = [
    firstLineHeadIndent,
    headIndent,
    listLevel,
    paragraphSpacing,
    textAlignment,
    verticalRibbon,
  ]

  // MARK: - Implementation

  internal let firstLineHeadIndent: CGFloat
  internal let headIndent: CGFloat
  internal let listLevel: Int  // "0" indicates not in an item list.
  internal let paragraphSpacing: CGFloat
  internal let textAlignment: NSTextAlignment
  internal let verticalRibbon: Color?

  private typealias _Cache = ConcurrentCache<ParagraphProperty, NSMutableParagraphStyle>

  nonisolated(unsafe) private static let _cache = _Cache()

  private func _createParagraphStyle() -> NSMutableParagraphStyle {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = textAlignment
    paragraphStyle.firstLineHeadIndent = firstLineHeadIndent
    paragraphStyle.headIndent = headIndent
    paragraphStyle.paragraphSpacing = paragraphSpacing
    paragraphStyle.hyphenationFactor = 0.9
    return paragraphStyle
  }

  // MARK: - Key

  static let firstLineHeadIndent = PropertyKey(.paragraph, .firstLineHeadIndent)  // CGFloat
  static let headIndent = PropertyKey(.paragraph, .headIndent)  // CGFloat
  static let listLevel = PropertyKey(.itemList, .level)  // Int
  static let paragraphSpacing = PropertyKey(.paragraph, .paragraphSpacing)  // CGFloat
  static let textAlignment = PropertyKey(.paragraph, .textAlignment)  // NSTextAlignment
  static let verticalRibbon = PropertyKey(.paragraph, .verticalRibbon)  // Optional<Color>
}
