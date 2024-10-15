// Copyright 2024 Lie Yan

import Foundation

enum Value: Equatable, Hashable {
    case none
    case auto

    case bool(Bool)
    case int(Int)
    case float(Double)
    case string(String)

    case fontSize(FontSize)
    case fontStyle(FontStyle)
    case fontWeight(FontWeight)
    case fontStretch(FontStretch)

    case mathStyle(MathStyle)
    case mathVariant(MathVariant)
}
