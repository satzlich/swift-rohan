// Copyright 2024-2025 Lie Yan

import Foundation

/**
 ElementNode
 |---children: [Node]
 |---postamble: String
 */
public class ElementNode: Node {
    private final var children: VersionedArray<Node>
    var postamble: String { "" }

    init(_ children: [Node], _ version: VersionId = .defaultInitial) {
        self.children = VersionedArray(children, version)

        super.init(version)

        for i in 0 ..< children.count {
            children[i]._parent = self
        }
    }

    final func _cloneChildren(from version: VersionId) -> [Node] {
        let count = self.children.count(version)

        var children: [Node] = []
        children.reserveCapacity(count)
        for i in 0 ..< count {
            children.append(self.children.at(i, version).clone(from: version))
        }
        return children
    }

    // children

    public final func childCount(_ version: VersionId) -> Int {
        children.count(version)
    }

    public final func childCount() -> Int {
        children.count()
    }

    public final func getChild(_ i: Int, _ version: VersionId) -> Node {
        children.at(i, version)
    }

    public final func getChild(_ i: Int) -> Node {
        children.at(i)
    }

    public final func insertChild(_ node: Node, at i: Int) {
        precondition(isEditing == true)
        children.insert(node, at: i)
        node._parent = self
    }

    @discardableResult
    public final func removeChild(at i: Int) -> Node {
        precondition(isEditing == true)
        let removed = children.remove(at: i)

        return removed
    }

    public final func removeSubrange(_ range: Range<Int>) {
        precondition(isEditing == true)

        // do remove
        children.removeSubrange(range)
    }

    // versions

    override func _advanceVersion(to target: VersionId) {
        super._advanceVersion(to: target)
        children.advanceVersion(to: target)
    }

    override public func dropVersions(through target: VersionId, recursive: Bool) {
        if target >= subtreeVersion { return }

        super.dropVersions(through: target, recursive: recursive)
        children.dropVersions(through: target)

        if recursive {
            // drop versions of children
            for i in 0 ..< children.count() {
                children.at(i).dropVersions(through: target, recursive: true)
            }
        }
    }
}

public final class RootNode: ElementNode {
    override public func clone(from version: VersionId) -> RootNode {
        RootNode(_cloneChildren(from: version))
    }

    override class var type: NodeType { .root }

    override public func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(root: self, context)
    }
}

public final class ParagraphNode: ElementNode {
    override var postamble: String { "\n" }

    override public func clone(from version: VersionId) -> ParagraphNode {
        ParagraphNode(_cloneChildren(from: version))
    }

    override class var type: NodeType { .paragraph }

    override public func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(paragraph: self, context)
    }
}

public final class HeadingNode: ElementNode {
    private var level: Int

    override var postamble: String { "\n" }

    init(level: Int, _ children: [Node], _ version: VersionId = .defaultInitial) {
        self.level = level
        super.init(children, version)
    }

    override public func clone(from version: VersionId) -> HeadingNode {
        HeadingNode(level: level, _cloneChildren(from: version))
    }

    public func getLevel() -> Int { level }

    override public func selector() -> TargetSelector {
        Heading.selector(level: level)
    }

    override class var type: NodeType { .heading }

    override public func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(heading: self, context)
    }
}

public final class ContentNode: ElementNode {
    override public func clone(from version: VersionId) -> ContentNode {
        ContentNode(_cloneChildren(from: version))
    }

    override class var type: NodeType { .content }

    override public func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(content: self, context)
    }
}
