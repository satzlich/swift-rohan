// Copyright 2024-2025 Lie Yan

import Foundation

extension Property {
    /** A __full__ dictionary from key to value */
    public struct Mapping: ExpressibleByDictionaryLiteral {
        public typealias Key = Property.Key
        public typealias Value = Property.Value

        private let dictionary: Property.Dictionary

        public init(_ dictionary: Property.Dictionary) {
            precondition(Mapping.validate(dictionary))
            self.dictionary = dictionary
        }

        public init(dictionaryLiteral elements: (Property.Key, Property.Value)...) {
            self.dictionary = Dictionary(uniqueKeysWithValues: elements)
            precondition(Mapping.validate(dictionary))
        }

        public subscript(_ key: Key) -> Value {
            dictionary[key]!
        }

        public var asDictionary: Property.Dictionary { dictionary }

        static func validate(_ dictionary: Property.Dictionary) -> Bool {
            dictionary.count == Key.allCases.count
        }
    }
}
