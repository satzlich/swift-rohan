// Copyright 2024-2025 Lie Yan

import Foundation

extension Property {
    // MARK: - Name

    public enum Name: Equatable, Hashable, Codable {
        // font

        case fontFamily
        case fontSize
        case fontStretch
        case fontStyle
        case fontWeight

        // math

        case bold
        case italic
        case autoItalic
        case cramped
        case mathStyle
        case mathVariant

        /// equation
        case isBlock

        // heading

        case level

        // paragraph

        case topMargin
        case bottomMargin
        case topPadding
        case bottomPadding
    }
}
