// Copyright 2024-2025 Lie Yan

import Foundation

struct Trace {
  var _elements: Array<TraceElement>

  init(_ elements: Array<TraceElement> = []) {
    self._elements = elements
  }

  @inline(__always)
  mutating func reserveCapacity(_ capacity: Int) {
    _elements.reserveCapacity(capacity)
  }

  @inline(__always)
  mutating func append(_ element: TraceElement) {
    _elements.append(element)
  }

  @inline(__always)
  mutating func append<S>(contentsOf elements: S)
  where S: Sequence, S.Element == TraceElement {
    _elements.append(contentsOf: elements)
  }

  @inline(__always)
  mutating func emplaceBack(_ node: Node, _ index: RohanIndex) {
    _elements.append(.init(node, index))
  }

  @inline(__always)
  mutating func truncate(to count: Int) {
    precondition(count <= _elements.count)
    _elements.removeLast(_elements.count - count)
  }
}

extension Trace: RandomAccessCollection {
  // Required

  var startIndex: Int { @inline(__always) get { _elements.startIndex } }
  var endIndex: Int { @inline(__always) get { _elements.endIndex } }

  @inline(__always)
  subscript(_ index: Int) -> TraceElement { _elements[index] }

  // Specialized

  typealias SubSequence = ArraySlice<TraceElement>

  @inline(__always)
  subscript(bounds: Range<Int>) -> ArraySlice<TraceElement> { _elements[bounds] }
}
