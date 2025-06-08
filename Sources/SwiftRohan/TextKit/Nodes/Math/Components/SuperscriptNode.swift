// Copyright 2024-2025 Lie Yan

final class SuperscriptNode: ContentNode {
  final override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      var current = super.getProperties(styleSheet)

      let key = MathProperty.style
      let value = key.resolveValue(current, styleSheet).mathStyle()!
      current[key] = .mathStyle(MathUtils.scriptStyle(for: value))

      _cachedProperties = current
    }
    return _cachedProperties!
  }

  final class func loadSelf(from json: JSONValue) -> _LoadResult<SuperscriptNode> {
    loadSelfGeneric(from: json)
  }
}
