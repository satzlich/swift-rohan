// Copyright 2024-2025 Lie Yan

import Foundation

final class NodeSynopsisVisitor: NodeVisitor<String, Void> {
    let version: VersionId?

    public init(version: VersionId? = nil) {
        self.version = version
    }

    override func visitNode(_ node: Node, _ context: Void) -> String {
        if let element = node as? ElementNode {
            var synopsis: [String] = []

            let version = version ?? node.subtreeVersion

            for i in 0 ..< element.childCount(version) {
                synopsis.append(element.getChild(i, version).accept(self, context))
            }

            return synopsis.joined(separator: "|")
        }
        return ""
    }

    override func visit(text: TextNode, _ context: Void) -> String {
        text.getString()
    }

    override func visit(equation: EquationNode, _ context: Void) -> String {
        equation.nucleus.accept(self, context)
    }
}
