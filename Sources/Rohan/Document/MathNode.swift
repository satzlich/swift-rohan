// Copyright 2024 Lie Yan

import Collections
import Foundation

/**

 - Note: EquationNode is not a MathNode.
 */
final class EquationNode: ElementNode {
    private(set) var isBlock: Bool

    init(isBlock: Bool, _ children: [Node]) {
        self.isBlock = isBlock
        super.init(children)
    }

    override final class var type: NodeType {
        .equation
    }
}

/**
 TeX calls this a "noad".
 */
class MathNode: Node { }

final class ScriptsNode: MathNode {
    var subScript: ContentNode?
    var superScript: ContentNode?

    init(subScript: ContentNode? = nil, superScript: ContentNode? = nil) {
        precondition(subScript != nil || superScript != nil)

        self.subScript = subScript
        self.superScript = superScript
        super.init()
    }

    override final class var type: NodeType {
        .scripts
    }
}

final class FractionNode: MathNode {
    let numerator: ContentNode
    let denominator: ContentNode

    init(numerator: ContentNode, denominator: ContentNode) {
        self.numerator = numerator
        self.denominator = denominator
        super.init()
    }

    override final class var type: NodeType {
        .fraction
    }
}

final class MatrixNode: MathNode {
    struct MatrixRow {
        private var elements: [ContentNode]

        init(elements: [ContentNode]) {
            self.elements = elements
        }
    }

    private var rows: [MatrixRow]

    init(rows: [MatrixRow]) {
        self.rows = rows
        super.init()
    }

    override final class var type: NodeType {
        .matrix
    }
}
