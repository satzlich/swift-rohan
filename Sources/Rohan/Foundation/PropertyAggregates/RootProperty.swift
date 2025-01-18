// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

public struct RootProperty: PropertyAggregate {
    public let layoutMode: LayoutMode

    public func properties() -> PropertyDictionary {
        [RootProperty.layoutMode: .layoutMode(layoutMode)]
    }

    public func attributes() -> [NSAttributedString.Key: Any] {
        [:]
    }

    public static func resolve(_ properties: PropertyDictionary,
                               _ fallback: PropertyMapping) -> RootProperty
    {
        let layoutMode = RootProperty.layoutMode.resolve(properties, fallback)
        return RootProperty(layoutMode: layoutMode.layoutMode()!)
    }

    // MARK: - Key

    public static let layoutMode = PropertyKey(.root, .layoutMode)

    public static let typeRegistry: PropertyTypeRegistry = [layoutMode: .layoutMode]

    public static let allKeys: [PropertyKey] = typeRegistry.keys.map { $0 }
}
