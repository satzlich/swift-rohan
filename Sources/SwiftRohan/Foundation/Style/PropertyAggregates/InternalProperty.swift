// Copyright 2024-2025 Lie Yan

import Foundation

public struct InternalProperty: PropertyAggregate {

  public let nestedLevel: Int

  public init(nestedLevel: Int) {
    self.nestedLevel = nestedLevel
  }

  public func getProperties() -> PropertyDictionary {
    [
      InternalProperty.nestedLevel: .integer(nestedLevel)
    ]
  }

  public func getAttributes() -> [NSAttributedString.Key: Any] {
    [:]
  }

  public static func resolve(
    _ properties: PropertyDictionary, _ fallback: PropertyMapping
  ) -> InternalProperty {
    func resolve(_ key: PropertyKey) -> PropertyValue {
      key.resolve(properties, fallback)
    }

    return InternalProperty(nestedLevel: resolve(nestedLevel).integer()!)
  }

  // MARK: - Key

  public static let nestedLevel = PropertyKey(.root, ._nestedLevel)

  public static let allKeys: [PropertyKey] = [
    nestedLevel
  ]
}
