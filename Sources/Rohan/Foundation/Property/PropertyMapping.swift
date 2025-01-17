// Copyright 2024-2025 Lie Yan

import Foundation

/** A __full__ dictionary from key to value */
public struct PropertyMapping: ExpressibleByDictionaryLiteral {
    public typealias Key = PropertyKey
    public typealias Value = PropertyValue

    private let dictionary: PropertyDictionary

    public init(_ dictionary: PropertyDictionary) {
        precondition(PropertyMapping.validate(dictionary))
        self.dictionary = dictionary
    }

    public init(dictionaryLiteral elements: (PropertyKey, PropertyValue)...) {
        self.dictionary = Dictionary(uniqueKeysWithValues: elements)
        precondition(PropertyMapping.validate(dictionary))
    }

    public subscript(_ key: Key) -> Value {
        dictionary[key]!
    }

    public var asDictionary: PropertyDictionary { dictionary }

    static func validate(_ dictionary: PropertyDictionary) -> Bool {
        dictionary.count == Key.allCases.count
    }
}
