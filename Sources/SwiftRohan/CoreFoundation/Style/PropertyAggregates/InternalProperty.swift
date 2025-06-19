// Copyright 2024-2025 Lie Yan

import Foundation

internal struct InternalProperty: PropertyAggregate {
  // MARK: - PropertyAggregate

  public static func resolveAggregate(
    _ properties: PropertyDictionary, _ fallback: PropertyMapping
  ) -> InternalProperty {
    func resolved(_ key: PropertyKey) -> PropertyValue {
      key.resolveValue(properties, fallback)
    }

    return InternalProperty(nestedLevel: resolved(nestedLevel).integer()!)
  }

  public static let allKeys: Array<PropertyKey> = [nestedLevel]

  // MARK: - Implementation

  public let nestedLevel: Int

  public init(nestedLevel: Int) {
    self.nestedLevel = nestedLevel
  }

  public static let nestedLevel = PropertyKey(.root, ._nestedLevel)

}
