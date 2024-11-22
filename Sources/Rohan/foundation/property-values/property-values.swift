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

enum PropertyValueType: Equatable, Hashable {
    case none
    case auto

    // ---
    case bool
    case int
    case float
    case string

    // ---

    case absLength

    // ---
    case fontSize
    case fontStyle
    case fontWeight
    case fontStretch

    // ---
    case mathStyle
    case mathVariant

    // ---

    case sum(Set<PropertyValueType>)

    /**
     Returns true if `self` is a subset of `other`.
     */
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

    /**
     True if not a sum.
     */
    func isSimple() -> Bool {
        switch self {
        case .sum: return false
        default: return true
        }
    }

    /**
     True if flattened, that is, `self.flattened() == self`.
     */
    func isFlattened() -> Bool {
        switch self {
        case let .sum(s):
            return s.count > 1 && s.allSatisfy { $0.isSimple() }
        default:
            return true
        }
    }

    /**
     Converts a flattened representation.
     */
    func flattened() -> PropertyValueType? {
        let s = Set(unnested())
        switch s.count {
        case 0: return nil
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
