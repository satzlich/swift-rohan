// Copyright 2024 Lie Yan

import Foundation

// MARK: - U16String

@usableFromInline
struct U16String: Equatable& Hashable {
    @usableFromInline
    typealias _Backend = PieceTable<UniChar>

    @usableFromInline
    typealias Element = UniChar

    @usableFromInline
    typealias Index = _Backend.Index

    @usableFromInline
    private(set) var _backend: _Backend

    @inlinable
    public subscript(index: Index) -> Element {
        _backend[index]
    }

    @inlinable
    public var string: String {
        String(utf16CodeUnits: _backend.map { $0 }, count: _backend.count)
    }
}

// MARK: - U16String + Collection

extension U16String: Collection {
    @inlinable
    public var startIndex: Index {
        _backend.startIndex
    }

    @inlinable
    public var endIndex: Index {
        _backend.endIndex
    }

    @inlinable
    func index(after i: Index) -> Index {
        _backend.index(after: i)
    }
}

// MARK: - U16String + RangeReplaceableCollection

extension U16String: RangeReplaceableCollection {
    @inlinable
    public init() {
        self._backend = .init()
    }

    @inlinable
    public mutating func replaceSubrange<C, R>(_ subrange: R, with newElements: C)
        where C: Collection, R: RangeExpression, C.Element == Element, R.Bound == Index
    {
        _backend.replaceSubrange(subrange, with: newElements)
    }
}
