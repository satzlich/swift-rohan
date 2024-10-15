// Copyright 2024 Lie Yan

import Foundation

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
