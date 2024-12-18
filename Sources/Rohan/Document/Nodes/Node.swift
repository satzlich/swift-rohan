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
    - EquationNode(isBlock, nucleus)
    - ScriptsNode( subScript ∨ superScript )
    - FractionNode(numerator, denominator)
    - MatrixNode(rows)
        - MatrixRow(elements)

 - Abstraction mechanism
    - ApplyNode(templateName)
        - children (immutable nodes and mutable uses of arguments)
    - NamelessVariableNode(index, content)
 */

class Node {
    private(set) var key: NodeKey

    fileprivate init() {
        self.key = .uninitialized
    }

    final var type: NodeType {
        Self.type
    }

    class var type: NodeType {
        .unknown
    }

    /**
     Returns extrinsic properties of the node.
     */
    func getProperties(with styles: StyleSheet) -> PropertyDict {
        PropertyDict()
    }
}

final class TextNode: Node {
    var string: String

    fileprivate init(_ string: String = "") {
        self.string = string
        super.init()
    }

    override final class var type: NodeType {
        .text
    }
}

class ElementNode: Node {
    var children: [NodeKey]
    var direction: TextDirection?

    fileprivate init(_ children: [NodeKey]) {
        self.children = children
        super.init()
    }
}

/**
 A minimalist element.
 */
final class ContentNode: ElementNode {
    override final class var type: NodeType {
        .content
    }
}

final class RootNode: ElementNode {
    override final class var type: NodeType {
        .root
    }
}

final class EmphasisNode: ElementNode {
    override final class var type: NodeType {
        .emphasis
    }
}

final class HeadingNode: ElementNode {
    let level: Int

    override final class var type: NodeType {
        .heading
    }

    fileprivate init(level: Int, _ children: [NodeKey]) {
        precondition(Heading.validate(level: level))
        self.level = level
        super.init(children)
    }

    /**
     Returns extrinsic properties
     */
    override func getProperties(with styles: StyleSheet) -> PropertyDict {
        let matcher = PropertyMatcher(PropertyName.level, PropertyValue.integer(0))
        let selector = Selector(NodeType.heading, matcher)
        return styles.getPropertyDict(selector) ?? PropertyDict()
    }
}

final class ParagraphNode: ElementNode {
    override final class var type: NodeType {
        .paragraph
    }
}

/**
 TeX calls this a "noad".
 */
class MathNode: Node { }

final class EquationNode: MathNode {
    private(set) var isBlock: Bool
    var nucleus: ContentNode

    fileprivate init(isBlock: Bool, _ nucleus: ContentNode) {
        self.isBlock = isBlock
        self.nucleus = nucleus
    }

    override final class var type: NodeType {
        .equation
    }
}

final class ScriptsNode: MathNode {
    var subScript: ContentNode?
    var superScript: ContentNode?

    fileprivate init(subScript: ContentNode? = nil, superScript: ContentNode? = nil) {
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

    fileprivate init(numerator: ContentNode, denominator: ContentNode) {
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

        fileprivate init(elements: [ContentNode]) {
            self.elements = elements
        }
    }

    private var rows: [MatrixRow]

    fileprivate init(rows: [MatrixRow]) {
        self.rows = rows
        super.init()
    }

    override final class var type: NodeType {
        .matrix
    }
}

final class ApplyNode: ElementNode {
    let templateName: TemplateName
    let variableLocations: [Nano.VariableLocations]

    fileprivate init(templateName: TemplateName,
                     variableLocations: [Nano.VariableLocations],
                     _ children: [NodeKey])
    {
        self.templateName = templateName
        self.variableLocations = variableLocations
        super.init(children)
    }

    override class var type: NodeType {
        .apply
    }
}

final class NamelessVariableNode: ElementNode {
    let index: Int

    fileprivate init(index: Int, _ children: [NodeKey]) {
        precondition(NamelessVariable.validate(index: index))
        self.index = index
        super.init(children)
    }

    override class var type: NodeType {
        .variable
    }
}

final class NodeFactory {
    func createTextNode(_ string: String) -> TextNode {
        preconditionFailure()
    }

    func createContentNode(_ children: [Node]) -> ContentNode {
        preconditionFailure()
    }

    func createRootNode(_ children: [Node]) -> RootNode {
        preconditionFailure()
    }

    func createEmphasisNode(_ children: [Node]) -> EmphasisNode {
        preconditionFailure()
    }

    func createHeadingNode(
        level: Int,
        _ children: [Node]
    ) -> HeadingNode {
        preconditionFailure()
    }

    func createParagraphNode(_ children: [Node]) -> ParagraphNode {
        preconditionFailure()
    }

    func createEquationNode(
        isBlock: Bool,
        _ nucleus: ContentNode
    ) -> EquationNode {
        preconditionFailure()
    }

    func createScriptsNode(
        subScript: ContentNode? = nil,
        superScript: ContentNode? = nil
    ) -> ScriptsNode {
        preconditionFailure()
    }

    func createFractionNode(
        numerator: ContentNode,
        denominator: ContentNode
    ) -> FractionNode {
        preconditionFailure()
    }

    func createMatrixNode(rows: [MatrixNode.MatrixRow]) -> MatrixNode {
        preconditionFailure()
    }

    func createApplyNode(
        templateName: TemplateName,
        variableLocations: [Nano.VariableLocations],
        _ children: [Node]
    ) -> ApplyNode {
        preconditionFailure()
    }

    func createNamelessVariableNode(
        index: Int,
        _ children: [Node]
    ) -> NamelessVariableNode {
        preconditionFailure()
    }
}
