// Copyright 2024-2025 Lie Yan

import Foundation

internal typealias PropertyDictionary = Dictionary<PropertyKey, PropertyValue>

internal protocol PropertyAggregate: Sendable {
  /// Resolve property aggregate from a dictionary of properties.
  /// - Parameters:
  ///   - properties: the dictionary of properties.
  ///   - styleSheet: the style sheet.
  static func resolveAggregate(
    _ properties: PropertyDictionary, _ styleSheet: StyleSheet
  ) -> Self

  static var allKeys: Array<PropertyKey> { get }
}
