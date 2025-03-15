// Copyright 2024-2025 Lie Yan

import DequeModule
import Foundation

/** A partial element reprsents an element node with only a subset of its children. */
struct SlicedElement {
  /** the underlying node */
  private var _node: ElementNode
  /** children are append-only */
  private var _children: Deque<PartialNode> = []

  init(for node: ElementNode) {
    _node = node
  }

  mutating func appendChild(_ child: PartialNode) {
    _children.append(child)
  }

  mutating func prependChild(_ child: PartialNode) {
    _children.prepend(child)
  }

  func deepCopy() -> ElementNode {
    let copy = _node.cloneEmpty()
    let children = _children.map { $0.deepCopy() }
    // insert children with `inStorage: false` as copy is unattached
    copy.insertChildren(contentsOf: children, at: 0, inStorage: false)
    return copy
  }
}
