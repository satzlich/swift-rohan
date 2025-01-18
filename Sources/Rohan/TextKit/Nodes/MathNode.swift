// Copyright 2024-2025 Lie Yan

public class MathNode: Node {
    // MARK: - Components

    /** Returns an ordered list of the node's components. */
    internal func enumerateComponents() -> [(index: MathIndex, content: ContentNode)] {
        preconditionFailure()
    }

    /** Returns an ordered list of the node's components. */
    @inline(__always)
    internal final func getComponents() -> [ContentNode] {
        enumerateComponents().map(\.content)
    }

    // MARK: - Layout

    @inline(__always)
    override final var isDirty: Bool { getComponents().contains(where: \.isDirty) }

    // MARK: - Location and Length

    @inline(__always)
    override final var length: Int { getComponents().reduce(0) { $0 + $1.length } }

    override final func _childIndex(
        for offset: Int,
        _ affinity: SelectionAffinity
    ) -> (index: RohanIndex, offset: Int)? {
        precondition(offset >= 0 && offset <= length)

        let components = enumerateComponents()
        func index(_ i: Int) -> RohanIndex { .mathIndex(components[i].index) }

        var s = 0
        // invariant: s = sum { length | 0 ..< i }
        for (i, (_, node)) in components.enumerated() {
            let n = s + node.length
            if n < offset { // make progress
                s = n
            }
            else if n == offset,
                    affinity == .downstream,
                    i + 1 < components.count
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
        let components = enumerateComponents()
        guard let index = index.mathIndex(),
              let i = components.firstIndex(where: { $0.index == index })
        else { return nil }
        return components[i].content
    }

    override final func _length(before index: RohanIndex) -> Int {
        let components = enumerateComponents()
        guard let index = index.mathIndex(),
              let i = components.firstIndex(where: { $0.index == index })
        else { fatalError("invalid index") }
        return components[..<i].reduce(0) { $0 + $1.content.length }
    }
}

public final class EquationNode: MathNode {
    override class var nodeType: NodeType { .equation }

    public init(isBlock: Bool, nucleus: ContentNode = .init()) {
        self._isBlock = isBlock
        self.nucleus = nucleus
        super.init()
        self.nucleus.parent = self
    }

    internal init(deepCopyOf equationNode: EquationNode) {
        self._isBlock = equationNode._isBlock
        self.nucleus = equationNode.nucleus.deepCopy()
        super.init()
        nucleus.parent = self
    }

    // MARK: - Layout

    private let _isBlock: Bool
    override public var isBlock: Bool { _isBlock }

    override func performLayout(_ context: RhLayoutContext, fromScratch: Bool) {
        // TODO: layout
        if fromScratch {
            context.insert(text: TextNode("$"))
        }
        else {
            context.skipBackwards(1)
        }
    }

    // MARK: - Components

    public let nucleus: ContentNode

    @inline(__always)
    override func enumerateComponents() -> [(index: MathIndex, content: ContentNode)] {
        [(MathIndex.nucleus, nucleus)]
    }

    // MARK: - Length

    override var nsLength: Int { 1 }

    override func _onContentChange(delta: _Summary, inContentStorage: Bool) {
        // change to nsLength is not propagated
        super._onContentChange(delta: delta.with(nsLength: 0),
                               inContentStorage: inContentStorage)
    }

    // MARK: - Clone and Visitor

    override public func deepCopy() -> Self { Self(deepCopyOf: self) }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(equation: self, context)
    }
}
