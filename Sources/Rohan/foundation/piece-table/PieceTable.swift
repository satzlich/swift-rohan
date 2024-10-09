// Copyright 2024 Lie Yan

import Foundation

// MARK: - PieceTable

struct PieceTable<Element> {
    private let _initialContents: [Element]
    private var _addedContents: [Element]

    private enum PieceSource {
        case initial
        case added
    }

    private struct Piece {
        let source: PieceSource

        private(set) var _startIndex: Int
        var startIndex: Int {
            get {
                _startIndex
            }
            set {
                precondition(newValue >= 0)
                _startIndex = newValue
            }
        }

        var length: Int {
            _endIndex - _startIndex
        }

        /**
         End index of the text, exclusive
         */
        private(set) var _endIndex: Int
        var endIndex: Int {
            get {
                _endIndex
            }
            set {
                precondition(newValue >= startIndex)
                _endIndex = newValue
            }
        }

        var isEmpty: Bool {
            length == 0
        }

        init(_ source: PieceSource,
             _ startIndex: Int,
             _ length: Int)
        {
            precondition(startIndex >= 0)
            // No empty pieces
            precondition(length > 0)

            self.source = source
            self._startIndex = startIndex
            self._endIndex = startIndex + length
        }
    }

    private var pieces: [Piece]

    public init(_ elements: [Element]) {
        self._initialContents = elements
        self._addedContents = []

        if !elements.isEmpty {
            self.pieces = [Piece(.initial, 0, _initialContents.count)]
        }
        else {
            self.pieces = []
        }
    }

    public init() {
        self.init([])
    }
}

// MARK: - PieceTable + Collection

extension PieceTable: Collection {
    public struct Index: Comparable {
        /**
         piece index
         */
        fileprivate let pieceIndex: Int
        /**
         content index
         */
        fileprivate let contentIndex: Int

        public static func < (lhs: Index, rhs: Index) -> Bool {
            (lhs.pieceIndex, lhs.contentIndex) < (rhs.pieceIndex, rhs.contentIndex)
        }

        init(_ pieceIndex: Int, contentIndex: Int) {
            self.pieceIndex = pieceIndex
            self.contentIndex = contentIndex
        }
    }

    public var startIndex: Index {
        Index(0, contentIndex: pieces.first?.startIndex ?? 0)
    }

    public var endIndex: Index {
        Index(pieces.count, contentIndex: 0)
    }

    public var count: Int {
        pieces.reduce(0) { $0 + $1.length }
    }

    func index(after i: Index) -> Index {
        let piece = pieces[i.pieceIndex]

        // Check if the the next content is within the piece
        if i.contentIndex + 1 < piece.endIndex {
            return Index(i.pieceIndex, contentIndex: i.contentIndex + 1)
        }

        // Move to the next piece
        let nextPieceIndex = i.pieceIndex + 1

        if nextPieceIndex < pieces.endIndex {
            return Index(nextPieceIndex, contentIndex: pieces[nextPieceIndex].startIndex)
        }
        else {
            return Index(nextPieceIndex, contentIndex: 0)
        }
    }

    private func sourceContents(_ source: PieceSource) -> [Element] {
        switch source {
        case .initial:
            _initialContents
        case .added:
            _addedContents
        }
    }

    subscript(position: Index) -> Element {
        let piece = pieces[position.pieceIndex]
        let contents = sourceContents(piece.source)
        return contents[position.contentIndex]
    }
}

// MARK: - PieceTable + RangeReplaceableCollection

extension PieceTable: RangeReplaceableCollection {
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
        mutating func appendPiece(_ piece: Piece, _ pieceIndex: Int?) {
            if let pieceIndex {
                lowerBound = lowerBound.map { Swift.min($0, pieceIndex) } ?? pieceIndex
                upperBound = upperBound.map { Swift.max($0, pieceIndex) } ?? pieceIndex
            }

            // No empty piece
            guard !piece.isEmpty else {
                return
            }

            // if `piece` continues from the last piece, extend the last.
            if let last = values.last,
               last.source == piece.source,
               last.endIndex == piece.startIndex
            {
                values[values.count - 1].endIndex = piece.endIndex
            }
            else {
                values.append(piece)
            }
        }

        mutating func appendPiece(_ piece: Piece) {
            appendPiece(piece, nil)
        }
    }

    private func safelyModifyPiece(
        _ description: inout ChangeDescription,
        _ pieceIndex: Int,
        modificationBlock: (inout Piece) -> Void
    ) {
        guard pieceIndex >= 0, pieceIndex < pieces.count else {
            return
        }

        // apply modifcation
        var piece = pieces[pieceIndex]
        modificationBlock(&piece)

        // update change description
        description.appendPiece(piece, pieceIndex)
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
            range = pieces.endIndex ..< pieces.endIndex
        }
        pieces.replaceSubrange(range, with: changeDescription.values)
    }

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
            let index = _addedContents.endIndex
            _addedContents.append(contentsOf: newElements)

            let newPiece = Piece(.added, index, newElements.count)
            changeDescription.appendPiece(newPiece)
        }

        // The trailing end
        safelyModifyPiece(&changeDescription, range.upperBound.pieceIndex) { piece in
            piece.startIndex = range.upperBound.contentIndex
        }

        applyChange(changeDescription)
    }
}
