// Copyright 2024 Lie Yan

import Foundation

enum PropertyValue: Equatable, Hashable, Codable {
    case none
    case auto

    // basic types

    case bool(Bool)
    case int(Int)
    case float(Double)
    case string(String)

    // general properties

    case absLength(AbsLength)
    case color(Color)

    // font properties

    case fontSize(FontSize)
    case fontStretch(FontStretch)
    case fontStyle(FontStyle)
    case fontWeight(FontWeight)

    // math properties

    case mathStyle(MathStyle)
    case mathVariant(MathVariant)

    var type: PropertyValueType {
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
        case .color: return .color
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
