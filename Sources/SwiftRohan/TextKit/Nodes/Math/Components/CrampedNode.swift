// Copyright 2024-2025 Lie Yan

/// A content node that is cramped.
final class CrampedNode: ContentNode {

  final override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      var current = super.getProperties(styleSheet)
      current[MathProperty.cramped] = .bool(true)
      _cachedProperties = current
    }
    return _cachedProperties!
  }

  final class func loadSelf(from json: JSONValue) -> _LoadResult<CrampedNode> {
    loadSelfGeneric(from: json)
  }
}
