// Copyright 2024-2025 Lie Yan

import Foundation

public typealias PropertyName = Property.Name
public typealias PropertyKey = Property.Key
public typealias PropertyValue = Property.Value
public typealias PropertyValueType = Property.ValueType
public typealias PropertyMatcher = Property.Matcher
public typealias PropertyTypeRegistry = [PropertyKey: PropertyValueType]

typealias PropertyAggregate = Property.Aggregate

public enum Property {
    protocol Aggregate {
        func propertyDictionary() -> PropertyDictionary
        func attributeDictionary() -> [NSAttributedString.Key: Any]

        static var typeRegistry: PropertyTypeRegistry { get }
        static var allKeys: [PropertyKey] { get }
    }

    static let allAggregates: [any Aggregate.Type] = [
        RootProperty.self,
        TextProperty.self,
        MathProperty.self,
        ParagraphProperty.self,
    ]
}

extension PropertyKey {
    public static let typeRegistry: PropertyTypeRegistry = _typeRegistry()

    public static let allCases: [PropertyKey] = Property.allAggregates.flatMap { $0.allKeys }

    private static func _typeRegistry() -> PropertyTypeRegistry {
        Property.allAggregates.reduce(into: PropertyTypeRegistry()) { registry, aggregate in
            registry.merge(aggregate.typeRegistry) { (_, _) in preconditionFailure() }
        }
    }
}
