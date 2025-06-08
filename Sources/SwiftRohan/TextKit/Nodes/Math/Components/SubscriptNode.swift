// Copyright 2024-2025 Lie Yan

final class SubscriptNode: ContentNode {
  final override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      var current = super.getProperties(styleSheet)

      let key = MathProperty.style
      let value = key.resolveValue(current, styleSheet).mathStyle()!
      current[key] = .mathStyle(MathUtils.scriptStyle(for: value))

      current[MathProperty.cramped] = .bool(true)

      _cachedProperties = current
    }
    return _cachedProperties!
  }

  final class func loadSelf(from json: JSONValue) -> _LoadResult<SubscriptNode> {
    loadSelfGeneric(from: json)
  }
}
