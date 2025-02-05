// Copyright 2024-2025 Lie Yan

import _RopeModule
import Foundation

public final class TextNode: Node {
    override class var nodeType: NodeType { .text }

    private let _bigString: BigString
    var bigString: BigString { @inline(__always) get { _bigString } }

    public func getString() -> String { String(_bigString) }

    public init(_ bigString: BigString) {
        precondition(Text.validate(string: bigString))
        self._bigString = bigString
    }

    internal init(_ textNode: TextNode) {
        self._bigString = textNode._bigString
    }

    internal init(deepCopyOf textNode: TextNode) {
        self._bigString = textNode._bigString
    }

    // MARK: - Content

    override var extrinsicLength: Int { _bigString.count }

    // MARK: - Layout

    override final var layoutLength: Int { _bigString.utf16.count }

    override final var isBlock: Bool { false }

    private var _isDirty: Bool = false
    override final var isDirty: Bool { _isDirty }

    override func performLayout(_ context: LayoutContext, fromScratch: Bool) {
        context.insertText(self)
        _isDirty = false
    }

    // MARK: - Clone and Visitor

    override public func deepCopy() -> Self { Self(deepCopyOf: self) }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(text: self, context)
    }
}
