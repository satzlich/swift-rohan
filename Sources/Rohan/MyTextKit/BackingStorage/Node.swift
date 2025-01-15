// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

class Node {
    weak var parent: Node?
    var isBlock: Bool { false }

    final var length: Int { contentLength }
    var contentLength: Int { preconditionFailure() }

    func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        preconditionFailure()
    }

    func copy() -> Node { preconditionFailure() }

    func _onContentChange(lengthDelta: Int) {
        parent?._onContentChange(lengthDelta: lengthDelta)
    }
}

final class TextNode: Node {
    let string: String

    override var contentLength: Int { string.count }

    internal init(_ string: String) {
        self.string = string
    }

    private init(_ textNode: TextNode) {
        self.string = textNode.string
    }

    override func copy() -> Self { Self(self) }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(text: self, context)
    }

    static func validate(string: String) -> Bool { Text.validate(string: string) }
}

class ElementNode: Node {
    private var _storage: ElementStorage

    private var _children: [Node] {
        @inline(__always) get { _storage.children }
        @inline(__always) _modify { yield &_storage.children }
    }

    private var _contentLength: Int
    override final var contentLength: Int { _contentLength }

    internal init(_ children: [Node] = []) {
        self._storage = ElementStorage(children: children)
        self._contentLength = children.reduce(0) { $0 + $1.length }
    }

    internal init(_ elementNode: ElementNode) {
        self._storage = elementNode._storage
        self._contentLength = elementNode._contentLength
    }

    final func childCount() -> Int { _children.count }

    final func getChild(_ index: Int) -> Node { _children[index] }

    final func insertChild(_ node: Node, at index: Int) {
        _storage.ensureUnique()
        _children.insert(node, at: index)

        // post update
        node.parent = self
        _onContentChange(lengthDelta: node.length)
    }

    final func removeChild(at index: Int) {
        _storage.ensureUnique()
        let removed = _children.remove(at: index)

        // post update
        removed.parent = nil
        _onContentChange(lengthDelta: -removed.length)
    }

    final func removeSubrange(_ range: Range<Int>) {
        _storage.ensureUnique()

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
        _storage.ensureUnique()

        _contentLength += lengthDelta
        super._onContentChange(lengthDelta: lengthDelta)
    }
}

final class RootNode: ElementNode {
    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(root: self, context)
    }

    override func copy() -> Self { Self(self) }
}

final class ContentNode: ElementNode {
    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(content: self, context)
    }

    override func copy() -> Self { Self(self) }
}

final class ParagraphNode: ElementNode {
    override var isBlock: Bool { true }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(paragraph: self, context)
    }

    override func copy() -> Self { Self(self) }
}

final class HeadingNode: ElementNode {
    let level: Int

    override var isBlock: Bool { true }

    init(level: Int, _ children: [Node]) {
        self.level = level
        super.init(children)
    }

    internal init(_ headingNode: HeadingNode) {
        self.level = headingNode.level
        super.init(headingNode)
    }

    override func copy() -> Self { Self(self) }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(heading: self, context)
    }
}

final class EmphasisNode: ElementNode {
    override func copy() -> Self { Self(self) }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(emphasis: self, context)
    }
}

final class EquationNode: Node {
    private let _isBlock: Bool
    let nucleus: ContentNode

    override var isBlock: Bool { _isBlock }
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
    }

    override func copy() -> Self { Self(self) }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(equation: self, context)
    }
}

struct ElementStorage {
    private var object: _ElementStorage

    var children: [Node] {
        @inline(__always) get { object.children }
        @inline(__always) _modify { yield &object.children }
    }

    init(children: [Node]) {
        self.object = _ElementStorage(children: children)
    }

    mutating func isUnique() -> Bool { isKnownUniquelyReferenced(&object) }

    mutating func ensureUnique() {
        guard !isKnownUniquelyReferenced(&object) else { return }
        object = object.copy()
    }

    private final class _ElementStorage {
        var children: [Node]

        init(children: [Node]) {
            self.children = children
        }

        func copy() -> _ElementStorage {
            _ElementStorage(children: children)
        }
    }
}
