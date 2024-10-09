// Copyright 2024 Lie Yan

import Foundation

// MARK: - UniString

/**
 String of unichar's.
 */
struct UniString: Equatable & Hashable {
    // MARK: - Associate types

    typealias Element = Character

    fileprivate typealias Storage = PieceTable<unichar>

    struct Index: Equatable, Hashable, Comparable {
        fileprivate let _value: Storage.Index

        fileprivate init(_ value: Storage.Index) {
            self._value = value
        }

        static func < (lhs: Index, rhs: Index) -> Bool {
            lhs._value < rhs._value
        }
    }

    // MARK: - Private

    fileprivate private(set) var _unichars: Storage

    init(_ s: SubSequence) {
        let l = s.startIndex._value
        let u = s.endIndex._value
        let unichars = s.base._unichars

        self._unichars = Storage(unichars[l ..< u])
    }

    // MARK: - Internal

    init(_ string: String) {
        self._unichars = Storage(string.utf16)
    }

    // MARK: - Public

    public subscript(_ index: Index) -> Element {
        let i = index._value

        if UTF16.isLeadSurrogate(_unichars[i]) {
            let ii = _unichars.index(after: i)
            let combinedValue = UTF16.combineSurrogates(_unichars[i], _unichars[ii])
            return Character(UnicodeScalar(combinedValue)!)
        }
        else {
            assert(!UTF16.isTrailSurrogate(_unichars[i]))
            return Character(UnicodeScalar(_unichars[i])!)
        }
    }

    public func toString() -> String {
        String(utf16CodeUnits: _unichars.map { $0 }, count: _unichars.count)
    }
}

// MARK: - UniString + Collection

extension UniString: Collection {
    public var startIndex: Index {
        Index(_unichars.startIndex)
    }

    public var endIndex: Index {
        if _unichars.isEmpty {
            startIndex
        }
        else {
            Index(_unichars.endIndex)
        }
    }

    public func index(after i: Index) -> Index {
        let i = i._value

        if i < _unichars.endIndex {
            let n = UTF16.isLeadSurrogate(_unichars[i]) ? 2 : 1
            return Index(_unichars.index(i, offsetBy: n))
        }
        else {
            return endIndex
        }
    }
}

// MARK: - UniString + RangeReplaceableCollection

extension UniString: RangeReplaceableCollection {
    public init() {
        self.init("")
    }

    public mutating func replaceSubrange<C>(_ subrange: Range<Index>, with newElements: C)
    where C: Collection, Character == C.Element {
        let range = subrange.relative(to: self)

        let l = range.lowerBound._value
        let u = range.upperBound._value

        _unichars.replaceSubrange(l ..< u,
                                  with: newElements.flatMap { $0.utf16 })
    }
}
