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

    case sum(SumSet)

    static func sum(_ elements: Set<PropertyValueType>) -> PropertyValueType {
        .sum(SumSet(elements))
    }

    /**
     A set with normalization on initialization
     */
    struct SumSet: Equatable, Hashable, Codable, Sequence {
        typealias Element = PropertyValueType

        var elements: Set<Element>

        init(_ elements: Set<Element>) {
            precondition(elements.count > 1 && elements.allSatisfy { $0.isSimple })
            self.elements = elements
        }

        var isEmpty: Bool {
            elements.isEmpty
        }

        var count: Int {
            elements.count
        }

        var first: PropertyValueType? {
            elements.first
        }

        func contains(_ element: Element) -> Bool {
            elements.contains(element)
        }

        func isSubset(of other: SumSet) -> Bool {
            elements.isSubset(of: other.elements)
        }

        func makeIterator() -> Set<Element>.Iterator {
            elements.makeIterator()
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
