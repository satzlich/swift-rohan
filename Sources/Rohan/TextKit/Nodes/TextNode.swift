// Copyright 2024-2025 Lie Yan

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

    var _isDirty: Bool = false
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

    override var layoutLength: Int { string.lengthAsNSString() }
    override var length: Int { string.count }
    override class var startPadding: Bool { false }
    override class var endPadding: Bool { false }

    override func _partialLength(before index: RohanIndex) -> Int {
        guard let i = index.arrayIndex()?.index else { fatalError("invalid index") }
        assert(i <= length)
        return i
    }

    override func _locate(_ offset: Int, _ path: inout [RohanIndex]) -> Int? {
        precondition(0 ... length ~= offset)
        return offset
    }
}
