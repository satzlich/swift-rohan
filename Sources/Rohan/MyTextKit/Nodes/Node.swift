// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

public class Node {
    @usableFromInline
    internal weak var parent: Node?

    var isBlock: Bool { false }
    var contentLength: Int { preconditionFailure() }
    final var length: Int { contentLength }

    public func copy() -> Node { preconditionFailure() }

    func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        preconditionFailure()
    }

    func _onContentChange(delta: Int) {
        parent?._onContentChange(delta: delta)
    }
}

public final class TextNode: Node {
    public let string: String

    override var contentLength: Int { string.count }

    public init(_ string: String) {
        precondition(TextNode.validate(string: string))
        self.string = string
    }

    internal init(_ textNode: TextNode) {
        self.string = textNode.string
    }

    override public func copy() -> Self { Self(self) }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(text: self, context)
    }

    static func validate(string: String) -> Bool { Text.validate(string: string) }
}

public class ElementNode: Node {
    @usableFromInline var _children: [Node]
    private var _contentLength: Int
    override final var contentLength: Int { _contentLength }

    internal init(_ children: [Node] = []) {
        self._children = children
        self._contentLength = children.reduce(0) { $0 + $1.length }
        super.init()

        _children.forEach { $0.parent = self }
    }

    internal init(_ elementNode: ElementNode) {
        self._children = elementNode._children
        self._contentLength = elementNode._contentLength
    }

    final func childCount() -> Int { _children.count }

    @inlinable
    final func getChild(_ index: Int) -> Node {
        if !isKnownUniquelyReferenced(&_children[index]) {
            _children[index] = _children[index].copy()
            _children[index].parent = self
        }
        return _children[index]
    }

    @inlinable
    final func getChild(_ index: Int, ensureUnique: Bool) -> Node {
        ensureUnique ? getChild(index) : _children[index]
    }

    final func insertChild(_ node: Node, at index: Int) {
        _children.insert(node, at: index)

        // post update
        node.parent = self
        _onContentChange(delta: node.length)
    }

    final func removeChild(at index: Int) {
        let removed = _children.remove(at: index)

        // post update
        removed.parent = nil
        _onContentChange(delta: -removed.length)
    }

    final func removeSubrange(_ range: Range<Int>) {
        // pre update
        var removedLength = 0
        for i in range {
            removedLength += _children[i].length
            _children[i].parent = nil
        }
        _onContentChange(delta: -removedLength)

        // perform remove
        _children.removeSubrange(range)
    }

    override final func _onContentChange(delta: Int) {
        _contentLength += delta
        super._onContentChange(delta: delta)
    }
}

public final class RootNode: ElementNode {
    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(root: self, context)
    }

    override public func copy() -> Self { Self(self) }
}

public final class ContentNode: ElementNode {
    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(content: self, context)
    }

    override public func copy() -> Self { Self(self) }
}

public final class ParagraphNode: ElementNode {
    override var isBlock: Bool { true }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(paragraph: self, context)
    }

    override public func copy() -> Self { Self(self) }
}

public final class HeadingNode: ElementNode {
    public let level: Int

    override var isBlock: Bool { true }

    init(level: Int, _ children: [Node]) {
        self.level = level
        super.init(children)
    }

    internal init(_ headingNode: HeadingNode) {
        self.level = headingNode.level
        super.init(headingNode)
    }

    override public func copy() -> Self { Self(self) }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(heading: self, context)
    }
}

public final class EmphasisNode: ElementNode {
    override public func copy() -> Self { Self(self) }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(emphasis: self, context)
    }
}

public final class EquationNode: Node {
    public let nucleus: ContentNode
    override public var isBlock: Bool { _isBlock }

    private let _isBlock: Bool
    override var contentLength: Int { nucleus.length }

    init(isBlock: Bool, nucleus: ContentNode = .init()) {
        self._isBlock = isBlock
        self.nucleus = ContentNode()
        super.init()

        // set parent
        self.nucleus.parent = self
    }

    internal init(_ equationNode: EquationNode) {
        self._isBlock = equationNode._isBlock
        self.nucleus = equationNode.nucleus.copy()
        super.init()

        // set parent
        nucleus.parent = self
    }

    override public func copy() -> Self { Self(self) }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(equation: self, context)
    }
}
