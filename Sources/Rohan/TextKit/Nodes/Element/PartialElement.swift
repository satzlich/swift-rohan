// Copyright 2024-2025 Lie Yan

import Foundation

/** A partial element reprsents an element node with only a subset of its children. */
struct PartialElement {
  /** the underlying node */
  private var _node: ElementNode
  /** children are append-only */
  private var _children: [Node] = []

  init(for node: ElementNode) {
    _node = node
  }

  mutating func appendChild(_ child: Node) {
    _children.append(child)
  }

  func deepCopy() -> ElementNode {
    let copy = _node.cloneEmpty()
    let children = _children.map { $0.deepCopy() }
    // insert children with `inStorage: false` as copy is unattached
    copy.insertChildren(contentsOf: children, at: 0, inStorage: false)
    return copy
  }
}
