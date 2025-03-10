// Copyright 2024-2025 Lie Yan

import Foundation

public final class UnknownNode: _SimpleNode {
  override class var nodeType: NodeType { .unknown }

  private let placeholder: String = "[Unknown Node]"

  // MARK: - Layout

  override var layoutLength: Int { placeholder.utf16.count }

  override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    context.insertText(placeholder, self)
  }

  // MARK: - Clone and Visitor

  override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
    visitor.visit(unknown: self, context)
  }
}
