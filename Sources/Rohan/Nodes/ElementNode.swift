// Copyright 2024-2025 Lie Yan

public class ElementNode: Node {
    @usableFromInline var _children: [Node]
    private var _length: Int
    override final var length: Int { _length }
    private var _nsLength: Int
    override final var nsLength: Int { _nsLength }

    public init(_ children: [Node] = []) {
        self._children = children
        self._length = children.reduce(0) { $0 + $1.length }
        self._nsLength = children.reduce(0) { $0 + $1.nsLength }
        super.init()

        _children.forEach { $0.parent = self }
    }

    internal init(_ elementNode: ElementNode) {
        self._children = elementNode._children
        self._length = elementNode._length
        self._nsLength = elementNode._nsLength
    }

    // MARK: - Location and Length

    override final func _childIndex(
        for offset: Int,
        _ affinity: Affinity
    ) -> (index: RohanIndex, offset: Int)? {
        precondition(offset >= 0 && offset <= length)

        func index(_ i: Int) -> RohanIndex { .arrayIndex(i) }

        var s = 0
        // invariant: s = sum { length | 0 ..< i }
        for (i, node) in _children.enumerated() {
            let n = s + node.length
            if n < offset { // move on
                s = n
            }
            else if n == offset,
                    affinity == .downstream,
                    i + 1 < _children.count
            { // boundary
                return (index(i + 1), 0)
            }
            else { // found
                return (index(i), offset - s)
            }
        }
        assert(s == 0)
        return nil
    }

    override final func _getChild(_ index: RohanIndex) -> Node? {
        guard let i = index.arrayIndex()?.index else { return nil }
        assert(i <= _children.count)
        return getChild(i, ensureUnique: false)
    }

    override final func _length(before index: RohanIndex) -> Int {
        guard let i = index.arrayIndex()?.index else { fatalError("invalid index") }
        assert(i <= _children.count)
        return _children[..<i].reduce(0) { $0 + $1.length }
    }

    override final func _onContentChange(delta: _Summary) {
        _length += delta.length
        _nsLength += delta.nsLength
        super._onContentChange(delta: delta)
    }

    // MARK: - Children

    @inlinable
    public final func childCount() -> Int { _children.count }

    @inlinable
    public final func getChild(_ index: Int) -> Node {
        if !isKnownUniquelyReferenced(&_children[index]) {
            _children[index] = _children[index].copy()
            _children[index].parent = self
        }
        return _children[index]
    }

    @inlinable
    internal final func getChild(_ index: Int, ensureUnique: Bool) -> Node {
        ensureUnique ? getChild(index) : _children[index]
    }

    public final func insertChild(_ node: Node, at index: Int) {
        _children.insert(node, at: index)

        // post update
        node.parent = self
        _onContentChange(delta: node._summary)
    }

    public final func insertChildren(contentsOf nodes: [Node], at index: Int) {
        _children.insert(contentsOf: nodes, at: index)

        // post update
        nodes.forEach { $0.parent = self }
        _onContentChange(delta: nodes.reduce(.init()) { $0 + $1._summary })
    }

    public final func removeChild(at index: Int) {
        let removed = _children.remove(at: index)

        // post update
        removed.parent = nil
        _onContentChange(delta: -removed._summary)
    }

    public final func removeSubrange(_ range: Range<Int>) {
        // pre update
        var summary: _Summary = .init()
        for i in range {
            summary += _children[i]._summary
            _children[i].parent = nil
        }
        _onContentChange(delta: -summary)

        // perform remove
        _children.removeSubrange(range)
    }
}

public final class RootNode: ElementNode {
    override class var nodeType: NodeType { .root }

    override class var isLayoutRoot: Bool { true }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(root: self, context)
    }

    override public func copy() -> Self { Self(self) }
}

public final class ContentNode: ElementNode {
    override class var nodeType: NodeType { .content }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(content: self, context)
    }

    override public func copy() -> Self { Self(self) }
}

public final class ParagraphNode: ElementNode {
    override class var nodeType: NodeType { .paragraph }

    override var isBlock: Bool { true }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(paragraph: self, context)
    }

    override public func copy() -> Self { Self(self) }
}

public final class HeadingNode: ElementNode {
    override class var nodeType: NodeType { .heading }

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
    override class var nodeType: NodeType { .emphasis }

    override public func copy() -> Self { Self(self) }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(emphasis: self, context)
    }
}
