// Copyright 2024-2025 Lie Yan

import Foundation

class Node {
    weak var parent: Node?

    final var length: Int { contentLength }
    var contentLength: Int { preconditionFailure() }

    func _onContentChange(lengthDelta: Int) {
        parent?._onContentChange(lengthDelta: lengthDelta)
    }

    func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        preconditionFailure()
    }
}

final class TextNode: Node {
    let string: String

    override var contentLength: Int { string.count }

    internal init(_ string: String) {
        self.string = string
    }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(text: self, context)
    }

    internal static func validate(string: String) -> Bool {
        return !string.contains(#/\r\n|\n|\r/#)
    }
}

class ElementNode: Node {
    private var _children: [Node]
    private var _contentLength: Int
    override final var contentLength: Int { _contentLength }

    init(_ children: [Node] = []) {
        self._children = children
        self._contentLength = children.reduce(0) { $0 + $1.length }
    }

    final func childCount() -> Int { _children.count }

    final func getChild(_ index: Int) -> Node { _children[index] }

    final func insertChild(_ node: Node, at index: Int) {
        _children.insert(node, at: index)

        // post update
        node.parent = self
        _onContentChange(lengthDelta: node.length)
    }

    final func removeChild(at index: Int) {
        let removed = _children.remove(at: index)

        // post update
        removed.parent = nil
        _onContentChange(lengthDelta: -removed.length)
    }

    final func removeSubrange(_ range: Range<Int>) {
        // pre update
        var removedLength = 0
        for i in range {
            removedLength += _children[i].length
            _children[i].parent = nil
        }
        _onContentChange(lengthDelta: -removedLength)

        // perform remove
        _children.removeSubrange(range)
    }

    override final func _onContentChange(lengthDelta: Int) {
        _contentLength += lengthDelta
        super._onContentChange(lengthDelta: lengthDelta)
    }
}

final class RootNode: ElementNode {
    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(root: self, context)
    }
}

final class ContentNode: ElementNode {
    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(content: self, context)
    }
}

final class ParagraphNode: ElementNode {
    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(paragraph: self, context)
    }
}

final class HeadingNode: ElementNode {
    let level: Int

    init(level: Int, _ children: [Node]) {
        self.level = level
        super.init(children)
    }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(heading: self, context)
    }
}

final class EmphasisNode: ElementNode {
    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(emphasis: self, context)
    }
}

final class EquationNode: Node {
    let isBlock: Bool
    var nucleus: ContentNode

    override var contentLength: Int { nucleus.length }

    init(isBlock: Bool, nucleus: ContentNode = .init()) {
        self.isBlock = isBlock
        self.nucleus = ContentNode()
        super.init()

        // set parent
        self.nucleus.parent = self
    }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(equation: self, context)
    }
}
