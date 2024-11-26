// Copyright 2024 Lie Yan

import Foundation

enum Value: Equatable, Hashable, Codable {
    case none
    case auto

    // basic types

    case bool(Bool)
    case int(Int)
    case float(Double)
    case string(String)

    // general

    case absLength(AbsLength)

    // font

    case fontSize(FontSize)
    case fontStretch(FontStretch)
    case fontStyle(FontStyle)
    case fontWeight(FontWeight)

    // math

    case mathStyle(MathStyle)
    case mathVariant(MathVariant)

    var type: ValueType {
        switch self {
        case .none: return .none
        case .auto: return .auto
        // ---
        case .bool: return .bool
        case .int: return .int
        case .float: return .float
        case .string: return .string
        // ---
        case .absLength: return .absLength
        // ---
        case .fontSize: return .fontSize
        case .fontStretch: return .fontStretch
        case .fontStyle: return .fontStyle
        case .fontWeight: return .fontWeight
        // ---
        case .mathStyle: return .mathStyle
        case .mathVariant: return .mathVariant
        }
    }
}
