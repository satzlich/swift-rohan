// Copyright 2024 Lie Yan

import Foundation

/**
 String of unichar's.
 */
struct UniString: Equatable, Hashable {
    typealias Element = Character

    struct Index: Equatable, Hashable, Comparable {
        fileprivate let _value: Int

        init(_ value: Int) {
            self._value = value
        }

        static func < (lhs: Index, rhs: Index) -> Bool {
            lhs._value < rhs._value
        }
    }

    fileprivate private(set) var _unichars: [unichar]

    public var startIndex: Index {
        Index(0)
    }

    public var endIndex: Index? {
        if _unichars.isEmpty {
            nil
        }
        else {
            Index(_unichars.count)
        }
    }

    init(_ string: String) {
        self._unichars = string.utf16.map { $0 }
    }

    private init(_ unichars: [unichar]) {
        self._unichars = unichars
    }

    public subscript(_ index: Index) -> Element {
        let i = index._value

        if UTF16Utils.isHighSurrogate(_unichars[i]) {
            let combinedValue = UTF16Utils.combineSurrogates(_unichars[i],
                                                             _unichars[i + 1])
            return Character(UnicodeScalar(combinedValue)!)
        }
        else {
            return Character(UnicodeScalar(_unichars[i])!)
        }
    }

    public mutating func insert(_ position: Index, _ newContent: UniString) {
        _unichars.insert(contentsOf: newContent._unichars, at: position._value)
    }

    public mutating func delete(_ range: Range<Index>) {
        let l = range.lowerBound._value
        let u = range.upperBound._value
        _unichars.removeSubrange(l ..< u)
    }

    public func substring(_ range: Range<Index>) -> UniString {
        let l = range.lowerBound._value
        let u = range.upperBound._value

        return UniString(_unichars[l ..< u].map { $0 })
    }

    public func toSwiftString() -> String {
        String(utf16CodeUnits: _unichars, count: _unichars.count)
    }
}
