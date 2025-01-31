// Copyright 2024-2025 Lie Yan

import Foundation

public final class TextNode: Node {
    override class var nodeType: NodeType { .text }

    public let string: String

    override final func _getChild(_ index: RohanIndex) -> Node? { nil }

    public init(_ string: String) {
        precondition(Text.validate(string: string))
        self.string = string
    }

    internal init(_ textNode: TextNode) {
        self.string = textNode.string
    }

    internal init(deepCopyOf textNode: TextNode) {
        self.string = textNode.string
    }

    // MARK: - Layout

    override var isBlock: Bool { false }

    private var _isDirty: Bool = false
    override var isDirty: Bool { _isDirty }

    override func performLayout(_ context: LayoutContext, fromScratch: Bool) {
        context.insertText(self)
        _isDirty = false
    }

    // MARK: - Clone and Visitor

    override public func deepCopy() -> Self { Self(deepCopyOf: self) }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(text: self, context)
    }

    // MARK: - Length & Location

    override var layoutLength: Int { string.utf16.count }

    /** Optimise length by caching */
    private lazy var _length: Int = string.count
    override var length: Int { @inline(__always) get { _length } }

    override class var startPadding: Bool { false }
    override class var endPadding: Bool { false }

    override func _partialLength(before index: RohanIndex) -> Int {
        guard let i = index.arrayIndex()?.intValue else { fatalError("invalid index") }
        assert(i <= length)
        return i
    }

    override func _locate(_ offset: Int, _ path: inout [RohanIndex]) -> Int {
        precondition(0 ... length ~= offset)
        return offset
    }
}
