// Copyright 2024 Lie Yan

import Foundation

/**
 Type of a property value.

 > Simplicity:
 Non-sum types are considered simple, while sum types are not.

 > Validity:
 All values are valid, except for sum types that (directly or recursively)
 contain no simple types.

 > isFlattened:
     ```
     self.flattened() == self
     ```

 */
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

    /// Returns true if `self` is simple.
    func isSimple() -> Bool {
        switch self {
        case .sum: return false
        case _: return true
        }
    }

    /// Returns true if `self` is valid.
    func isValid() -> Bool {
        switch self {
        case let .sum(s):
            return s.contains(where: { $0.isValid() })
        case _:
            return true
        }
    }

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
     Returns true if `self` is flattened.
     */
    func isFlattened() -> Bool {
        switch self {
        case let .sum(s):
            return s.count > 1 && s.allSatisfy { $0.isSimple() }
        case _:
            return true
        }
    }

    /**
     Returns a flattened representation.
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
     Converts to a flattened list of simple values.
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
