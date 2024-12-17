// Copyright 2024 Lie Yan

import Collections
import Foundation

/*

 ## Data Model

 - Node category
    - TextNode
    - ElementNode(children)
    - MathNode(components)

 - ElementNode:
    - RootNode
    - ContentNode
    - EmphasisNode
    - HeadingNode(level)
    - ParagraphNode

 - MathNode:
    - EquationNode(isBlock, mathList)
    - ScriptsNode( subScript ∨ superScript )
    - FractionNode(numerator, denominator)
    - MatrixNode(rows)
        - MatrixRow(elements)

 - Abstraction mechanism
    - ApplyNode(templateName)
        - children (immutable nodes and mutable uses of arguments)
    - VariableNode(index, content)
 */

class Node {
    private(set) var isMutable: Bool

    init(isMutable: Bool = true) {
        self.isMutable = isMutable
    }

    func setMutable(_ isMutable: Bool) {
        self.isMutable = isMutable
    }

    func getPropertyDict(with styles: StyleSheet) -> PropertyDict {
        PropertyDict()
    }

    final var type: NodeType {
        Self.type
    }

    class var type: NodeType {
        .unknown
    }
}

final class TextNode: Node {
    var string: String

    init(_ string: String = "") {
        self.string = string
        super.init()
    }

    override final class var type: NodeType {
        .text
    }
}
