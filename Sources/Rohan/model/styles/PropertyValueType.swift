// Copyright 2024 Lie Yan

import Foundation

enum PropertyValueType: Equatable, Hashable, Codable {
    case none
    case auto

    // ---
    case bool
    case integer
    case float
    case string

    // ---
    case absLength
    case color

    // ---
    case fontSize
    case fontStretch
    case fontStyle
    case fontWeight

    // ---
    case mathStyle
    case mathVariant

    // ---

    case sum(Sum)

    static func sum(_ elements: Set<PropertyValueType>) -> PropertyValueType {
        .sum(Sum(elements))
    }

    /**
     A set that enforces invariants.
     */
    struct Sum: Equatable, Hashable, Codable {
        typealias Element = PropertyValueType

        var elements: Set<Element>

        init(_ elements: Set<Element>) {
            precondition(elements.count > 1 && elements.allSatisfy { $0.isSimple })
            self.elements = elements
        }

        func isSubset(of other: Sum) -> Bool {
            elements.isSubset(of: other.elements)
        }

        func contains(_ element: Element) -> Bool {
            elements.contains(element)
        }
    }

    /**
     Returns true if `self` is simple.

     - Complexity: O(1)
     */
    var isSimple: Bool {
        switch self {
        case .sum: return false
        case _: return true
        }
    }

    /**
     - Complexity: O(m) where m is the size of `self`
     */
    func isSubset(of other: Self) -> Bool {
        switch self {
        case let .sum(s):
            switch other {
            case let .sum(t):
                return s.isSubset(of: t)
            case _:
                return false
            }
        case _:
            switch other {
            case let .sum(t):
                return t.contains(self)
            case _:
                return self == other
            }
        }
    }

    /**

     - Complexity: O(m) where m is the size of `other`
     */
    func isSuperset(of other: Self) -> Bool {
        other.isSubset(of: self)
    }
}
