// Copyright 2024-2025 Lie Yan

import Foundation

public typealias StyleRules = Dictionary<TargetSelector, PropertyDictionary>

public final class StyleSheet: Sendable {
  private let styleRules: StyleRules
  public let defaultProperties: PropertyMapping

  public init(_ styleRules: StyleRules, _ defaultProperties: PropertyMapping) {
    self.styleRules = styleRules
    self.defaultProperties = defaultProperties
  }

  /// Styles for the given selector
  public func getProperties(for selector: TargetSelector) -> PropertyDictionary? {
    styleRules[selector]
  }
}

extension StyleSheet {
  public func resolveDefault(_ key: PropertyKey) -> PropertyValue {
    key.resolveValue([:], defaultProperties)
  }

  public func resolveDefault<T: PropertyAggregate>() -> T {
    T.resolveAggregate([:], defaultProperties)
  }
}
