// Copyright 2024-2025 Lie Yan

public final class TextNode: Node {
    override class var nodeType: NodeType { .text }

    public let string: String

    override var length: Int { string.count }
    override var nsLength: Int { string.nsLength() }

    public init(_ string: String) {
        precondition(TextNode.validate(string: string))
        self.string = string
    }

    internal init(_ textNode: TextNode) {
        self.string = textNode.string
    }

    internal init(deepCopyOf textNode: TextNode) {
        self.string = textNode.string
    }

    internal static func validate(string: String) -> Bool {
        Text.validate(string: string)
    }

    // MARK: - Layout

    override var isBlock: Bool { false }

    var _isDirty: Bool = false
    override var isDirty: Bool { _isDirty }

    override func performLayout(_ context: RhLayoutContext, fromScratch: Bool) {
        context.insert(text: self)
        _isDirty = false
    }

    // MARK: - Clone and Visitor

    override public func deepCopy() -> Self { Self(deepCopyOf: self) }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(text: self, context)
    }

    // MARK: - Location and Length

    override final func _childIndex(
        for offset: Int,
        _ affinity: SelectionAffinity
    ) -> (index: RohanIndex, offset: Int)? {
        precondition(offset >= 0 && offset <= length)
        return nil
    }

    override final func _getChild(_ index: RohanIndex) -> Node? { nil }

    override final func _length(before index: RohanIndex) -> Int {
        guard let i = index.arrayIndex()?.index else { fatalError("invalid index") }
        assert(i <= length)
        return i
    }
}
