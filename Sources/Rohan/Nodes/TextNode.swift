// Copyright 2024-2025 Lie Yan

public final class TextNode: Node {
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

    override func _locate(_ offset: Int,
                          _ affinity: Affinity,
                          _ path: inout [RohanIndex]) -> Int
    {
        precondition(offset >= 0 && offset <= length)
        return offset
    }

    override func _offset(_ path: ArraySlice<RohanIndex>, _ acc: inout Int) {
        precondition(path.count <= 1)
        if path.isEmpty { return }
        guard let index = path.first!.arrayIndex()?.index
        else { preconditionFailure() }
        assert(index <= length)
        acc += index
        return
    }

    override public func copy() -> Self { Self(self) }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(text: self, context)
    }

    static func validate(string: String) -> Bool { Text.validate(string: string) }
}
