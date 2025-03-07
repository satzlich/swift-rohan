// Copyright 2024-2025 Lie Yan

import Foundation

public struct PropertyKey: Equatable, Hashable, Codable {
  let nodeType: NodeType
  let propertyName: PropertyName

  init(_ nodeType: NodeType, _ propertyName: PropertyName) {
    self.nodeType = nodeType
    self.propertyName = propertyName
  }
}

extension PropertyKey {
  public func resolve(
    _ properties: PropertyDictionary, _ fallback: PropertyMapping
  ) -> PropertyValue {
    return properties[self] ?? fallback[self]
  }
}
