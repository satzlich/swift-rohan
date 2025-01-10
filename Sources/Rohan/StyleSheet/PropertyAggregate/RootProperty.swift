// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

public struct RootProperty: PropertyAggregate {
    public let layoutMode: LayoutMode

    public func propertyDictionary() -> PropertyDictionary {
        [RootProperty.layoutMode: .layoutMode(layoutMode)]
    }

    public func attributeDictionary() -> [NSAttributedString.Key: Any] {
        [:]
    }

    // MARK: - Key

    public static let layoutMode = PropertyKey(.root, .layoutMode)

    public static let typeRegistry: PropertyTypeRegistry = [layoutMode: .layoutMode]

    public static let allKeys: [PropertyKey] = typeRegistry.keys.map { $0 }
}
