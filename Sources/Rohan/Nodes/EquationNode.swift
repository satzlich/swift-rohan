// Copyright 2024-2025 Lie Yan

public class MathNode: Node {
    // MARK: - Components

    /**
     Returns an ordered list of the node's components.

     - Warning: Reference uniqueness is not guaranteed.
     */
    internal func getComponents() -> [(index: MathIndex, content: ContentNode)] {
        preconditionFailure()
    }

    // MARK: - Location and Length

    override final func _childIndex(
        for offset: Int,
        _ affinity: SelectionAffinity
    ) -> (index: RohanIndex, offset: Int)? {
        precondition(offset >= 0 && offset <= length)

        let components = getComponents()
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
        let components = getComponents()
        guard let index = index.mathIndex(),
              let i = components.firstIndex(where: { $0.index == index })
        else { return nil }
        return components[i].content
    }

    override final func _length(before index: RohanIndex) -> Int {
        let components = getComponents()
        guard let index = index.mathIndex(),
              let i = components.firstIndex(where: { $0.index == index })
        else { fatalError("invalid index") }
        return components[..<i].reduce(0) { $0 + $1.content.length }
    }
}

public final class EquationNode: MathNode {
    override class var nodeType: NodeType { .equation }

    init(isBlock: Bool, nucleus: ContentNode = .init()) {
        self._isBlock = isBlock
        self.nucleus = nucleus
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

    // MARK: - Components

    public let nucleus: ContentNode

    override func getComponents() -> [(index: MathIndex, content: ContentNode)] {
        [(MathIndex.nucleus, nucleus)]
    }

    // MARK: - Layout

    override public var isBlock: Bool { _isBlock }
    private let _isBlock: Bool

    // MARK: - Length

    override var length: Int { nucleus.length }
    override var nsLength: Int { 1 }

    override func _onContentChange(delta: _Summary) {
        // no change to nsLength as equation is a special case
        super._onContentChange(delta: delta.with(nsLength: 0))
    }

    // MARK: - Clone and Visitor

    override public func copy() -> Self { Self(self) }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(equation: self, context)
    }
}
