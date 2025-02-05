// Copyright 2024-2025 Lie Yan

import Foundation

public final class LinebreakNode: Node {
    override final class var nodeType: NodeType { .linebreak }

    // MARK: - Content

    override final var extrinsicLength: Int { 1 }

    // MARK: - Layout

    override var layoutLength: Int { 1 }
    override var isBlock: Bool { false }
    override var isDirty: Bool { false }

    override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
        if fromScratch {
            context.insertNewline(self)
        }
        else {
            context.skipBackwards(1)
        }
    }

    // MARK: - Clone and Visitor

    override public func deepCopy() -> Node { LinebreakNode() }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(linebreak: self, context)
    }
}
