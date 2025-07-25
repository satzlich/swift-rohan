/// A content node that is cramped.
final class CrampedNode: ContentNode {
  // MARK: - Node

  final override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      var current = super.getProperties(styleSheet)
      current[MathProperty.cramped] = .bool(true)
      _cachedProperties = current
    }
    return _cachedProperties!
  }

  // MARK: - Storage

  final class func loadSelf(from json: JSONValue) -> NodeLoaded<CrampedNode> {
    loadSelfGeneric(from: json)
  }
}
