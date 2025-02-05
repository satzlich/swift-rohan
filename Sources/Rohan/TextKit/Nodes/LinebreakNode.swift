// Copyright 2024-2025 Lie Yan

import Foundation

final class LinebreakNode: Node {
    override final class var nodeType: NodeType { .linebreak }

    // MARK: - Content

    override class var isTransparent: Bool { false }

    override var intrinsicLength: Int { 0 }

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

    // MARK: - Offset/Length

    override var length: Int { 1 }

    override class var startPadding: Bool { false }
    override class var endPadding: Bool { false }

    override func getOffset(before index: RohanIndex) -> Int {
        guard let i = index.arrayIndex() else { fatalError("Expect array index") }
        return i
    }

    // MARK: - Index/Location

    override func getChild(_ index: RohanIndex) -> Node? { nil }

    override func _getLocation(_ offset: Int, _ path: inout [RohanIndex]) -> Int { offset
    }

    // MARK: - Clone and Visitor

    override func deepCopy() -> Node { LinebreakNode() }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(linebreak: self, context)
    }
}
