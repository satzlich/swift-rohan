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

extension Trace {
  mutating func buildLocation() -> TextLocation? {
    guard let last,
      var offset = last.index.index()
    else { return nil }

    var lastNode: Node = last.node

    while true {
      switch lastNode {
      case let container as ElementNode where isParagraphContainerLike(container):
        if offset < container.childCount,
          let child = container.getChild(offset) as? ElementNode,
          child.isTransparent
        {
          // make progress
          self.append(child, .index(0))
          lastNode = child
          offset = 0
          continue
        }
        else {
          return TextLocation(_elements.dropLast().map(\.index), offset)
        }

      case let node as ElementNode:
        if offset < node.childCount,
          isTextNode(node.getChild(offset))
        {
          return TextLocation(_elements.map(\.index), 0)
        }
        else if offset > 0,
          let textNode = node.getChild(offset - 1) as? TextNode
        {
          self.moveTo(.index(offset - 1))
          return TextLocation(_elements.map(\.index), textNode.llength)
        }
        else {
          return TextLocation(_elements.dropLast().map(\.index), offset)
        }

      // Verbatim from "case let node as ElementNode:"
      case let node as ArgumentNode:
        if offset < node.childCount,
          isTextNode(node.getChild(offset))
        {
          return TextLocation(_elements.map(\.index), 0)
        }
        else if offset > 0,
          let textNode = node.getChild(offset - 1) as? TextNode
        {
          self.moveTo(.index(offset - 1))
          return TextLocation(_elements.map(\.index), textNode.llength)
        }
        else {
          return TextLocation(_elements.dropLast().map(\.index), offset)
        }

      default:
        return TextLocation(_elements.dropLast().map(\.index), offset)
      }
    }
  }
}
