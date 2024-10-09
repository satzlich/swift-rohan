// Copyright 2024 Lie Yan

import Foundation

// MARK: - PieceTable

struct PieceTable<Element>: Equatable, Hashable
    where Element: Equatable & Hashable
{
    // MARK: - Private

    private var _contents: Storage

    fileprivate struct Piece {
        var startIndex: Storage.Index

        /**
         End index of the text, exclusive
         */
        var endIndex: Storage.Index

        var length: Int {
            endIndex - startIndex
        }

        var isEmpty: Bool {
            startIndex == endIndex
        }

        init(_ startIndex: Storage.Index,
             length: Int)
        {
            self.init(startIndex, endIndex: startIndex + length)
        }

        init(_ startIndex: Storage.Index,
             endIndex: Storage.Index)
        {
            precondition(startIndex >= 0)
            precondition(endIndex > startIndex)

            self.startIndex = startIndex
            self.endIndex = endIndex
        }
    }

    fileprivate typealias PieceList = ContiguousArray<Piece>

    private var pieceList: PieceList

    // MARK: - Internal

    static func == (lhs: PieceTable<Element>, rhs: PieceTable<Element>) -> Bool {
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

    func hash(into hasher: inout Hasher) {
        for i in indices {
            hasher.combine(self[i])
        }
    }

    // MARK: - Public

    public init<S: Sequence>(_ elements: S)
        where S.Element == Element
    {
        self._contents = Storage(elements)

        if !_contents.isEmpty {
            let piece = Piece(_contents.startIndex, endIndex: _contents.endIndex)
            self.pieceList = [piece]
        }
        else {
            self.pieceList = []
        }
    }

    public init() {
        self.init([])
    }

    public init(_ s: SubSequence) {
        self._contents = s.base._contents
        self.pieceList = PieceTable.extractSubrange(s.base.pieceList,
                                                    s.startIndex,
                                                    s.endIndex)
    }

    /**
     Extract the pieces corresponding to the range
     */
    fileprivate static func extractSubrange(
        _ pieceList: PieceList,
        _ startIndex: Index,
        _ endIndex: Index
    ) -> PieceList {
        if startIndex.pieceIndex == endIndex.pieceIndex {
            if startIndex.contentIndex == endIndex.contentIndex {
                return .init()
            }
            else {
                let piece = Piece(startIndex.contentIndex, endIndex: endIndex.contentIndex)
                return .init([piece])
            }
        }
        else {
            var result = ContiguousArray<Piece>()

            // start
            do {
                let startPiece = pieceList[startIndex.pieceIndex]
                result.append(Piece(startIndex.contentIndex, endIndex: startPiece.endIndex))
            }

            // middle
            for i in (startIndex.pieceIndex + 1) ..< (endIndex.pieceIndex) {
                result.append(pieceList[i])
            }

            // end
            if endIndex.pieceIndex != pieceList.endIndex {
                let endPiece = pieceList[endIndex.pieceIndex]
                result.append(Piece(endPiece.startIndex, endIndex: endIndex.contentIndex))
            }

            return result
        }
    }
}

// MARK: - PieceTable + Collection

extension PieceTable: Collection {
    public struct Index: Equatable, Hashable, Comparable {
        /**
         piece index
         */
        fileprivate let pieceIndex: PieceList.Index
        /**
         content index
         */
        fileprivate let contentIndex: Storage.Index

        public static func < (lhs: Index, rhs: Index) -> Bool {
            (lhs.pieceIndex, lhs.contentIndex) < (rhs.pieceIndex, rhs.contentIndex)
        }

        init(_ pieceIndex: Int, contentIndex: Int) {
            self.pieceIndex = pieceIndex
            self.contentIndex = contentIndex
        }
    }

    public var startIndex: Index {
        Index(0, contentIndex: pieceList.first?.startIndex ?? 0)
    }

    public var endIndex: Index {
        Index(pieceList.count, contentIndex: 0)
    }

    public var count: Int {
        pieceList.reduce(0) { $0 + $1.length }
    }

    public func index(after i: Index) -> Index {
        let piece = pieceList[i.pieceIndex]

        // Check if the the next content is within the piece
        if i.contentIndex + 1 < piece.endIndex {
            return Index(i.pieceIndex, contentIndex: i.contentIndex + 1)
        }

        // Move to the next piece
        let nextPieceIndex = i.pieceIndex + 1

        if nextPieceIndex < pieceList.endIndex {
            return Index(nextPieceIndex, contentIndex: pieceList[nextPieceIndex].startIndex)
        }
        else {
            return Index(nextPieceIndex, contentIndex: 0)
        }
    }

    public subscript(position: Index) -> Element {
        return _contents[position.contentIndex]
    }
}

// MARK: - PieceTable + RangeReplaceableCollection

extension PieceTable: RangeReplaceableCollection {
    // MARK: - Private

    private struct ChangeDescription {
        private(set) var values: [Piece] = []

        /**
         The smallest index of the pieces added to `values`
         */
        private(set) var lowerBound: Int?

        /**
         The greatest index of the pieces added to `values`, inclusive.
         */
        private(set) var upperBound: Int?

        /**

         - Parameters:
            - piece: added piece
            - pieceIndex: the piece index of the added one if it originates from
                an existing one; or nil otherwise
         */
        mutating func appendPiece(_ piece: Piece) {
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

        mutating func extendBounds(_ pieceIndex: Int) {
            lowerBound = lowerBound.map { Swift.min($0, pieceIndex) } ?? pieceIndex
            upperBound = upperBound.map { Swift.max($0, pieceIndex) } ?? pieceIndex
        }
    }

    private func safelyModifyPiece(
        _ description: inout ChangeDescription,
        _ pieceIndex: Int,
        mutationBlock: (inout Piece) -> Void
    ) {
        guard pieceList.indices.contains(pieceIndex) else {
            return
        }

        // apply modifcation
        var piece = pieceList[pieceIndex]
        mutationBlock(&piece)

        // update change description
        description.extendBounds(pieceIndex)
        description.appendPiece(piece)
    }

    /**
     Update the piece table with the described change
     */
    private mutating func applyChange(_ changeDescription: ChangeDescription) {
        let range: Range<Int>
        if let l = changeDescription.lowerBound, let u = changeDescription.upperBound {
            range = l ..< u + 1
        }
        else {
            range = pieceList.endIndex ..< pieceList.endIndex
        }
        pieceList.replaceSubrange(range, with: changeDescription.values)
    }

    // MARK: - Public

    public mutating func replaceSubrange<C, R>(_ subrange: R, with newElements: C)
        where C: Collection, R: RangeExpression,
        C.Element == Element, R.Bound == Index
    {
        let range = subrange.relative(to: self)

        // The (possibly) mutated pieces
        var changeDescription = ChangeDescription()

        // The leading end
        safelyModifyPiece(&changeDescription, range.lowerBound.pieceIndex - 1) { _ in
            // No modification

            // Adding the piece immediately before the lower bound allows
            // coalesce with that piece.
        }

        safelyModifyPiece(&changeDescription, range.lowerBound.pieceIndex) { piece in
            piece.endIndex = range.lowerBound.contentIndex
        }

        if !newElements.isEmpty {
            let (startIndex, endIndex) = _contents.append(contentsOf: newElements)
            let newPiece = Piece(startIndex, endIndex: endIndex)
            changeDescription.appendPiece(newPiece)
        }

        // The trailing end
        safelyModifyPiece(&changeDescription, range.upperBound.pieceIndex) { piece in
            piece.startIndex = range.upperBound.contentIndex
        }

        applyChange(changeDescription)
    }
}
