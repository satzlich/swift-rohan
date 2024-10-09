// Copyright 2024 Lie Yan

import Foundation

// MARK: - UniString

struct UniString: Equatable & Hashable {
    // MARK: - Associate types

    @usableFromInline
    typealias Backend = U16String

    @usableFromInline
    typealias Element = Character

    @usableFromInline
    struct Index: Equatable, Hashable, Comparable {
        @usableFromInline
        let _value: U16String.Index

        @usableFromInline
        init(_ value: U16String.Index) {
            self._value = value
        }

        @usableFromInline
        static func < (lhs: Index, rhs: Index) -> Bool {
            lhs._value < rhs._value
        }
    }

    // MARK: - Private

    @usableFromInline
    private(set) var _backend: Backend

    @usableFromInline
    init(_ s: SubSequence) {
        let l = s.startIndex._value
        let u = s.endIndex._value
        let unichars = s.base._backend

        self._backend = Backend(unichars[l ..< u])
    }

    // MARK: - Internal

    init(_ string: String) {
        self._backend = Backend(string.utf16)
    }

    // MARK: - Public

    public subscript(_ index: Index) -> Element {
        let i = index._value

        if UTF16.isLeadSurrogate(_backend[i]) {
            let ii = _backend.index(after: i)
            let combinedValue = UTF16.combineSurrogates(_backend[i], _backend[ii])
            return Character(UnicodeScalar(combinedValue)!)
        }
        else {
            assert(!UTF16.isTrailSurrogate(_backend[i]))
            return Character(UnicodeScalar(_backend[i])!)
        }
    }

    public var string: String {
        _backend.string
    }
}

// MARK: - UniString + Collection

extension UniString: Collection {
    public var startIndex: Index {
        Index(_backend.startIndex)
    }

    public var endIndex: Index {
        if _backend.isEmpty {
            startIndex
        }
        else {
            Index(_backend.endIndex)
        }
    }

    public func index(after i: Index) -> Index {
        let i = i._value

        if i < _backend.endIndex {
            let n = UTF16.isLeadSurrogate(_backend[i]) ? 2 : 1
            return Index(_backend.index(i, offsetBy: n))
        }
        else {
            return endIndex
        }
    }
}

// MARK: - UniString + RangeReplaceableCollection

extension UniString: RangeReplaceableCollection {
    init() {
        self._backend = Backend()
    }

    @inlinable
    public mutating func replaceSubrange<C>(_ subrange: Range<Index>, with newElements: C)
    where C: Collection, Element == C.Element {
        let u = subrange.lowerBound._value
        let l = subrange.upperBound._value

        _backend.replaceSubrange(u ..< l, with: newElements.flatMap { $0.utf16 })
    }
}
