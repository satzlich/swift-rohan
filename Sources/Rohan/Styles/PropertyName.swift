// Copyright 2024 Lie Yan

import Foundation

/**
 
 ## About Naming
 We use _property name_ instead of _attribute name_ to avoid conflicts
 with names common in Cocoa contexts.
 */
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
