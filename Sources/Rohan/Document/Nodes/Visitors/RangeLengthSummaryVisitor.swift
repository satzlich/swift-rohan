// Copyright 2024-2025 Lie Yan

import Foundation

final class RangeLengthSummaryVisitor: NodeVisitor<HomoTree<Int>, Void> {
    let version: VersionId?

    public init(version: VersionId? = nil) {
        self.version = version
    }

    override func visitNode(_ node: Node, _ context: Void) -> HomoTree<Int> {
        let version = version ?? node.subtreeVersion

        if let element = node as? ElementNode {
            var children: [HomoTree<Int>] = []
            for i in 0 ..< element.childCount(version) {
                children.append(element.getChild(i, version).accept(self, context))
            }
            let total = element.rangeLength(for: version)
            return .Node(total, children)
        }
        return .Leaf(node.rangeLength(for: version))
    }

    override func visit(equation: EquationNode, _ context: Void) -> HomoTree<Int> {
        let node = equation.rangeLength(for: version ?? equation.subtreeVersion)
        let nucleus = equation.nucleus.accept(self, context)

        return .Node(node, [nucleus])
    }
}
