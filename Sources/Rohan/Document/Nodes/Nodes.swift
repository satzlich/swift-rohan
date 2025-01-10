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

public final class TextNode: Node {
    private var string: VersionedValue<String>

    init(_ string: String, _ version: VersionId = .defaultInitial) {
        self.string = .init(string, version)
        super.init(version)
    }

    public func getString(for version: VersionId) -> String {
        string.get(version)
    }

    public func getString() -> String {
        getString(for: nodeVersion)
    }

    override public func clone(from version: VersionId) -> TextNode {
        TextNode(getString(for: version), version)
    }

    override public func localChanged(_ version: VersionId) -> Bool {
        string.isChanged(version)
    }

    override func _advanceVersion(to target: VersionId) {
        super._advanceVersion(to: target)
        string.advanceVersion(to: target)
    }

    override public func dropVersions(through target: VersionId, recursive: Bool) {
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

public class ElementNode: Node {
    private final var children: VersionedArray<Node>

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

    override class var type: NodeType {
        .root
    }

    override public func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(root: self, context)
    }
}

public final class ParagraphNode: ElementNode {
    override public func clone(from version: VersionId) -> ParagraphNode {
        ParagraphNode(_cloneChildren(from: version))
    }

    override class var type: NodeType {
        .paragraph
    }

    override public func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(paragraph: self, context)
    }
}

public final class HeadingNode: ElementNode {
    private var level: Int

    init(level: Int, _ children: [Node], _ version: VersionId = .defaultInitial) {
        self.level = level
        super.init(children, version)
    }

    override public func clone(from version: VersionId) -> HeadingNode {
        HeadingNode(level: level, _cloneChildren(from: version))
    }

    public func getLevel() -> Int {
        level
    }

    override public func selector() -> TargetSelector {
        Heading.selector(level: level)
    }

    override class var type: NodeType {
        .heading
    }

    override public func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(heading: self, context)
    }
}

public final class EmphasisNode: ElementNode {
    override public func clone(from version: VersionId) -> EmphasisNode {
        EmphasisNode(_cloneChildren(from: version))
    }

    override class var type: NodeType {
        .emphasis
    }

    override public func getProperties(with styleSheet: StyleSheet) -> PropertyDictionary {
        if _cachedProperties == nil {
            var properties = super.getProperties(with: styleSheet)

            // obtain effective value
            let key = TextProperty.style
            let effectiveValue = properties[key] ?? styleSheet.defaultProperties[key]!

            // invert font style
            let newFontStyle = Emphasis.invert(fontStyle: effectiveValue.fontStyle()!)
            properties[key] = .fontStyle(newFontStyle)

            // update cache
            _cachedProperties = properties
        }

        return _cachedProperties!
    }

    override public func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(emphasis: self, context)
    }
}

public final class ContentNode: ElementNode {
    override public func clone(from version: VersionId) -> ContentNode {
        ContentNode(_cloneChildren(from: version))
    }

    override class var type: NodeType {
        .content
    }

    override public func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(content: self, context)
    }
}

public final class EquationNode: Node {
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

    override public func clone(from version: VersionId) -> EquationNode {
        EquationNode(isBlock: _isBlock, nucleus: nucleus.clone(from: version))
    }

    public func isBlock() -> Bool {
        _isBlock
    }

    override public func selector() -> TargetSelector {
        Equation.selector(isBlock: _isBlock)
    }

    override public func getProperties(with styleSheet: StyleSheet) -> PropertyDictionary {
        if _cachedProperties == nil {
            var properties = super.getProperties(with: styleSheet)
            properties[RootProperty.layoutMode] = .layoutMode(.math)
            _cachedProperties = properties
        }
        return _cachedProperties!
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
