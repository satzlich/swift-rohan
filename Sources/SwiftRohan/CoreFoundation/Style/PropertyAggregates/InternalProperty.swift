import Foundation

internal struct InternalProperty: PropertyAggregate {
  // MARK: - PropertyAggregate

  public static func resolveAggregate(
    _ properties: PropertyDictionary, _ styleSheet: StyleSheet
  ) -> InternalProperty {
    @inline(__always)
    func resolved(_ key: PropertyKey) -> PropertyValue {
      key.resolveValue(properties, styleSheet)
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
