// Copyright 2024-2025 Lie Yan

import Algorithms
import BitCollections

/**
 Maintains an array of booleans that indicates whether a newline should
 be inserted at a given index.
 */
@usableFromInline
struct NewlineArray {
    private var _isBlock: BitArray
    private var _insertNewline: BitArray
    private(set) var trueValueCount: Int

    @inline(__always)
    public var isEmpty: Bool { _insertNewline.isEmpty }

    @inline(__always)
    public var count: Int { _insertNewline.count }

    @inline(__always)
    public var asBitArray: BitArray { _insertNewline }

    public subscript(index: Int) -> Bool {
        @inline(__always) get { _insertNewline[index] }
    }

    init<S>(_ isBlock: S) where S: Sequence, S.Element == Bool {
        self._isBlock = BitArray(isBlock)
        self._insertNewline = BitArray(Self.newlines(for: _isBlock))
        self.trueValueCount = _insertNewline.lazy.map(\.intValue).reduce(0, +)
    }

    mutating func insert<C>(contentsOf isBlock: C, at index: Int)
    where C: Collection, C.Element == Bool {
        precondition(index >= 0 && index <= _insertNewline.count)

        let prev: Bool? = index == 0 ? nil : _isBlock[index - 1]
        let next: Bool? = index == _insertNewline.count ? nil : _isBlock[index]
        let (previous, segment) = Self.newlines(previous: prev,
                                                segment: isBlock,
                                                next: next)

        var delta = 0
        if previous != nil {
            delta += previous!.intValue - _insertNewline[index - 1].intValue
            _insertNewline[index - 1] = previous!
        }
        delta += segment.lazy.map(\.intValue).reduce(0, +)

        _isBlock.insert(contentsOf: isBlock, at: index)
        _insertNewline.insert(contentsOf: segment, at: index)
        trueValueCount += delta
    }

    mutating func insert(_ isBlock: Bool, at index: Int) {
        insert(contentsOf: CollectionOfOne(isBlock), at: index)
    }

    mutating func removeSubrange(_ range: Range<Int>) {
        precondition(range.lowerBound >= 0 && range.upperBound <= _insertNewline.count)

        guard !range.isEmpty else { return }

        // remove
        let delta = -_insertNewline[range].lazy.map(\.intValue).reduce(0, +)
        _isBlock.removeSubrange(range)
        _insertNewline.removeSubrange(range)
        trueValueCount += delta

        // update the previous
        guard range.lowerBound > 0 else { return }
        let i = range.lowerBound - 1
        let newValue: Bool = (i < _insertNewline.count - 1)
            ? (_isBlock[i] || _isBlock[i + 1])
            : false
        trueValueCount += newValue.intValue - _insertNewline[i].intValue
        _insertNewline[i] = newValue
    }

    mutating func remove(at index: Int) {
        removeSubrange(index ..< index + 1)
    }

    static func newlines<S>(
        previous: Bool?,
        segment isBlock: S,
        next: Bool?
    ) -> (previous: Bool?, segment: [Bool])
    where S: Sequence, S.Element == Bool {
        let isBlock = previous.asArray + isBlock + next.asArray
        var newlines = Self.newlines(for: isBlock)

        let previous = previous.map { _ in newlines[0] }

        if previous != nil {
            newlines.removeFirst()
        }
        if next != nil {
            newlines.removeLast()
        }

        return (previous, newlines)
    }

    /** Determine whether newlines are needed between adjacent children. */
    static func newlines<C>(for isBlock: C) -> [Bool]
    where C: Collection, C.Element == Bool {
        if isBlock.isEmpty { return [] }
        return isBlock.adjacentPairs().map { $0.0 || $0.1 } + CollectionOfOne(false)
    }
}
