// Copyright 2024 Lie Yan

import Foundation

enum PropertyValueType: Equatable, Hashable, Codable {
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
