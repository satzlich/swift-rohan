// Copyright 2024-2025 Lie Yan

final class SubscriptNode: ContentNode {
  override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      var properties = super.getProperties(styleSheet)
      let key = MathProperty.style
      let value = key.resolveValue(properties, styleSheet).mathStyle()!
      // style, cramped
      properties[key] = .mathStyle(MathUtils.scriptStyle(for: value))
      properties[MathProperty.cramped] = .bool(true)
      _cachedProperties = properties
    }
    return _cachedProperties!
  }

  final class func loadSelf(from json: JSONValue) -> _LoadResult<SubscriptNode> {
    loadSelfGeneric(from: json)
  }
}
