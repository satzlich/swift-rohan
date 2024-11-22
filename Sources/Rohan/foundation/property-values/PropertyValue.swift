// Copyright 2024 Lie Yan

import Foundation

/*

 (Math, bold): Bool
 (Math, italic): <Bool, None>
 (Math, variant): MathVariant
 (Math, cramped): Bool
 (Math, style): MathStyle

 (Text, size): FontSize
 (Text, weight): FontWeight
 (Text, style): FontStyle
 (Text, stretch): FontStretch

 (Paragraph, topMargin): AbsLength
 (Paragraph, bottomMargin): AbsLength
 (Paragraph, topPadding): AbsLength
 (Paragraph, bottomPadding): AbsLength

 */

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

    // font properties

    case fontSize(FontSize)
    case fontStyle(FontStyle)
    case fontWeight(FontWeight)
    case fontStretch(FontStretch)

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
        // ---
        case .fontSize: return .fontSize
        case .fontStyle: return .fontStyle
        case .fontWeight: return .fontWeight
        case .fontStretch: return .fontStretch
        // ---
        case .mathStyle: return .mathStyle
        case .mathVariant: return .mathVariant
        }
    }
}
