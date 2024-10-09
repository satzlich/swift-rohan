// Copyright 2024 Lie Yan

import Foundation

extension PieceTable {
    /**
     Append-only storage.
     */
    @usableFromInline
    final class Storage {
        typealias Index = Int

        private var elements: ContiguousArray<Element>

        public func append<S>(contentsOf newElements: S) -> (startIndex: Index, endIndex: Index)
        where S: Sequence, S.Element == Element {
            let startIndex = elements.endIndex
            elements.append(contentsOf: newElements)
            let endIndex = elements.endIndex

            return (startIndex, endIndex)
        }

        public func append(_ element: Element) -> (startIndex: Index, endIndex: Index) {
            append(contentsOf: [element])
        }

        @usableFromInline
        convenience init() {
            self.init([])
        }

        @usableFromInline
        init<S>(_ elements: S)
            where S: Sequence, S.Element == Element
        {
            self.elements = []
            self.elements.append(contentsOf: elements)
        }

        public var isEmpty: Bool {
            elements.isEmpty
        }

        public var count: Int {
            elements.count
        }

        public subscript(index: Index) -> Element {
            elements[index]
        }

        public var startIndex: Index {
            elements.startIndex
        }

        public var endIndex: Index {
            elements.endIndex
        }
    }
}
