// Copyright 2024-2025 Lie Yan

import Algorithms
import Foundation

public typealias PropertyDictionary = [PropertyKey: PropertyValue]
public typealias StyleRules = [TargetSelector: PropertyDictionary]

public final class StyleSheet {
    private let styleRules: StyleRules
    public let defaultProperties: PropertyDictionary

    public init(_ styleRules: StyleRules, _ defaultProperties: PropertyDictionary) {
        precondition(defaultProperties.count == PropertyKey.allCases.count)
        self.styleRules = styleRules
        self.defaultProperties = defaultProperties
    }

    /** Styles for the given selector */
    public func getProperties(for selector: TargetSelector) -> PropertyDictionary? {
        styleRules[selector]
    }
}
