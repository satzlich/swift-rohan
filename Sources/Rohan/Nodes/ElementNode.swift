// Copyright 2024-2025 Lie Yan

public class ElementNode: Node {
    @usableFromInline var _children: [Node]
    private var _length: Int
    override final var length: Int { _length }
    private var _nsLength: Int
    override var nsLength: Int { _nsLength }

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

    override final func _locate(
        _ offset: Int,
        _ context: inout [RohanIndex],
        preferEnd: Bool
    ) -> Int {
        precondition(offset >= 0 && offset <= length)

        var current = 0
        for (i, node) in _children.enumerated() {
            let n = current + node.length
            if n < offset {
                current = n
            }
            else {
                if n == offset, !preferEnd, i + 1 < _children.count {
                    context.append(.arrayIndex(i + 1))
                    return _children[i + 1]._locate(0, &context, preferEnd: preferEnd)
                }
                context.append(.arrayIndex(i))
                return node._locate(offset - current, &context, preferEnd: preferEnd)
            }
        }
        assert(current == 0)
        return offset
    }

    override final func _offset(_ path: ArraySlice<RohanIndex>, _ acc: inout Int) {
        // take the first index
        guard !path.isEmpty else { return }
        // sum up the length before the index
        guard let i = path.first!.arrayIndex()?.index
        else { preconditionFailure() }
        assert(i <= _children.count)
        acc += _children[..<i].reduce(0) { $0 + $1.length }
        // recurse
        if i == _children.count { return }
        _children[i]._offset(path.dropFirst(), &acc)
    }

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
        _onContentChange(delta: node.summary)
    }

    public final func insertChildren(contentsOf nodes: [Node], at index: Int) {
        _children.insert(contentsOf: nodes, at: index)

        // post update
        nodes.forEach { $0.parent = self }
        _onContentChange(delta: nodes.reduce(.init()) { $0 + $1.summary })
    }

    public final func removeChild(at index: Int) {
        let removed = _children.remove(at: index)

        // post update
        removed.parent = nil
        _onContentChange(delta: -removed.summary)
    }

    public final func removeSubrange(_ range: Range<Int>) {
        // pre update
        var summary: Summary = .init()
        for i in range {
            summary += _children[i].summary
            _children[i].parent = nil
        }
        _onContentChange(delta: -summary)

        // perform remove
        _children.removeSubrange(range)
    }

    override func _onContentChange(delta: Summary) {
        _length += delta.length
        _nsLength += delta.nsLength
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
