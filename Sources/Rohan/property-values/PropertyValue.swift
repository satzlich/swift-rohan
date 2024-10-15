// Copyright 2024 Lie Yan

import Foundation

/*

 (Math, bold): Bool
 (Math, italic): Bool
 (Math, variant): MathVariant
 (Math, style): MathStyle

 (Text, size): FontSize
 (Text, weight): FontWeight
 (Text, style): FontStyle
 (Text, stretch): FontStretch

 */

enum PropertyValue: Equatable, Hashable {
    // basic types

    case bool(Bool)
    case int(Int)
    case float(Double)
    case string(String)

    // font properties

    case fontSize(FontSize)
    case fontStyle(FontStyle)
    case fontWeight(FontWeight)
    case fontStretch(FontStretch)

    // math properties

    case mathStyle(MathStyle)
    case mathVariant(MathVariant)
}
