final class NumeratorNode: ContentNode {
  // MARK: - Node

  final override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      var current = super.getProperties(styleSheet)

      // set math style ← fraction style
      let key = MathProperty.style
      let value = key.resolveValue(current, styleSheet).mathStyle()!
      current[key] = .mathStyle(MathUtils.fractionStyle(for: value))

      _cachedProperties = current
    }
    return _cachedProperties!
  }
  
  // MARK: - Storage

  final class func loadSelf(from json: JSONValue) -> NodeLoaded<NumeratorNode> {
    loadSelfGeneric(from: json)
  }
}
