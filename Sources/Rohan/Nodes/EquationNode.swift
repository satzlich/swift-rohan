// Copyright 2024-2025 Lie Yan

public class MathNode: Node {
    internal func components() -> [(index: MathIndex, content: ContentNode)] {
        preconditionFailure()
    }

    override final func _locate(
        _ offset: Int,
        _ context: inout [RohanIndex],
        preferEnd: Bool
    ) -> Int {
        precondition(offset >= 0 && offset <= length)
        var current = 0
        let components = components()
        for (i, (index, node)) in components.enumerated() {
            let n = current + node.length
            if n < offset { current = n }
            else {
                if n == offset, !preferEnd, i + 1 < components.count {
                    context.append(.mathIndex(components[i + 1].index))
                    return components[i + 1].content._locate(0, &context,
                                                             preferEnd: preferEnd)
                }
                context.append(.mathIndex(index))
                return node._locate(offset - current, &context, preferEnd: preferEnd)
            }
        }
        assert(current == 0)
        return offset
    }

    override final func _offset(_ path: ArraySlice<RohanIndex>, _ acc: inout Int) {
        // take the first index
        guard let first = path.first else { return }
        guard let index = first.mathIndex() else { preconditionFailure() }
        // sum up the length before the index
        let components = self.components()
        guard let i = components.firstIndex(where: { $0.index == index })
        else { preconditionFailure() }
        acc += components[..<i].reduce(0) { $0 + $1.content.length }
        // recurse
        components[i].content._offset(path.dropFirst(), &acc)
    }
}

public final class EquationNode: MathNode {
    public let nucleus: ContentNode
    override public var isBlock: Bool { _isBlock }

    private let _isBlock: Bool
    override var length: Int { nucleus.length }
    override var nsLength: Int { 1 }

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

    override func components() -> [(index: MathIndex, content: ContentNode)] {
        [(MathIndex.nucleus, nucleus)]
    }

    override public func copy() -> Self { Self(self) }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(equation: self, context)
    }
}
