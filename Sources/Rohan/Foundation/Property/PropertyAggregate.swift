// Copyright 2024-2025 Lie Yan

import Foundation

public typealias PropertyDictionary = [PropertyKey: PropertyValue]

public protocol PropertyAggregate: Sendable {
  func getProperties() -> PropertyDictionary
  func getAttributes() -> [NSAttributedString.Key: Any]

  /**
   Resolve property aggregate from a dictionary of properties.
   - Parameters:
      - properties: the dictionary of properties.
      - fallback: the fallback property mapping.
   */
  static func resolve(_ properties: PropertyDictionary, _ fallback: PropertyMapping) -> Self

  static var allKeys: [PropertyKey] { get }
}
