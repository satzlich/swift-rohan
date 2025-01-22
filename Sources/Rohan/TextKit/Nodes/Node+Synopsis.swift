// Copyright 2024-2025 Lie Yan

import Foundation

extension Node {
    public final func flatSynopsis() -> String {
        accept(FlatSynopsisVisitor(), ())
    }

    final func textSynopsis() -> String {
        accept(TextSynopsisVisitor(), ()).description
    }

    final func lengthSynopsis() -> String {
        accept(NodeTreeVisitor(\.length), ()).description
    }

    final func nsLengthSynopsis() -> String {
        accept(NodeTreeVisitor(\.nsLength), ()).description
    }

    final func paddedLengthSynopsis() -> String {
        accept(NodeTreeVisitor(\.paddedLength), ()).description
    }
}

private final class FlatSynopsisVisitor: NodeVisitor<String, Void> {
    override func visitNode(_ node: Node, _ context: Void) -> String {
        if let element = node as? ElementNode {
            return (0 ..< element.childCount())
                .map { element.getChild($0).accept(self, context) }
                .joined(separator: "ꞈ")
        }
        preconditionFailure("overriding required")
    }

    override func visit(text: TextNode, _ context: Void) -> String {
        text.string
    }

    override func visit(equation: EquationNode, _ context: Void) -> String {
        equation.nucleus.accept(self, context)
    }
}

private enum _Rope<T>: CustomStringConvertible {
    case Leaf(T)
    case Node([_Rope<T>])

    var description: String {
        switch self {
        case let .Leaf(value):
            return "`\(value)`"
        case let .Node(children):
            let children = children.map(\.description).joined(separator: ", ")
            return "[\(children)]"
        }
    }
}

private final class TextSynopsisVisitor: NodeVisitor<_Rope<String>, Void> {
    override func visitNode(_ node: Node, _ context: Void) -> _Rope<String> {
        if let element = node as? ElementNode {
            let children = (0 ..< element.childCount())
                .map { element.getChild($0).accept(self, context) }
            return .Node(children)
        }
        preconditionFailure("overriding required")
    }

    override func visit(text: TextNode, _ context: Void) -> _Rope<String> {
        .Leaf(text.string)
    }

    override func visit(equation: EquationNode, _ context: Void) -> _Rope<String> {
        let nucleus = equation.nucleus.accept(self, context)
        return .Node([nucleus])
    }
}

private final class NodeTreeVisitor<T>: NodeVisitor<Tree<T>, Void> {
    private let f: (Node) -> T

    init(_ f: @escaping (Node) -> T) {
        self.f = f
    }

    override func visitNode(_ node: Node, _ context: Void) -> Tree<T> {
        if let element = node as? ElementNode {
            let children = (0 ..< element.childCount())
                .map { element.getChild($0).accept(self, context) }
            return .Node(f(element), children)
        }
        preconditionFailure("overriding required")
    }

    override func visit(text: TextNode, _ context: Void) -> Tree<T> {
        .Leaf(f(text))
    }

    override func visit(equation: EquationNode, _ context: Void) -> Tree<T> {
        let nucleus = equation.nucleus.accept(self, context)
        return .Node(f(equation), [nucleus])
    }
}
