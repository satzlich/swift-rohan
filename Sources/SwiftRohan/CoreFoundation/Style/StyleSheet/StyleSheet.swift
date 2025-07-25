import Foundation

internal typealias StyleRules = Dictionary<TargetSelector, PropertyDictionary>

public final class StyleSheet: Sendable {
  private let styleRules: StyleRules
  internal let defaultProperties: PropertyMapping

  internal init(_ styleRules: StyleRules, _ defaultProperties: PropertyMapping) {
    self.styleRules = styleRules
    self.defaultProperties = defaultProperties
  }

  /// Styles for the given selector
  internal func getProperties(for selector: TargetSelector) -> PropertyDictionary? {
    styleRules[selector]
  }
}

extension StyleSheet {
  internal func resolveDefault(_ key: PropertyKey) -> PropertyValue {
    key.resolveValue([:], self)
  }

  internal func resolveDefault<T: PropertyAggregate>() -> T {
    T.resolveAggregate([:], self)
  }
}
