// Copyright 2024-2025 Lie Yan

class SimpleNodeVisitor<C>: NodeVisitor<Void, C> {
    @usableFromInline
    final func _visitChildren(of node: ElementNode, _ context: C) {
        for i in 0 ..< node.childCount() {
            node.getChild(i).accept(self, context)
        }
    }

    final func _visitComponents(of node: MathNode, _ context: C) {
        node.getComponents().forEach { $0.content.accept(self, context) }
    }

    override public func visitNode(_ node: Node, _ context: C) {
        // do nothing
    }

    override public func visit(text: TextNode, _ context: C) {
        visitNode(text, context)
    }

    override public func visit(root: RootNode, _ context: C) {
        visitNode(root, context)
        _visitChildren(of: root, context)
    }

    override public func visit(paragraph: ParagraphNode, _ context: C) {
        visitNode(paragraph, context)
        _visitChildren(of: paragraph, context)
    }

    override public func visit(heading: HeadingNode, _ context: C) {
        visitNode(heading, context)
        _visitChildren(of: heading, context)
    }

    override public func visit(emphasis: EmphasisNode, _ context: C) {
        visitNode(emphasis, context)
        _visitChildren(of: emphasis, context)
    }

    override public func visit(content: ContentNode, _ context: C) {
        visitNode(content, context)
        _visitChildren(of: content, context)
    }

    override public func visit(equation: EquationNode, _ context: C) {
        visitNode(equation, context)
        _visitComponents(of: equation, context)
    }

    override func visit(textMode: TextModeNode, _ context: C) {
        visitNode(textMode, context)
        _visitChildren(of: textMode, context)
    }
}
