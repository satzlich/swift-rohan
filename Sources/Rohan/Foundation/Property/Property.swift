// Copyright 2024-2025 Lie Yan

import Foundation

public typealias PropertyDictionary = [PropertyKey: PropertyValue]

/// Type registry records the type of each property key.
public typealias PropertyTypeRegistry = [PropertyKey: PropertyValueType]

public protocol PropertyAggregate {
  func getProperties() -> PropertyDictionary
  func getAttributes() -> [NSAttributedString.Key: Any]

  /**
   Resolve property aggregate from a dictionary of properties.
   - Parameters:
      - properties: the dictionary of properties.
      - fallback: the fallback property mapping.
   */
  static func resolve(_ properties: PropertyDictionary, _ fallback: PropertyMapping) -> Self

  static var typeRegistry: PropertyTypeRegistry { get }
  static var allKeys: [PropertyKey] { get }
}

public enum Property {
  static let allAggregates: [any PropertyAggregate.Type] = [
    TextProperty.self,
    MathProperty.self,
    ParagraphProperty.self,
  ]
}

extension PropertyKey {
  static let typeRegistry: PropertyTypeRegistry = _typeRegistry()

  public static let allCases: [PropertyKey] = Property.allAggregates.flatMap { $0.allKeys }

  private static func _typeRegistry() -> PropertyTypeRegistry {
    var registry: PropertyTypeRegistry = [:]
    for aggregate in Property.allAggregates {
      registry.merge(aggregate.typeRegistry) { _, _ in
        preconditionFailure("Duplicate key")
      }
    }
    return registry
  }
}
