// Copyright 2024-2025 Lie Yan

import Foundation

class NodeVisitor<R, C> {
    public func visitNode(_ node: Node, _ context: C) -> R {
        preconditionFailure("Must be overridden")
    }

    /// text
    public func visit(text: TextNode, _ context: C) -> R {
        visitNode(text, context)
    }

    /// root
    public func visit(root: RootNode, _ context: C) -> R {
        visitNode(root, context)
    }

    /// paragraph
    public func visit(paragraph: ParagraphNode, _ context: C) -> R {
        visitNode(paragraph, context)
    }

    /// heading
    public func visit(heading: HeadingNode, _ context: C) -> R {
        visitNode(heading, context)
    }

    /// emphasis
    public func visit(emphasis: EmphasisNode, _ context: C) -> R {
        visitNode(emphasis, context)
    }

    /// content
    public func visit(content: ContentNode, _ context: C) -> R {
        visitNode(content, context)
    }

    /// equation
    public func visit(equation: EquationNode, _ context: C) -> R {
        visitNode(equation, context)
    }
}
