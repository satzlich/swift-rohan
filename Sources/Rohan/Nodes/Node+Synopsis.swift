// Copyright 2024-2025 Lie Yan

import Foundation

extension Node {
    public final func synopsis() -> String {
        accept(NodeSynopsisVisitor(), ())
    }

    final func lengthTree() -> HomoTree<Int> {
        accept(NodeValueVisitor(\.length), ())
    }

    final func nsLengthTree() -> HomoTree<Int> {
        accept(NodeValueVisitor(\.nsLength), ())
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

private final class NodeValueVisitor<T>: NodeVisitor<HomoTree<T>, Void> {
    private let f: (Node) -> T

    init(_ f: @escaping (Node) -> T) {
        self.f = f
    }

    override func visitNode(_ node: Node, _ context: Void) -> HomoTree<T> {
        if let element = node as? ElementNode {
            let children = (0 ..< element.childCount())
                .map { element.getChild($0, ensureUnique: false).accept(self, context) }
            return .Node(f(element), children)
        }
        preconditionFailure("overriding required for \(type(of: node))")
    }

    override func visit(text: TextNode, _ context: Void) -> HomoTree<T> {
        .Leaf(f(text))
    }

    override func visit(equation: EquationNode, _ context: Void) -> HomoTree<T> {
        let nucleus = equation.nucleus.accept(self, context)
        return .Node(f(equation), [nucleus])
    }
}
