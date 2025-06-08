// Copyright 2024-2025 Lie Yan

final class DenominatorNode: ContentNode {
  // MARK: - Node

  final override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      var current = super.getProperties(styleSheet)

      // set math style ← fraction style
      let key = MathProperty.style
      let value = key.resolveValue(current, styleSheet).mathStyle()!
      current[key] = .mathStyle(MathUtils.fractionStyle(for: value))

      // set cramped ← true
      current[MathProperty.cramped] = .bool(true)

      _cachedProperties = current
    }
    return _cachedProperties!
  }
  
  // MARK: - DenominatorNode

  final class func loadSelf(from json: JSONValue) -> _LoadResult<DenominatorNode> {
    loadSelfGeneric(from: json)
  }
}
