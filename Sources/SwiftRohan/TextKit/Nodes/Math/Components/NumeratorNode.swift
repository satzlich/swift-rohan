// Copyright 2024-2025 Lie Yan

final class NumeratorNode: ContentNode {
  override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      // inherit properties
      var properties = super.getProperties(styleSheet)
      // set math style ← fraction style
      let key = MathProperty.style
      let value = key.resolveValue(properties, styleSheet).mathStyle()!
      properties[key] = .mathStyle(MathUtils.fractionStyle(for: value))
      // cache properties
      _cachedProperties = properties
    }
    return _cachedProperties!
  }

  final class func loadSelf(from json: JSONValue) -> _LoadResult<NumeratorNode> {
    loadSelfGeneric(from: json)
  }
}
