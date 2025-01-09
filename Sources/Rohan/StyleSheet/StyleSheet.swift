// Copyright 2024-2025 Lie Yan

import Algorithms
import Foundation

public typealias PropertyMap = [PropertyKey: PropertyValue]
public typealias StyleRules = [TargetSelector: PropertyMap]

public final class StyleSheet {
    private let styleRules: StyleRules
    public let defaultProperties: PropertyMap

    public init(_ styleRules: StyleRules, _ defaultProperties: PropertyMap) {
        precondition(defaultProperties.count == PropertyKey.allCases.count)
        self.styleRules = styleRules
        self.defaultProperties = defaultProperties
    }

    /** Styles for the given selector */
    public func getProperties(for selector: TargetSelector) -> PropertyMap? {
        styleRules[selector]
    }
}
