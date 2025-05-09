// Copyright 2024-2025 Lie Yan

/// A content node that is cramped.
final class CrampedNode: ContentNode {
  override func deepCopy() -> CrampedNode { CrampedNode(deepCopyOf: self) }

  override func cloneEmpty() -> Self { Self() }

  override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      var properties = super.getProperties(styleSheet)
      properties[MathProperty.cramped] = .bool(true)
      _cachedProperties = properties
    }
    return _cachedProperties!
  }
}
