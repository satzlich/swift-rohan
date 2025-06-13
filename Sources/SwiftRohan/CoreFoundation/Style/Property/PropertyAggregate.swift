// Copyright 2024-2025 Lie Yan

import Foundation

public typealias PropertyDictionary = [PropertyKey: PropertyValue]

public protocol PropertyAggregate: Sendable {
  /// Resolve property aggregate from a dictionary of properties.
  /// - Parameters:
  ///   - properties: the dictionary of properties.
  ///   - fallback: the fallback property mapping.
  static func resolveAggregate(
    _ properties: PropertyDictionary, _ fallback: PropertyMapping
  ) -> Self

  static var allKeys: Array<PropertyKey> { get }
}
