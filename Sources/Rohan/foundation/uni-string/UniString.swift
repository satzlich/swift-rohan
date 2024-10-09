// Copyright 2024 Lie Yan

import Foundation

// MARK: - UniString

@usableFromInline
struct UniString: Equatable & Hashable {
    @usableFromInline
    typealias _Backend = U16String

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

    @usableFromInline
    private(set) var _backend: _Backend

    @usableFromInline
    init(_ s: SubSequence) {
        let l = s.startIndex._value
        let u = s.endIndex._value
        let backend = s.base._backend

        self._backend = .init(backend[l ..< u])
    }

    @usableFromInline
    init(_ string: String) {
        self._backend = _Backend(string.utf16)
    }

    @inlinable
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

    @inlinable
    public var string: String {
        _backend.string
    }
}

// MARK: - UniString + Collection

extension UniString: Collection {
    @inlinable
    public var startIndex: Index {
        Index(_backend.startIndex)
    }

    @inlinable
    public var endIndex: Index {
        Index(_backend.endIndex)
    }

    @inlinable
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
    @usableFromInline
    init() {
        self._backend = .init()
    }

    @inlinable
    public mutating func replaceSubrange<C, R>(_ subrange: R, with newElements: C)
        where C: Collection, R: RangeExpression, C.Element == Element, R.Bound == Index
    {
        let range = subrange.relative(to: self)
        let u = range.lowerBound._value
        let l = range.upperBound._value

        _backend.replaceSubrange(u ..< l, with: newElements.flatMap { $0.utf16 })
    }
}
