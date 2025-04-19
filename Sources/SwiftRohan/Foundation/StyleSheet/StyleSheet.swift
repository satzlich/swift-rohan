// Copyright 2024-2025 Lie Yan

import Foundation

public typealias StyleRules = [TargetSelector: PropertyDictionary]

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
  public var textFont: String {
    TextProperty.font.resolve([:], defaultProperties).string()!
  }

  public var textSize: FontSize {
    TextProperty.size.resolve([:], defaultProperties).fontSize()!
  }
}
