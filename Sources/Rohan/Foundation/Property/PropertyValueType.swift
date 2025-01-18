// Copyright 2024-2025 Lie Yan

import Foundation

public enum PropertyValueType: Equatable, Hashable, Codable {
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
    case layoutMode

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

    public static func sum(_ elements: Set<PropertyValueType>) -> PropertyValueType {
        .sum(Sum(elements))
    }

    /** A set that enforces invariants. */
    public struct Sum: Equatable, Hashable, Codable {
        typealias Element = PropertyValueType

        let elements: Set<Element>

        init(_ elements: Set<Element>) {
            precondition(Self.validate(elements: elements))
            self.elements = elements
        }

        func isSubset(of other: Sum) -> Bool {
            elements.isSubset(of: other.elements)
        }

        func contains(_ element: Element) -> Bool {
            elements.contains(element)
        }

        static func validate(elements: Set<Element>) -> Bool {
            elements.count > 1 && elements.allSatisfy { $0.isSimple }
        }
    }

    /**
     Returns true if `self` is simple.

     - Complexity: O(1)
     */
    public var isSimple: Bool {
        switch self {
        case .sum: return false
        case _: return true
        }
    }

    /**
     - Complexity: O(m) where m is the size of `self`
     */
    public func isSubset(of other: Self) -> Bool {
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
}
