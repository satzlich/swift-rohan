// Copyright 2024 Lie Yan

import Foundation

/*

 TextNode

 ElementNode
 [
    The selection and an element can intersect partially.
    All kinds of elements can be laid-out uniformly once children are processed.
 ]
    - RootNode
    - HeadingNode
    - ParagraphNode(level)

 MathNode
    - EquationNode(isBlock, mathList)

    - ScriptsNode(subscript?, superscript?)
    - FractionNode(numerator, denominator)
    - MatrixNode(rows)
        - MatrixRow(elements)

 (Template)
    - ApplyNode(templateName, arguments)
    - VariableNode(name)

 */

class Node {
    final var type: NodeType {
        Self.getType()
    }

    weak var parent: Node?

    class func getType() -> NodeType {
        .unknown
    }
}

final class TextNode: Node {
    var text: String

    override final class func getType() -> NodeType {
        .text
    }

    init(_ text: String) {
        self.text = text
        super.init()
    }
}

/**
 Essentailly a list of nodes
 */
class Content {
    private var elements: [Node]
    var direction: Direction?

    convenience init() {
        self.init([])
    }

    init(_ elements: [Node]) {
        self.elements = elements
    }

    subscript(index: Int) -> Node {
        elements[index]
    }

    var count: Int {
        elements.count
    }
}

class ElementNode: Node {
    var children: [Node]
    var direction: Direction?

    override convenience init() {
        self.init([])
    }

    init(_ children: [Node]) {
        self.children = children
    }

    func isInline() -> Bool {
        false
    }
}

class MathNode: Node {
    override class func getType() -> NodeType {
        .unknown
    }
}

final class RootNode: ElementNode {
    override final class func getType() -> NodeType {
        .root
    }
}

final class ParagraphNode: ElementNode {
    override final class func getType() -> NodeType {
        .paragraph
    }
}

final class HeadingNode: ElementNode {
    let level: Int

    override final class func getType() -> NodeType {
        .heading
    }

    init(level: Int, _ children: [Node]) {
        self.level = level
        super.init(children)
    }
}

final class EmphasisNode: ElementNode {
    override final class func getType() -> NodeType {
        .emphasis
    }
}

final class EquationNode: MathNode {
    private(set) var isBlock: Bool
    var mathList: Content

    init(isBlock: Bool, _ mathList: Content) {
        self.isBlock = isBlock
        self.mathList = mathList
    }

    convenience init(isBlock: Bool, _ mathList: [Node]) {
        self.init(isBlock: isBlock, Content(mathList))
    }

    override final class func getType() -> NodeType {
        .equation
    }
}

final class ScriptsNode: MathNode {
    var `subscript`: Content?
    var superscript: Content?

    init(subscript: Content) {
        self.subscript = `subscript`
    }

    init(superscript: Content) {
        self.superscript = superscript
    }

    init(subscript: Content, superscript: Content) {
        self.subscript = `subscript`
        self.superscript = superscript
    }

    convenience init(subscript: [Node]) {
        self.init(subscript: Content(`subscript`))
    }

    convenience init(superscript: [Node]) {
        self.init(superscript: Content(superscript))
    }

    convenience init(subscript: [Node], superscript: [Node]) {
        self.init(subscript: Content(`subscript`),
                  superscript: Content(superscript))
    }

    override final class func getType() -> NodeType {
        .scripts
    }
}

final class FractionNode: MathNode {
    let numerator: Content
    let denominator: Content

    init(numerator: Content, denominator: Content) {
        self.numerator = numerator
        self.denominator = denominator
    }

    convenience init(numerator: [Node], denominator: [Node]) {
        self.init(numerator: Content(numerator),
                  denominator: Content(denominator))
    }

    override final class func getType() -> NodeType {
        .fraction
    }
}

final class MatrixNode: MathNode {
    struct MatrixRow {
        private var elements: [Content]

        init(_ elements: [Content]) {
            self.elements = elements
        }

        init(_ elements: [[Node]]) {
            self.init(elements.map { Content($0) })
        }

        var count: Int {
            elements.count
        }

        subscript(index: Int) -> Content {
            elements[index]
        }
    }

    var rows: [MatrixRow]

    init(_ rows: [MatrixRow]) {
        self.rows = rows
    }

    convenience init(_ rows: [[[Node]]]) {
        self.init(rows.map { MatrixRow($0) })
    }

    override final class func getType() -> NodeType {
        .matrix
    }
}

// MARK: - Apply

final class ApplyNode: Node {
    var templateName: String
    var arguments: [Content]

    init(_ templateName: String, arguments: [Content] = []) {
        self.templateName = templateName
        self.arguments = arguments
    }

    override class func getType() -> NodeType {
        .apply
    }
}

// MARK: - Variable

final class VariableNode: Node {
    let name: String

    init(_ name: String) {
        self.name = name
    }

    override class func getType() -> NodeType {
        .variable
    }
}
