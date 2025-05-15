// Copyright 2024-2025 Lie Yan

/// Degree of Radical.
final class DegreeNode: ContentNode {
  override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      var properties = super.getProperties(styleSheet)
      properties[MathProperty.style] = .mathStyle(.scriptScript)
      _cachedProperties = properties
    }
    return _cachedProperties!
  }
  
  
  final class func loadSelf(from json: JSONValue) -> _LoadResult<DegreeNode> {
    loadSelfGeneric(from: json)
  }
}
