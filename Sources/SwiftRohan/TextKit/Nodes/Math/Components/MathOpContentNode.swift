// Copyright 2024-2025 Lie Yan

final class MathOpContentNode: ContentNode {
  override func deepCopy() -> MathOpContentNode { MathOpContentNode(deepCopyOf: self) }

  override func cloneEmpty() -> Self { Self() }

  override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      var properties = super.getProperties(styleSheet)
      properties[MathProperty.variant] = .mathVariant(.serif)
      properties[MathProperty.italic] = .bool(false)
      properties[MathProperty.bold] = .bool(false)
      _cachedProperties = properties
    }
    return _cachedProperties!
  }
}
