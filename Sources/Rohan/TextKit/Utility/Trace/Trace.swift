// Copyright 2024-2025 Lie Yan

import Foundation

struct Trace {
  var _elements: [TraceElement]

  var elements: [TraceElement] { @inline(__always) get { _elements } }

  var isEmpty: Bool { @inline(__always) get { _elements.isEmpty } }
  var count: Int { @inline(__always) get { _elements.count } }

  var last: TraceElement? { @inline(__always) get { _elements.last } }

  init(_ elements: [TraceElement]) {
    self._elements = elements
  }

  mutating func append(_ node: Node, _ index: RohanIndex) {
    _elements.append(.init(node, index))
  }

  mutating func truncate(to count: Int) {
    precondition(count <= _elements.count)
    _elements.removeLast(_elements.count - count)
  }
}

