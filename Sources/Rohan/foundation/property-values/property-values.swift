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

 */

enum PropertyValue: Equatable, Hashable {
    case none
    case auto

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

    var type: PropertyValueType {
        switch self {
        case .none: return .none
        case .auto: return .auto
        case .bool: return .bool
        case .int: return .int
        case .float: return .float
        case .string: return .string
        case .fontSize: return .fontSize
        case .fontStyle: return .fontStyle
        case .fontWeight: return .fontWeight
        case .fontStretch: return .fontStretch
        case .mathStyle: return .mathStyle
        case .mathVariant: return .mathVariant
        }
    }
}

enum PropertyValueType: Equatable, Hashable {
    case none
    case auto

    case bool
    case int
    case float
    case string

    case fontSize
    case fontStyle
    case fontWeight
    case fontStretch

    case mathStyle
    case mathVariant

    case sum(Set<PropertyValueType>)

    func isSubset(of other: PropertyValueType) -> Bool {
        switch self {
        case let .sum(s):
            return s.allSatisfy { $0.isSubset(of: other) }
        case _:
            switch other {
            case let .sum(t):
                return t.contains(where: { self.isSubset(of: $0) })
            case _:
                return self == other
            }
        }
    }

    mutating func normalize() {
        self = normalized()
    }

    func normalized() -> PropertyValueType {
        let s = Set(unnested())
        switch s.count {
        case 0: return .none
        case 1: return s.first!
        case _: return .sum(s)
        }
    }

    /**
     Flatten nested property value types.
     */
    private func unnested() -> [PropertyValueType] {
        switch self {
        case let .sum(s):
            return s.flatMap { $0.unnested() }
        case _:
            return [self]
        }
    }
}
