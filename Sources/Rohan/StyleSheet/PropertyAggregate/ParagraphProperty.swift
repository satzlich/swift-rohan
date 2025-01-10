// Copyright 2024-2025 Lie Yan

import AppKit

public struct ParagraphProperty: PropertyAggregate {
    public let topMargin: AbsLength
    public let bottomMargin: AbsLength
    public let topPadding: AbsLength
    public let bottomPadding: AbsLength

    public func propertyDictionary() -> PropertyDictionary {
        [
            ParagraphProperty.topMargin: .absLength(topMargin),
            ParagraphProperty.bottomMargin: .absLength(bottomMargin),
            ParagraphProperty.topPadding: .absLength(topPadding),
            ParagraphProperty.bottomPadding: .absLength(bottomPadding),
        ]
    }
    
    func attributeDictionary() -> [NSAttributedString.Key : Any] {
        [:]
    }

    // MARK: - Key

    public static let topMargin = PropertyKey(.paragraph, .topMargin) // AbsLength
    public static let bottomMargin = PropertyKey(.paragraph, .bottomMargin) // AbsLength
    public static let topPadding = PropertyKey(.paragraph, .topPadding) // AbsLength
    public static let bottomPadding = PropertyKey(.paragraph, .bottomPadding) // AbsLength

    public static let typeRegistry: PropertyTypeRegistry = [
        topMargin: .absLength,
        bottomMargin: .absLength,
        topPadding: .absLength,
        bottomPadding: .absLength,
    ]

    public static let allKeys: [PropertyKey] = typeRegistry.keys.map { $0 }
}
