// Copyright 2024 Lie Yan

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
        - children (immutable nodes and mutable references to arguments)
    - ArgumentReferenceNode(index, content)
 */

class Node {
    final var type: NodeType {
        Self.getType()
    }

    func getPropertyDict(with styles: StyleSheet) -> PropertyDict {
        PropertyDict()
    }

    class func getType() -> NodeType {
        .unknown
    }
}

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

class ElementNode: Node {
    var children: [Node]
    var direction: Direction?

    init(_ children: [Node]) {
        self.children = children
        super.init()
    }
}

/**
 A minimalist element.
 */
final class ContentNode: ElementNode {
    override final class func getType() -> NodeType {
        .content
    }
}

class MathNode: Node {
    var components: [ContentNode] {
        preconditionFailure()
    }
}

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
    let level: Int

    override final class func getType() -> NodeType {
        .heading
    }

    init(level: Int, _ children: [Node]) {
        precondition(Heading.validate(level: level))
        self.level = level
        super.init(children)
    }

    /**
     Returns extrinsic properties
     */
    override func getPropertyDict(with styles: StyleSheet) -> PropertyDict {
        let propertyMatcher = PropertyMatcher(name: PropertyName.level,
                                              value: PropertyValue.integer(0))
        let selector = Selector(nodeType: NodeType.heading,
                                propertyMatcher: propertyMatcher)
        return styles.getPropertyDict(selector) ?? PropertyDict()
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

    override final var components: [ContentNode] {
        [mathList]
    }

    override final class func getType() -> NodeType {
        .equation
    }
}

final class ScriptsNode: MathNode {
    var subScript: ContentNode?
    var superScript: ContentNode?

    init(subScript: ContentNode? = nil, superScript: ContentNode? = nil) {
        precondition(subScript != nil || superScript != nil)

        self.subScript = subScript
        self.superScript = superScript

        super.init()
    }

    override final var components: [ContentNode] {
        var components = [ContentNode]()

        if let `subscript` = subScript {
            components.append(`subscript`)
        }
        if let superscript = superScript {
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

        init(elements: [ContentNode]) {
            self.elements = elements
        }

        var count: Int {
            elements.count
        }

        subscript(index: Int) -> ContentNode {
            elements[index]
        }
    }

    var rows: [MatrixRow]

    init(rows: [MatrixRow]) {
        self.rows = rows

        super.init()
    }

    override final var components: [ContentNode] {
        rows.flatMap { $0.elements }
    }

    override final class func getType() -> NodeType {
        .matrix
    }
}
