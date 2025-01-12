// Copyright 2024-2025 Lie Yan

import Foundation

public typealias PropertyName = Property.Name
public typealias PropertyKey = Property.Key
public typealias PropertyValue = Property.Value
public typealias PropertyValueType = Property.ValueType
public typealias PropertyDictionary = Property.Dictionary
public typealias PropertyMapping = Property.Mapping
public typealias PropertyMatcher = Property.Matcher

typealias PropertyAggregate = Property.Aggregate
typealias PropertyTypeRegistry = Property.TypeRegistry

public enum Property {
    protocol Aggregate {
        func properties() -> PropertyDictionary
        func attributes() -> [NSAttributedString.Key: Any]

        static func resolve(_ properties: PropertyDictionary,
                            _ fallback: PropertyMapping) -> Self

        static var typeRegistry: TypeRegistry { get }
        static var allKeys: [PropertyKey] { get }
    }

    static let allAggregates: [any Aggregate.Type] = [
        RootProperty.self,
        TextProperty.self,
        MathProperty.self,
        ParagraphProperty.self,
    ]

    public typealias Dictionary = [Key: Value]
    typealias TypeRegistry = [Key: ValueType]
}

extension Property.Key {
    static let typeRegistry: Property.TypeRegistry = _typeRegistry()

    public static let allCases: [Property.Key] = Property.allAggregates.flatMap { $0.allKeys }

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
