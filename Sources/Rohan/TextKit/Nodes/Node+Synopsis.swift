// Copyright 2024-2025 Lie Yan

import Foundation

extension Node {
    final func flatSynopsis() -> String {
        accept(FlatSynopsisVisitor(), ())
    }

    final func textSynopsis() -> String {
        accept(TextSynopsisVisitor(), ()).description
    }

    final func layoutLengthSynopsis() -> String {
        accept(NodeTreeVisitor(\.layoutLength), ()).description
    }

    final func lengthSynopsis() -> String {
        accept(NodeTreeVisitor(\.length), ()).description
    }

    final func intrinsicLengthSynopsis() -> String {
        accept(NodeTreeVisitor(\.intrinsicLength), ()).description
    }

    final func extrinsicLengthSynopsis() -> String {
        accept(NodeTreeVisitor(\.extrinsicLength), ()).description
    }
}

private final class FlatSynopsisVisitor: NodeVisitor<String, Void> {
    override func visitNode(_ node: Node, _ context: Void) -> String {
        if let element = node as? ElementNode {
            return (0 ..< element.childCount())
                .map { element.getChild($0).accept(self, context) }
                .joined(separator: "ꞈ")
        }
        else if let math = node as? MathNode {
            return math.enumerateComponents()
                .map { $0.content.accept(self, context) }
                .joined(separator: "ꞈ")
        }

        preconditionFailure("overriding required")
    }

    override func visit(text: TextNode, _ context: Void) -> String {
        text.getString()
    }

    override func visit(linebreak: LinebreakNode, _ context: Void) -> String {
        "⏎"
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
        else if let math = node as? MathNode {
            let children = math.enumerateComponents()
                .map { $0.content.accept(self, context) }
            return .Node(children)
        }
        preconditionFailure("overriding required")
    }

    override func visit(text: TextNode, _ context: Void) -> _Rope<String> {
        .Leaf(text.getString())
    }

    override func visit(linebreak: LinebreakNode, _ context: Void) -> _Rope<String> {
        .Leaf("⏎")
    }
}

private final class NodeTreeVisitor<T>: NodeVisitor<Tree<T>, Void> {
    private let eval: (Node) -> T

    init(_ eval: @escaping (Node) -> T) {
        self.eval = eval
    }

    override func visitNode(_ node: Node, _ context: Void) -> Tree<T> {
        if let element = node as? ElementNode {
            let children = (0 ..< element.childCount())
                .map { element.getChild($0).accept(self, context) }
            return .Node(eval(element), children)
        }
        else if let math = node as? MathNode {
            let children = math.enumerateComponents()
                .map { $0.content.accept(self, context) }
            return .Node(eval(math), children)
        }
        fatalError("overriding required for \(type(of: node))")
    }

    override func visit(text: TextNode, _ context: Void) -> Tree<T> {
        .Leaf(eval(text))
    }

    override func visit(linebreak: LinebreakNode, _ context: Void) -> Tree<T> {
        .Leaf(eval(linebreak))
    }
}
