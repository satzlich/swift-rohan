// Copyright 2024-2025 Lie Yan

import Foundation

internal struct PropertyKey: Equatable, Hashable, Codable, Sendable {
  let nodeType: NodeType
  let propertyName: PropertyName

  init(_ nodeType: NodeType, _ propertyName: PropertyName) {
    self.nodeType = nodeType
    self.propertyName = propertyName
  }

  @inlinable @inline(__always)
  internal func resolveValue(
    _ properties: PropertyDictionary, _ fallback: PropertyMapping
  ) -> PropertyValue {
    properties[self] ?? fallback[self]
  }

  internal func resolveValue(
    _ properties: PropertyDictionary, _ stylesheet: StyleSheet
  ) -> PropertyValue {
    properties[self] ?? stylesheet.defaultProperties[self]
  }
}
