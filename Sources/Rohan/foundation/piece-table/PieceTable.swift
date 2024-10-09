// Copyright 2024 Lie Yan

import Foundation

// MARK: - PieceTable

struct PieceTable {
    private let _initialContents: [unichar]
    private var _addedContents: [unichar]

    private enum PieceSource {
        case initial
        case added
    }

    private struct Piece {
        private var _startIndex: Int

        var source: PieceSource {
            (_startIndex & 0x1) == 0 ? .initial : .added
        }

        var startIndex: Int {
            get {
                _startIndex >> 1
            }
            set {
                precondition(newValue >= 0)

                let bit = (_startIndex & 0x1)
                _startIndex = (newValue << 1) | bit
            }
        }

        var length: Int

        /**
         End index of the text, exclusive
         */
        var endIndex: Int {
            get {
                startIndex + length
            }
            set {
                precondition(newValue > startIndex)
                length = newValue - startIndex
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

            let bit = (source == .initial) ? 0x0 : 0x1
            self._startIndex = (startIndex << 1) | bit
            self.length = length
        }
    }

    private var pieces: [Piece]

    public init(_ string: String) {
        self._initialContents = Array(string.utf16)
        self._addedContents = []
        self.pieces = [Piece(.initial, 0, _initialContents.count)]
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

    private func sourceContents(_ source: PieceSource) -> [unichar] {
        switch source {
        case .initial:
            _initialContents
        case .added:
            _addedContents
        }
    }

    subscript(position: Index) -> unichar {
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
         The smallest index of an existing piece added to `values`
         */
        var lowerBound: Int?

        /**
         The greatest index of an existing piece added to `values`, inclusive.
         */
        var upperBound: Int?

        mutating func addPiece(_ piece: Piece) {
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
        }
    }

    private func safelyAddToDescription(
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
        description.lowerBound = description.lowerBound.map { Swift.min($0, pieceIndex) } ?? pieceIndex
        description.upperBound = description.lowerBound.map { Swift.max($0, pieceIndex) } ?? pieceIndex
        description.addPiece(piece)
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
        C.Element == Self.Element, R.Bound == Self.Index
    {
        let range = subrange.relative(to: self)

        // The (possibly) mutated pieces
        var changeDescription = ChangeDescription()

        safelyAddToDescription(&changeDescription, range.lowerBound.pieceIndex - 1) { _ in
            // No modification

            // Adding the piece immediately before the lower bound allows
            // coalesce with that piece.
        }

        safelyAddToDescription(&changeDescription, range.lowerBound.pieceIndex) { piece in
            piece.endIndex = range.lowerBound.contentIndex
        }

        if !newElements.isEmpty {
            let index = _addedContents.endIndex
            _addedContents.append(contentsOf: newElements)

            let newPiece = Piece(.added, index, newElements.count)
            changeDescription.addPiece(newPiece)
        }

        safelyAddToDescription(&changeDescription, range.upperBound.pieceIndex) { piece in
            piece.startIndex = range.upperBound.contentIndex
        }

        applyChange(changeDescription)
    }
}
