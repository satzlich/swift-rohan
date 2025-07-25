import Foundation

internal struct PropertyKey: Equatable, Hashable, Codable, Sendable {
  let nodeType: NodeType
  let propertyName: PropertyName

  init(_ nodeType: NodeType, _ propertyName: PropertyName) {
    self.nodeType = nodeType
    self.propertyName = propertyName
  }

  internal func resolveValue(
    _ properties: PropertyDictionary, _ stylesheet: StyleSheet
  ) -> PropertyValue {
    properties[self] ?? stylesheet.defaultProperties[self]
  }
}
