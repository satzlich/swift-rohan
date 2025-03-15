// Copyright 2024-2025 Lie Yan

import DequeModule
import Foundation

/** A partial element reprsents an element node with only a subset of its children. */
final class SlicedElement: Encodable {
  typealias BackStore = Deque<PartialNode>

  /** the underlying node */
  private var _sourceNode: ElementNode
  /** children are append-only */
  private var _children: Deque<PartialNode> = []

  init(for elementNode: ElementNode) {
    _sourceNode = elementNode
  }

  func appendChild(_ child: PartialNode) {
    _children.append(child)
  }

  func prependChild(_ child: PartialNode) {
    _children.prepend(child)
  }

  func deepCopy() -> ElementNode {
    let copy = _sourceNode.cloneEmpty()
    let children = _children.map { $0.deepCopy() }
    // insert children with `inStorage: false` as copy is unattached
    copy.insertChildren(contentsOf: children, at: 0, inStorage: false)
    return copy
  }

  // MARK: - Encodable

  func encode(to encoder: any Encoder) throws {
    try _sourceNode.encode(to: encoder, withChildren: _children)
  }
}
