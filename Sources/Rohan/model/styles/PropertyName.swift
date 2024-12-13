// Copyright 2024 Lie Yan

import Foundation

enum PropertyName: Equatable, Hashable, Codable {
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

    // heading

    case level

    // paragraph

    case topMargin
    case bottomMargin
    case topPadding
    case bottomPadding
}
