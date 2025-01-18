// Copyright 2024-2025 Lie Yan

import Foundation

public typealias PropertyDictionary = [PropertyKey: PropertyValue]
public typealias PropertyTypeRegistry = [PropertyKey: PropertyValueType]

public protocol PropertyAggregate {
    func properties() -> PropertyDictionary
    func attributes() -> [NSAttributedString.Key: Any]

    static func resolve(_ properties: PropertyDictionary,
                        _ fallback: PropertyMapping) -> Self

    static var typeRegistry: PropertyTypeRegistry { get }
    static var allKeys: [PropertyKey] { get }
}

public enum Property {
    static let allAggregates: [any PropertyAggregate.Type] = [
        RootProperty.self,
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
