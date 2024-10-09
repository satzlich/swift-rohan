// Copyright 2024 Lie Yan

import Foundation

// MARK: - PieceTable

@usableFromInline
struct PieceTable<Element>: Equatable, Hashable
    where Element: Equatable & Hashable
{
    @usableFromInline
    var _buffer: _Buffer

    @usableFromInline
    private(set) var _pieceList: _PieceList

    @usableFromInline
    static func == (lhs: Self, rhs: Self) -> Bool {
        if lhs.count != rhs.count {
            return false
        }

        // compare elementwise

        var i = lhs.startIndex
        var j = rhs.startIndex

        while i < lhs.endIndex, j < rhs.endIndex {
            if lhs[i] != rhs[j] {
                return false
            }

            i = lhs.index(after: i)
            j = rhs.index(after: j)
        }
        return true
    }

    @usableFromInline
    func hash(into hasher: inout Hasher) {
        for i in indices {
            hasher.combine(self[i])
        }
    }

    @inlinable
    public init<S: Sequence>(_ elements: S) where S.Element == Element {
        self._buffer = _Buffer(elements)

        if !_buffer.isEmpty {
            let piece = _Piece(_buffer.startIndex, endIndex: _buffer.endIndex)
            self._pieceList = .init([piece])
        }
        else {
            self._pieceList = .init()
        }
    }

    @inlinable
    public init() {
        self.init([])
    }

    @inlinable
    public init(_ s: SubSequence) {
        self._buffer = s.base._buffer
        self._pieceList = Self._extractSubrange(s.base._pieceList,
                                                s.startIndex,
                                                s.endIndex)
    }

    /**
     Extract the pieces corresponding to the range
     */
    @usableFromInline
    static func _extractSubrange(
        _ pieceList: _PieceList,
        _ startIndex: Index,
        _ endIndex: Index
    ) -> _PieceList {
        if startIndex._pieceIndex == endIndex._pieceIndex {
            if startIndex._bufferIndex == endIndex._bufferIndex {
                return .init()
            }
            else {
                let piece = _Piece(startIndex._bufferIndex, endIndex: endIndex._bufferIndex)
                return .init([piece])
            }
        }
        else {
            var result = _PieceList()

            // start
            do {
                let startPiece = pieceList[startIndex._pieceIndex]
                result.append(_Piece(startIndex._bufferIndex, endIndex: startPiece.endIndex))
            }

            // middle
            for i in (startIndex._pieceIndex + 1) ..< (endIndex._pieceIndex) {
                result.append(pieceList[i])
            }

            // end
            if endIndex._pieceIndex != pieceList.endIndex {
                let endPiece = pieceList[endIndex._pieceIndex]
                result.append(_Piece(endPiece.startIndex, endIndex: endIndex._bufferIndex))
            }

            return result
        }
    }

    // MARK: - _Buffer

    /**
     Simple wrapper of array, but append-only.
     */
    @usableFromInline
    final class _Buffer {
        @inlinable
        public func append<S>(contentsOf newElements: S) -> (startIndex: Index, endIndex: Index)
        where S: Sequence, S.Element == Element {
            let startIndex = _elements.endIndex
            _elements.append(contentsOf: newElements)
            let endIndex = _elements.endIndex

            return (startIndex, endIndex)
        }

        @inlinable
        public func append(_ element: Element) -> (startIndex: Index, endIndex: Index) {
            append(contentsOf: [element])
        }

        @inlinable
        public var isEmpty: Bool {
            _elements.isEmpty
        }

        @inlinable
        public var count: Int {
            _elements.count
        }

        @inlinable
        public subscript(index: Index) -> Element {
            _elements[index]
        }

        @inlinable
        public var startIndex: Index {
            _elements.startIndex
        }

        @inlinable
        public var endIndex: Index {
            _elements.endIndex
        }

        // MARK: - Internal

        @usableFromInline
        typealias Index = Int

        @usableFromInline
        init() {
            self._elements = .init()
        }

        @usableFromInline
        init<S>(_ elements: S)
            where S: Sequence, S.Element == Element
        {
            self._elements = .init(elements)
        }

        // MARK: - Private

        @usableFromInline
        var _elements: ContiguousArray<Element>
    }

    // MARK: - _Piece

    @usableFromInline
    struct _Piece {
        @usableFromInline
        var startIndex: _Buffer.Index

        /**
         End index of the text, exclusive
         */
        @usableFromInline
        var endIndex: _Buffer.Index

        @usableFromInline
        var length: Int {
            endIndex - startIndex
        }

        @usableFromInline
        var isEmpty: Bool {
            startIndex == endIndex
        }

        @usableFromInline
        init(_ startIndex: _Buffer.Index, length: Int) {
            precondition(startIndex >= 0 && length > 0)

            self.startIndex = startIndex
            self.endIndex = startIndex + length
        }

        @usableFromInline
        init(_ startIndex: _Buffer.Index, endIndex: _Buffer.Index) {
            precondition(startIndex >= 0 && endIndex > startIndex)

            self.startIndex = startIndex
            self.endIndex = endIndex
        }
    }

    @usableFromInline
    typealias _PieceList = ContiguousArray<_Piece>
}

// MARK: - PieceTable + Collection

extension PieceTable: Collection {
    public struct Index: Equatable, Hashable, Comparable {
        @usableFromInline
        let _pieceIndex: _PieceList.Index

        @usableFromInline
        let _bufferIndex: _Buffer.Index

        @inlinable
        public static func < (lhs: Index, rhs: Index) -> Bool {
            if lhs._pieceIndex == rhs._pieceIndex {
                return lhs._bufferIndex < rhs._bufferIndex
            }
            return lhs._pieceIndex < rhs._pieceIndex
        }

        @usableFromInline
        init(_ pieceIndex: _PieceList.Index, _ bufferIndex: _Buffer.Index) {
            self._pieceIndex = pieceIndex
            self._bufferIndex = bufferIndex
        }
    }

    @inlinable
    public var startIndex: Index {
        Index(0, _pieceList.first?.startIndex ?? 0)
    }

    @inlinable
    public var endIndex: Index {
        Index(_pieceList.count, 0)
    }

    @inlinable
    public var count: Int {
        _pieceList.reduce(0) { $0 + $1.length }
    }

    @inlinable
    public func index(after i: Index) -> Index {
        let piece = _pieceList[i._pieceIndex]

        // Check if the the next content is within the piece
        if i._bufferIndex + 1 < piece.endIndex {
            return Index(i._pieceIndex, i._bufferIndex + 1)
        }

        // Move to the next piece
        let pieceIndex = i._pieceIndex + 1

        if pieceIndex < _pieceList.endIndex {
            return Index(pieceIndex, _pieceList[pieceIndex].startIndex)
        }
        else {
            return Index(pieceIndex, 0)
        }
    }

    @inlinable
    public subscript(index: Index) -> Element {
        return _buffer[index._bufferIndex]
    }
}

// MARK: - PieceTable + RangeReplaceableCollection

extension PieceTable: RangeReplaceableCollection {
    @usableFromInline
    struct _ChangeDescription {
        @usableFromInline
        private(set) var values: [_Piece] = []

        /**
         The smallest index of the pieces added to `values`
         */
        @usableFromInline
        private(set) var lowerBound: Int?

        /**
         The greatest index of the pieces added to `values`, inclusive.
         */
        @usableFromInline
        private(set) var upperBound: Int?

        @usableFromInline
        init() {
        }

        /**

         - Parameters:
            - piece: added piece
            - pieceIndex: the piece index of the added one if it originates from
                an existing one; or nil otherwise
         */
        @usableFromInline
        mutating func appendPiece(_ piece: _Piece) {
            // Skip empty piece
            guard !piece.isEmpty else {
                return
            }

            // if `piece` continues from the last piece, extend the last.
            if let last = values.last,
               last.endIndex == piece.startIndex
            {
                values[values.count - 1].endIndex = piece.endIndex
            }
            else {
                values.append(piece)
            }
        }

        @usableFromInline
        mutating func extendBounds(_ pieceIndex: Int) {
            lowerBound = lowerBound.map { Swift.min($0, pieceIndex) } ?? pieceIndex
            upperBound = upperBound.map { Swift.max($0, pieceIndex) } ?? pieceIndex
        }
    }

    @usableFromInline
    func _safelyModifyPiece(
        _ description: inout _ChangeDescription,
        _ pieceIndex: _PieceList.Index,
        mutationBlock: (inout _Piece) -> Void
    ) {
        guard _pieceList.indices.contains(pieceIndex) else {
            return
        }

        // apply modifcation
        var piece = _pieceList[pieceIndex]
        mutationBlock(&piece)

        // update change description
        description.extendBounds(pieceIndex)
        description.appendPiece(piece)
    }

    /**
     Update the piece table with the described change
     */
    @usableFromInline
    mutating func _applyChange(_ changeDescription: _ChangeDescription) {
        let range: Range<Int>
        if let l = changeDescription.lowerBound, let u = changeDescription.upperBound {
            range = l ..< u + 1
        }
        else {
            range = _pieceList.endIndex ..< _pieceList.endIndex
        }
        _pieceList.replaceSubrange(range, with: changeDescription.values)
    }

    @inlinable
    public mutating func replaceSubrange<C, R>(_ subrange: R, with newElements: C)
        where C: Collection, R: RangeExpression, C.Element == Element, R.Bound == Index
    {
        let range = subrange.relative(to: self)

        // The (possibly) mutated pieces
        var changeDescription = _ChangeDescription()

        // The leading end
        _safelyModifyPiece(&changeDescription, range.lowerBound._pieceIndex - 1) { _ in
            // No modification

            // Adding the piece immediately before the lower bound allows
            // coalesce with that piece.
        }

        _safelyModifyPiece(&changeDescription, range.lowerBound._pieceIndex) { piece in
            piece.endIndex = range.lowerBound._bufferIndex
        }

        if !newElements.isEmpty {
            let (startIndex, endIndex) = _buffer.append(contentsOf: newElements)
            let newPiece = _Piece(startIndex, endIndex: endIndex)
            changeDescription.appendPiece(newPiece)
        }

        // The trailing end
        _safelyModifyPiece(&changeDescription, range.upperBound._pieceIndex) { piece in
            piece.startIndex = range.upperBound._bufferIndex
        }

        _applyChange(changeDescription)
    }
}
