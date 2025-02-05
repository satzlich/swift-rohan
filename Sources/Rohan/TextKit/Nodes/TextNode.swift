// Copyright 2024-2025 Lie Yan

import Foundation

public final class TextNode: Node {
    override class var nodeType: NodeType { .text }

    public let string: String

    override final func getChild(_ index: RohanIndex) -> Node? { nil }

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

    /**
     Convert offset to layout offset.

     - Complexity: O(n) where n is the offset. It can be more efficient if big
     string is used.
     */
    final func layoutOffset(for offset: Int) -> Int {
        precondition(0 ... length ~= offset)
        let index = string.index(string.startIndex, offsetBy: offset)
        return string.utf16.distance(from: string.utf16.startIndex, to: index)
    }

    /**
     Convert layout offset to offset.

     - Complexity: O(n) where n is the layout offset. It can be more efficient
     if big string is used.
     */
    final func offset(for layoutOffset: Int) -> Int {
        precondition(0 ... layoutLength ~= layoutOffset)
        let index = string.utf16.index(string.utf16.startIndex,
                                       offsetBy: layoutOffset)
        return string.distance(from: string.startIndex, to: index)
    }

    override class var startPadding: Bool { false }
    override class var endPadding: Bool { false }

    override func getOffset(before index: RohanIndex) -> Int {
        guard let i = index.arrayIndex() else { fatalError("Expect array index") }
        assert(i <= length)
        return i
    }

    override func _getLocation(_ offset: Int, _ path: inout [RohanIndex]) -> Int {
        precondition(0 ... length ~= offset)
        return offset
    }
}
