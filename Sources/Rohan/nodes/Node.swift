// Copyright 2024 Lie Yan

import Foundation

/*

 - Node
     - TextNode
     - CellNode(elements)
     - ElementNode(children)
     - MathNode
     - ApplyNode(templateName, arguments)
     - VariableNode(name)

 ElementNode [
    The selection and an element can intersect partially.
    All kinds of elements can be laid-out uniformly once children are processed.
 ]:
    - RootNode
    - Emphasis
    - HeadingNode
    - ParagraphNode(level)

 MathNode:
    - EquationNode(isBlock, mathList)
    - ScriptsNode(subscript?, superscript?)
    - FractionNode(numerator, denominator)
    - MatrixNode(rows)
        - MatrixRow(elements)
 */

class Node {
    final var type: NodeType {
        Self.getType()
    }

    class func getType() -> NodeType {
        .unknown
    }
}

// MARK: - TextNode

final class TextNode: Node {
    var text: String

    override final class func getType() -> NodeType {
        .text
    }

    init(_ text: String = "") {
        self.text = text
        super.init()
    }
}

// MARK: - CellNode

/**
 A local environment for edit.
 */
class CellNode: Node {
    private var elements: [Node]
    var direction: Direction?

    init(_ elements: [Node] = []) {
        self.elements = elements

        super.init()
    }

    subscript(index: Int) -> Node {
        elements[index]
    }

    var count: Int {
        elements.count
    }
}

// MARK: - ElementNode

class ElementNode: Node {
    var children: [Node]
    var direction: Direction?

    init(_ children: [Node]) {
        self.children = children

        super.init()
    }

    func isInline() -> Bool {
        false
    }
}

// MARK: - MathNode

class MathNode: Node {
}

// MARK: - ApplyNode

final class ApplyNode: Node {
    var templateName: String
    var arguments: [CellNode]

    init(_ templateName: String, arguments: [CellNode]) {
        self.templateName = templateName
        self.arguments = arguments

        super.init()
    }

    convenience init(_ templateName: String, arguments: [[Node]] = []) {
        self.init(templateName, arguments: arguments.map { CellNode($0) })
    }

    override class func getType() -> NodeType {
        .apply
    }
}

// MARK: - VariableNode

final class VariableNode: Node {
    let name: String

    init(_ name: String) {
        self.name = name

        super.init()
    }

    override class func getType() -> NodeType {
        .variable
    }
}

// MARK: - RootNode

final class RootNode: ElementNode {
    override final class func getType() -> NodeType {
        .root
    }
}

final class EmphasisNode: ElementNode {
    override final class func getType() -> NodeType {
        .emphasis
    }
}

final class HeadingNode: ElementNode {
    /// 1 ... 5
    let level: Int

    override final class func getType() -> NodeType {
        .heading
    }

    init?(level: Int, _ children: [Node]) {
        guard HeadingNode.validateLevel(level) else {
            return nil
        }

        self.level = level
        super.init(children)
    }

    static func validateLevel(_ level: Int) -> Bool {
        (1 ... 5) ~= level
    }
}

final class ParagraphNode: ElementNode {
    override final class func getType() -> NodeType {
        .paragraph
    }
}

final class EquationNode: MathNode {
    private(set) var isBlock: Bool
    var mathList: CellNode

    init(isBlock: Bool, _ mathList: CellNode) {
        self.isBlock = isBlock
        self.mathList = mathList

        super.init()
    }

    convenience init(isBlock: Bool, _ mathList: [Node]) {
        self.init(isBlock: isBlock, CellNode(mathList))
    }

    override final class func getType() -> NodeType {
        .equation
    }
}

final class ScriptsNode: MathNode {
    var `subscript`: CellNode?
    var superscript: CellNode?

    init(subscript: CellNode) {
        self.subscript = `subscript`

        super.init()
    }

    init(superscript: CellNode) {
        self.superscript = superscript

        super.init()
    }

    init(subscript: CellNode, superscript: CellNode) {
        self.subscript = `subscript`
        self.superscript = superscript

        super.init()
    }

    convenience init(subscript: [Node]) {
        self.init(subscript: CellNode(`subscript`))
    }

    convenience init(superscript: [Node]) {
        self.init(superscript: CellNode(superscript))
    }

    convenience init(subscript: [Node], superscript: [Node]) {
        self.init(subscript: CellNode(`subscript`),
                  superscript: CellNode(superscript))
    }

    override final class func getType() -> NodeType {
        .scripts
    }
}

final class FractionNode: MathNode {
    let numerator: CellNode
    let denominator: CellNode

    init(numerator: CellNode, denominator: CellNode) {
        self.numerator = numerator
        self.denominator = denominator

        super.init()
    }

    convenience init(numerator: [Node], denominator: [Node]) {
        self.init(numerator: CellNode(numerator),
                  denominator: CellNode(denominator))
    }

    override final class func getType() -> NodeType {
        .fraction
    }
}

final class MatrixNode: MathNode {
    struct MatrixRow {
        private var elements: [CellNode]

        init(_ elements: [CellNode]) {
            self.elements = elements
        }

        init(_ elements: [[Node]]) {
            self.init(elements.map { CellNode($0) })
        }

        var count: Int {
            elements.count
        }

        subscript(index: Int) -> CellNode {
            elements[index]
        }
    }

    var rows: [MatrixRow]

    init(_ rows: [MatrixRow]) {
        self.rows = rows

        super.init()
    }

    convenience init(_ rows: [[[Node]]]) {
        self.init(rows.map { MatrixRow($0) })
    }

    override final class func getType() -> NodeType {
        .matrix
    }
}
