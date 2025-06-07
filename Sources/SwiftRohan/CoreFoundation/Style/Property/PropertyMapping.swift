// Copyright 2024-2025 Lie Yan

import Foundation

/// A full dictionary from key to value
public struct PropertyMapping: ExpressibleByDictionaryLiteral, Sendable {
  public typealias Key = PropertyKey
  public typealias Value = PropertyValue

  private let dictionary: PropertyDictionary

  public init(dictionaryLiteral elements: (PropertyKey, PropertyValue)...) {
    self.dictionary = Dictionary(uniqueKeysWithValues: elements)
    assert(PropertyMapping.validate(dictionary))
  }

  public subscript(_ key: Key) -> Value { dictionary[key]! }

  private static func validate(_ dictionary: PropertyDictionary) -> Bool {
    dictionary.count == ALL_KEYS.count
  }
}

private let ALL_KEYS: [PropertyKey] =
  [
    TextProperty.allKeys,
    MathProperty.allKeys,
    ParagraphProperty.allKeys,
    PageProperty.allKeys,
    InternalProperty.allKeys,
  ].flatMap { $0 }
