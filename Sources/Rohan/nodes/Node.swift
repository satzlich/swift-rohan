// Copyright 2024 Lie Yan

import Foundation

/*

 # Data Model

 - Node
    - node type
    - node key
    - properties
    - constituents: children | components

 - Node category
    - TextNode
    - GenElement
        - ElementNode(children)
        - ApplyNode(templateName, arguments: [ContentNode])
        - VariableValueNode
    - MathNode(components)
    - VariableNode(name)

 - ElementNode:
    - RootNode
    - ContentNode
    - EmphasisNode
    - HeadingNode(level)
    - ParagraphNode

 - MathNode:
    - EquationNode(isBlock, mathList)
    - ScriptsNode( subscript ∨ superscript )
    - FractionNode(numerator, denominator)
    - MatrixNode(rows)
        - MatrixRow(elements)
 */

class Node {
    final var type: NodeType {
        Self.getType()
    }

    func getExported(styles: StyleSheet) -> PropertyDict {
        PropertyDict()
    }

    class func getType() -> NodeType {
        .unknown
    }
}

// MARK: - TextNode

final class TextNode: Node {
    var text: String

    init(_ text: String = "") {
        self.text = text
        super.init()
    }

    override final class func getType() -> NodeType {
        .text
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

    convenience init(_ children: Node ...) {
        self.init(children)
    }

    var isInline: Bool {
        false
    }
}

// MARK: - ContentNode

/**
 A minimalist element.
 */
final class ContentNode: ElementNode, GenericElement {
    override var isInline: Bool {
        false
    }

    override class func getType() -> NodeType {
        .content
    }
}

// MARK: - MathNode

class MathNode: Node {
    var components: [ContentNode] {
        preconditionFailure()
    }
}

// MARK: - ApplyNode

final class ApplyNode: Node, GenericElement {
    var templateName: String
    var arguments: [ContentNode]

    init(_ templateName: String, arguments: [ContentNode]) {
        self.templateName = templateName
        self.arguments = arguments

        super.init()
    }

    convenience init(_ templateName: String, arguments: [Node] ...) {
        self.init(templateName, arguments: arguments.map { ContentNode($0) })
    }

    var children: [Node] {
        preconditionFailure("not implemented")
    }

    var isInline: Bool {
        true
    }

    override class func getType() -> NodeType {
        .apply
    }
}

// MARK: - VariableNode

/**
 Reference to variable used in template definition.
 */
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

    /**
     Returns extrinsic properties
     */
    override func getExported(styles: StyleSheet) -> PropertyDict {
        let selector = Selector(nodeType: .heading,
                                matches: (.level, .integer(level)))
        return styles.getProperties(selector) ?? PropertyDict()
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
    var mathList: ContentNode

    init(isBlock: Bool, _ mathList: ContentNode) {
        self.isBlock = isBlock
        self.mathList = mathList

        super.init()
    }

    convenience init(isBlock: Bool, _ mathList: [Node]) {
        self.init(isBlock: isBlock, ContentNode(mathList))
    }

    override final var components: [ContentNode] {
        [mathList]
    }

    override final class func getType() -> NodeType {
        .equation
    }
}

final class ScriptsNode: MathNode {
    var `subscript`: ContentNode?
    var superscript: ContentNode?

    init(subscript: ContentNode) {
        self.subscript = `subscript`

        super.init()
    }

    init(superscript: ContentNode) {
        self.superscript = superscript

        super.init()
    }

    init(subscript: ContentNode, superscript: ContentNode) {
        self.subscript = `subscript`
        self.superscript = superscript

        super.init()
    }

    convenience init(subscript: Node ...) {
        self.init(subscript: ContentNode(`subscript`))
    }

    convenience init(superscript: Node ...) {
        self.init(superscript: ContentNode(superscript))
    }

    convenience init(subscript: Node ..., superscript: Node ...) {
        self.init(subscript: ContentNode(`subscript`),
                  superscript: ContentNode(superscript))
    }

    override final var components: [ContentNode] {
        var components = [ContentNode]()
        if let `subscript` = `subscript` {
            components.append(`subscript`)
        }
        if let superscript = superscript {
            components.append(superscript)
        }
        return components
    }

    override final class func getType() -> NodeType {
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

    convenience init(numerator: Node ..., denominator: Node ...) {
        self.init(numerator: ContentNode(numerator),
                  denominator: ContentNode(denominator))
    }

    override final var components: [ContentNode] {
        [numerator, denominator]
    }

    override final class func getType() -> NodeType {
        .fraction
    }
}

final class MatrixNode: MathNode {
    struct MatrixRow {
        var elements: [ContentNode]

        init(_ elements: [ContentNode]) {
            self.elements = elements
        }

        init(_ elements: [[Node]]) {
            self.init(elements.map { ContentNode($0) })
        }

        var count: Int {
            elements.count
        }

        subscript(index: Int) -> ContentNode {
            elements[index]
        }
    }

    var rows: [MatrixRow]

    init(_ rows: [MatrixRow]) {
        self.rows = rows

        super.init()
    }

    convenience init(_ rows: [[Node]] ...) {
        self.init(rows.map { MatrixRow($0) })
    }

    override final var components: [ContentNode] {
        rows.flatMap { $0.elements }
    }

    override final class func getType() -> NodeType {
        .matrix
    }
}
