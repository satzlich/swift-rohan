// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

final class LinebreakNode: SimpleNode {
  override class var type: NodeType { .linebreak }

  override init() { super.init() }

  required init(from decoder: any Decoder) throws {
    try super.init(from: decoder)
  }

  // MARK: - Layout

  override func layoutLength() -> Int { 1 }

  override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    context.insertText("\n", self)
  }

  // MARK: - Clone and Visitor

  override func deepCopy() -> LinebreakNode { LinebreakNode() }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(linebreak: self, context)
  }

  override class var storageTags: [String] {
    ["linebreak"]
  }
}
