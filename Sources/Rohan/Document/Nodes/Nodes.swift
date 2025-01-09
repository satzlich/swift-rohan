// Copyright 2024-2025 Lie Yan

import Foundation

/*

 ## Data Model

 - Node category
    - TextNode
    - ElementNode(children)
    - MathNode(components)

 - ElementNode:
    - RootNode
    - ContentNode
    - EmphasisNode
    - HeadingNode(level)
    - ParagraphNode

 - MathNode:
    - EquationNode(isBlock, nucleus)
    - ScriptsNode( subScript ∨ superScript )
    - FractionNode(numerator, denominator)
    - MatrixNode(rows)
        - MatrixRow(elements)

 - Abstraction mechanism
    - ApplyNode(templateName)
        - children (immutable nodes and mutable uses of arguments)
    - NamelessVariableNode(index, content)
 */

final class TextNode: Node {
    private var string: VersionedValue<String>

    init(_ string: String, _ version: VersionId = .defaultInitial) {
        self.string = .init(string, version)
        super.init(version)
    }

    public func getString(for version: VersionId) -> String {
        string.get(version)
    }

    public func getString() -> String {
        string.get()
    }

    override func clone() -> TextNode {
        TextNode(string.get())
    }

    override func rangeLength(for version: VersionId) -> Int {
        string.get(version).count
    }

    override func localChanged(_ version: VersionId) -> Bool {
        string.isChanged(version)
    }

    override func _advanceVersion(to target: VersionId) {
        super._advanceVersion(to: target)
        string.advanceVersion(to: target)
    }

    override func dropVersions(through target: VersionId, recursive: Bool) {
        super.dropVersions(through: target, recursive: recursive)
        string.dropVersions(through: target)
    }

    override class var type: NodeType {
        .text
    }

    override public func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(text: self, context)
    }
}

class ElementNode: Node {
    private var children: VersionedArray<Node>
    private var _rangeLength: VersionedValue<Int>

    init(_ children: [Node], _ version: VersionId = .defaultInitial) {
        self._rangeLength = .init(children.map { $0.rangeLength() }.reduce(0, +),
                                  version)
        self.children = VersionedArray(children, version)

        super.init(version)

        for i in 0 ..< children.count {
            children[i]._parent = self
        }
    }

    func _cloneChildren() -> [Node] {
        let count = self.children.count()

        var children: [Node] = []
        children.reserveCapacity(count)
        for i in 0 ..< count {
            children.append(self.children.at(i).clone())
        }
        return children
    }

    override public func clone() -> ElementNode {
        preconditionFailure()
    }

    override public final func rangeLength(for version: VersionId) -> Int {
        _rangeLength.get(version)
    }

    override final func _propagateRangeLengthChanged(_ delta: Int) {
        _rangeLength.set(_rangeLength.get() + delta)
        super._propagateRangeLengthChanged(delta)
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

        // update range length
        _propagateRangeLengthChanged(node.rangeLength())
    }

    public final func removeChild(at i: Int) {
        precondition(isEditing == true)
        let removed = children.remove(at: i)

        // update range length
        _propagateRangeLengthChanged(-removed.rangeLength())
    }

    public final func removeSubrange(_ range: Range<Int>) {
        precondition(isEditing == true)

        // calculate range length
        let rangeLength = range.reduce(0) {
            (acc, i) in acc + children.at(i).rangeLength()
        }

        // do remove
        children.removeSubrange(range)

        // update range length
        _propagateRangeLengthChanged(-rangeLength)
    }

    // versions

    override func _advanceVersion(to target: VersionId) {
        super._advanceVersion(to: target)
        children.advanceVersion(to: target)
        _rangeLength.advanceVersion(to: target)
    }

    override func dropVersions(through target: VersionId, recursive: Bool) {
        if target >= subtreeVersion { return }

        super.dropVersions(through: target, recursive: recursive)
        children.dropVersions(through: target)
        _rangeLength.dropVersions(through: target)

        if recursive {
            // drop versions of children
            for i in 0 ..< children.count() {
                children.at(i).dropVersions(through: target, recursive: true)
            }
        }
    }
}

final class RootNode: ElementNode {
    override public func clone() -> RootNode {
        RootNode(_cloneChildren())
    }

    override class var type: NodeType {
        .root
    }

    override public func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(root: self, context)
    }
}

final class ParagraphNode: ElementNode {
    override public func clone() -> ParagraphNode {
        ParagraphNode(_cloneChildren())
    }

    override class var type: NodeType {
        .paragraph
    }

    override public func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(paragraph: self, context)
    }
}

final class HeadingNode: ElementNode {
    private var level: Int

    init(level: Int, _ children: [Node], _ version: VersionId = .defaultInitial) {
        self.level = level
        super.init(children, version)
    }

    override public func clone() -> HeadingNode {
        HeadingNode(level: level, _cloneChildren())
    }

    public func getLevel() -> Int {
        level
    }

    override class var type: NodeType {
        .heading
    }

    override public func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(heading: self, context)
    }
}

final class EmphasisNode: ElementNode {
    override public func clone() -> EmphasisNode {
        EmphasisNode(_cloneChildren())
    }

    override class var type: NodeType {
        .emphasis
    }

    override public func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(emphasis: self, context)
    }
}

final class ContentNode: ElementNode {
    override public func clone() -> ContentNode {
        ContentNode(_cloneChildren())
    }

    override class var type: NodeType {
        .content
    }

    override public func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(content: self, context)
    }
}

final class EquationNode: Node {
    private var _isBlock: Bool
    private(set) var nucleus: ContentNode

    init(isBlock: Bool,
         nucleus: ContentNode,
         _ version: VersionId = .defaultInitial)
    {
        self._isBlock = isBlock
        self.nucleus = nucleus
        super.init(version)

        nucleus._parent = self
    }

    override public func clone() -> EquationNode {
        EquationNode(isBlock: _isBlock, nucleus: nucleus.clone())
    }

    override final func rangeLength(for version: VersionId) -> Int {
        // one for attachment character
        return 1
    }

    override final func _propagateRangeLengthChanged(_ delta: Int) {
        // do nothing
    }

    public func isBlock() -> Bool {
        _isBlock
    }

    override public func dropVersions(through target: VersionId,
                                      recursive: Bool = true)
    {
        if target >= subtreeVersion { return }

        super.dropVersions(through: target, recursive: recursive)
        if recursive {
            nucleus.dropVersions(through: target, recursive: true)
        }
    }

    override class var type: NodeType {
        .equation
    }

    override public func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(equation: self, context)
    }
}
