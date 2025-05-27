// Copyright 2024-2025 Lie Yan

final class SuperscriptNode: ContentNode {
  override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      var properties = super.getProperties(styleSheet)
      let key = MathProperty.style
      let value = key.resolve(properties, styleSheet).mathStyle()!
      // style
      properties[key] = .mathStyle(MathUtils.scriptStyle(for: value))
      _cachedProperties = properties
    }
    return _cachedProperties!
  }

  final class func loadSelf(from json: JSONValue) -> _LoadResult<SuperscriptNode> {
    loadSelfGeneric(from: json)
  }
}
