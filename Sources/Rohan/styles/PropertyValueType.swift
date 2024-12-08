// Copyright 2024 Lie Yan

import Foundation

struct PropertyValueType: Equatable, Hashable {
    static let none = PropertyValueType(.none)
    static let auto = PropertyValueType(.auto)
    static let bool = PropertyValueType(.bool)
    static let integer = PropertyValueType(.integer)
    static let float = PropertyValueType(.float)
    static let string = PropertyValueType(.string)
    static let absLength = PropertyValueType(.absLength)
    static let color = PropertyValueType(.color)
    static let fontSize = PropertyValueType(.fontSize)
    static let fontStretch = PropertyValueType(.fontStretch)
    static let fontStyle = PropertyValueType(.fontStyle)
    static let fontWeight = PropertyValueType(.fontWeight)
    static let mathStyle = PropertyValueType(.mathStyle)
    static let mathVariant = PropertyValueType(.mathVariant)

    static func sum(_ elements: Set<PropertyValueType>) -> PropertyValueType {
        let s = Set(elements.map { $0.impl })
        let n = TypeImpl.sum(s).normalForm()
        return PropertyValueType(n)
    }

    var isEmpty: Bool {
        impl.isEmpty
    }

    var isSimple: Bool {
        impl.isSimple
    }

    /**

     - Complexity: O(n) where n is the size of `self`
     */
    func isSubset(of other: PropertyValueType) -> Bool {
        impl.isSubset_n(of: other.impl)
    }

    // MARK: - Private

    private let impl: TypeImpl

    private init(_ impl: TypeImpl) {
        self.impl = impl
    }

    /**
     Type of a property value.

     > Simplicity:
     Non-sum types are considered simple, while sum types are not.

     > Normal form:
     The normal form of a value is either a simple type or a (flat) sum type with zero or
     multiple elements, excluding singletons, where all elements are simple values.

     */
    private enum TypeImpl: Equatable, Hashable, Codable {
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

        case sum(Set<TypeImpl>)

        /**
         Returns true if `self` is empty.

         - Complexity: O(1)
         */
        var isEmpty: Bool {
            switch self {
            case let .sum(s):
                return s.isEmpty
            case _:
                return false
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
         Returns true if `self` is a subset of `other`.

         - Complexity: O(m + n)
         */
        func isSubset(of other: TypeImpl) -> Bool {
            let lhs = normalForm()
            let rhs = other.normalForm()

            return lhs.isSubset_n(of: rhs)
        }

        /**
         Faster version of `isSubset` that assumes `self` and `other` are in normal form.

         - Complexity: O(m) where m is the size of `self`
         */
        func isSubset_n(of other: TypeImpl) -> Bool {
            precondition(isNormal() && other.isNormal())

            switch self {
            case let .sum(s):
                switch other {
                case let .sum(t):
                    return s.isSubset(of: t)
                case _:
                    return s.isEmpty
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
         Returns true if `self` is in normal form.

         - Complexity: O(n)
         */
        func isNormal() -> Bool {
            switch self {
            case let .sum(s):
                return s.count == 0 ||
                    s.count > 1 && s.allSatisfy { $0.isSimple }
            case _:
                return true
            }
        }

        /**
         Returns the normal form.

         - Complexity: O(n)
         */
        func normalForm() -> TypeImpl {
            let s = Set(unnested())
            switch s.count {
            case 0: return .sum([])
            case 1: return s.first!
            case _: return .sum(s)
            }
        }

        /**
         Returns all simple values in `self` as a flat list.

         - Complexity: O(n)
         */
        private func unnested() -> [TypeImpl] {
            var acc: [TypeImpl] = []
            collect(&acc)
            return acc
        }

        /**
         Collects all simple values in `self` into `acc`.

         - Complexity: O(n)
         */
        private func collect(_ acc: inout [TypeImpl]) {
            switch self {
            case let .sum(s):
                s.forEach { $0.collect(&acc) }
            case _:
                acc.append(self)
            }
        }
    }
}
