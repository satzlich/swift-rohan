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

    /**
     A set with normalization on initialization
     */
    struct SumSet: Equatable, Hashable, Codable, ExpressibleByArrayLiteral, Sequence {
        typealias Element = PropertyValueType

        var elements: Set<Element>

        init(_ elements: some Sequence<Element>) {
            let elements = Self.flatten(elements)
            precondition(!elements.isEmpty)
            self.elements = elements
        }

        init(arrayLiteral elements: Element...) {
            self.init(elements)
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

        private static func flatten(_ elements: some Sequence<Element>) -> Set<Element> {
            func flatten(
                _ elements: some Sequence<Element>,
                _ acc: inout Set<Element>
            ) {
                for element in elements {
                    switch element {
                    case let .sum(s):
                        flatten(s, &acc)
                    case let t:
                        acc.insert(t)
                    }
                }
            }

            var acc = Set<Element>()
            flatten(elements, &acc)
            return acc
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
                return s.count == 1 && s.first! == other
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
