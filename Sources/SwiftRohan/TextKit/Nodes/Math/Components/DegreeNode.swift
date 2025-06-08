// Copyright 2024-2025 Lie Yan

/// Degree of Radical.
final class DegreeNode: ContentNode {

  final override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      var current = super.getProperties(styleSheet)
      current[MathProperty.style] = .mathStyle(.scriptScript)
      _cachedProperties = current
    }
    return _cachedProperties!
  }

  final class func loadSelf(from json: JSONValue) -> _LoadResult<DegreeNode> {
    loadSelfGeneric(from: json)
  }
}
