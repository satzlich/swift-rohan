// Copyright 2024-2025 Lie Yan

import _RopeModule
import Foundation

public final class TextNode: Node {
    override class var nodeType: NodeType { .text }

    private let _bigString: BigString
    var bigString: BigString { _bigString }

    public func getString() -> String { String(_bigString) }

    override final func getChild(_ index: RohanIndex) -> Node? { nil }

    public init(_ string: String) {
        precondition(Text.validate(string: string))
        self._bigString = BigString(string)
    }

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

    override final class var isTransparent: Bool { true }
    override final var intrinsicLength: Int { _bigString.count }

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

    // MARK: - Length & Location

    /** Optimise length by caching */
    override var length: Int { @inline(__always) get { _bigString.count } }

    /**
     Convert offset to layout offset.

     - Complexity: O(n) where n is the offset. It can be more efficient if big
     string is used.
     */
    final func layoutOffset(for offset: Int) -> Int {
        precondition(0 ... length ~= offset)
        let index = _bigString.index(_bigString.startIndex, offsetBy: offset)
        return _bigString.utf16.distance(from: _bigString.utf16.startIndex, to: index)
    }

    /**
     Convert layout offset to offset.

     - Complexity: O(n) where n is the layout offset. It can be more efficient
     if big string is used.
     */
    final func offset(for layoutOffset: Int) -> Int {
        precondition(0 ... layoutLength ~= layoutOffset)
        let index = _bigString.utf16.index(_bigString.utf16.startIndex,
                                           offsetBy: layoutOffset)
        return _bigString.distance(from: _bigString.startIndex, to: index)
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
