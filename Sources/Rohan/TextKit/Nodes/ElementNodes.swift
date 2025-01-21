// Copyright 2024-2025 Lie Yan

public final class RootNode: ElementNode {
    override class var nodeType: NodeType { .root }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(root: self, context)
    }

    override public func deepCopy() -> Self { Self(deepCopyOf: self) }
}

public final class ContentNode: ElementNode {
    override class var nodeType: NodeType { .content }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(content: self, context)
    }

    override public func deepCopy() -> Self { Self(deepCopyOf: self) }
}

public final class ParagraphNode: ElementNode {
    override class var nodeType: NodeType { .paragraph }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(paragraph: self, context)
    }

    override public func deepCopy() -> Self { Self(deepCopyOf: self) }
}

public final class HeadingNode: ElementNode {
    override class var nodeType: NodeType { .heading }

    public let level: Int

    public init(level: Int, _ children: [Node]) {
        self.level = level
        super.init(children)
    }

    internal init(deepCopyOf headingNode: HeadingNode) {
        self.level = headingNode.level
        super.init(deepCopyOf: headingNode)
    }

    override public func deepCopy() -> Self { Self(deepCopyOf: self) }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(heading: self, context)
    }
}

public final class EmphasisNode: ElementNode {
    override class var nodeType: NodeType { .emphasis }

    override public func deepCopy() -> Self { Self(deepCopyOf: self) }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(emphasis: self, context)
    }
}

public final class TextModeNode: ElementNode {
    override class var nodeType: NodeType { .textMode }

    override public func deepCopy() -> Self { Self(deepCopyOf: self) }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(textMode: self, context)
    }
}
