// Copyright 2024 Lie Yan

import Foundation

// MARK: - U16String

@usableFromInline
struct U16String: Equatable& Hashable {
    @usableFromInline
    typealias Storage = PieceTable<UniChar>

    @usableFromInline
    typealias Element = UniChar

    @usableFromInline
    typealias Index = Storage.Index

    @usableFromInline
    private(set) var _unichars: Storage

    public subscript(index: Index) -> Element {
        _unichars[index]
    }

    public var string: String {
        String(utf16CodeUnits: _unichars.map { $0 }, count: _unichars.count)
    }
}

// MARK: - U16String + Collection

extension U16String: Collection {
    @inlinable
    public var startIndex: Index {
        _unichars.startIndex
    }

    @inlinable
    public var endIndex: Index {
        _unichars.endIndex
    }

    @inlinable
    func index(after i: Index) -> Index {
        _unichars.index(after: i)
    }
}

// MARK: - U16String + RangeReplaceableCollection

extension U16String: RangeReplaceableCollection {
    @inlinable
    public init() {
        self._unichars = .init()
    }

    @inlinable
    public mutating func replaceSubrange<C>(_ subrange: Range<Index>, with newElements: C)
    where C: Collection, Element == C.Element {
        _unichars.replaceSubrange(subrange, with: newElements)
    }
}
