// Copyright 2024-2025 Lie Yan

import Foundation

extension Property {
    // MARK: - Value

    public enum Value: Equatable, Hashable, Codable {
        case none
        case auto

        // basic types

        case bool(Bool)
        case integer(Int)
        case float(Double)
        case string(String)

        // general

        case absLength(AbsLength)
        case color(Color)

        // font

        case fontSize(FontSize)
        case fontStretch(FontStretch)
        case fontStyle(FontStyle)
        case fontWeight(FontWeight)

        // math

        case mathStyle(MathStyle)
        case mathVariant(MathVariant)

        public var type: ValueType {
            switch self {
            case .none: return .none
            case .auto: return .auto
            // ---
            case .bool: return .bool
            case .integer: return .integer
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

        public func fontStyle() -> FontStyle? {
            switch self {
            case let .fontStyle(fontStyle): return fontStyle
            default: return nil
            }
        }
    }
}
