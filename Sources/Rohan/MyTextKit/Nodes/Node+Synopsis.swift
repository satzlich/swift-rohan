// Copyright 2024-2025 Lie Yan

import Foundation

extension Node {
    func synopsis() -> String {
        accept(NodeSynopsisVisitor(), ())
    }

    func lengthSummary() -> HomoTree<Int> {
        accept(NodeLengthSummaryVisitor(), ())
    }
}

private final class NodeSynopsisVisitor: NodeVisitor<String, Void> {
    override func visitNode(_ node: Node, _ context: Void) -> String {
        if let element = node as? ElementNode {
            return (0 ..< element.childCount())
                .map { element.getChild($0, ensureUnique: false).accept(self, context) }
                .joined(separator: "|")
        }
        preconditionFailure("overriding required for \(type(of: node))")
    }

    override func visit(text: TextNode, _ context: Void) -> String {
        text.string
    }

    override func visit(equation: EquationNode, _ context: Void) -> String {
        equation.nucleus.accept(self, context)
    }
}

private final class NodeLengthSummaryVisitor: NodeVisitor<HomoTree<Int>, Void> {
    override func visitNode(_ node: Node, _ context: Void) -> HomoTree<Int> {
        if let element = node as? ElementNode {
            let children = (0 ..< element.childCount())
                .map { element.getChild($0, ensureUnique: false).accept(self, context) }
            return .Node(element.length, children)
        }
        preconditionFailure("overriding required for \(type(of: node))")
    }

    override func visit(text: TextNode, _ context: Void) -> HomoTree<Int> {
        .Leaf(text.string.count)
    }

    override func visit(equation: EquationNode, _ context: Void) -> HomoTree<Int> {
        let nucleus = equation.nucleus.accept(self, context)
        return .Node(nucleus.value, [nucleus])
    }
}
