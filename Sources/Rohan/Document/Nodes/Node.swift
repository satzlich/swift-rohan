//// Copyright 2024-2025 Lie Yan
//
//import Collections
//import Foundation
//
///*
//
// ## Data Model
//
// - Node category
//    - TextNode
//    - ElementNode(children)
//    - MathNode(components)
//
// - ElementNode:
//    - RootNode
//    - ContentNode
//    - EmphasisNode
//    - HeadingNode(level)
//    - ParagraphNode
//
// - MathNode:
//    - EquationNode(isBlock, nucleus)
//    - ScriptsNode( subScript ∨ superScript )
//    - FractionNode(numerator, denominator)
//    - MatrixNode(rows)
//        - MatrixRow(elements)
//
// - Abstraction mechanism
//    - ApplyNode(templateName)
//        - children (immutable nodes and mutable uses of arguments)
//    - NamelessVariableNode(index, content)
// */
//
//class Node {
//    fileprivate(set) var key: NodeKey
//
//    init(_ key: NodeKey) {
//        self.key = key
//    }
//
//    final var type: NodeType {
//        Self.type
//    }
//
//    class var type: NodeType {
//        .unknown
//    }
//
//    /**
//     Returns extrinsic properties of the node.
//     */
//    func getProperties(with styles: StyleSheet) -> PropertyDict {
//        PropertyDict()
//    }
//}
//
//final class TextNode: Node {
//    var string: String
//
//    init(_ key: NodeKey, _ string: String = "") {
//        self.string = string
//        super.init(key)
//    }
//
//    override final class var type: NodeType {
//        .text
//    }
//}
//
//class ElementNode: Node {
//    var children: [NodeKey]
//    var direction: TextDirection?
//
//    init(_ key: NodeKey, _ children: [NodeKey]) {
//        self.children = children
//        super.init(key)
//    }
//}
//
///**
// A minimalist element.
// */
//final class ContentNode: ElementNode {
//    override final class var type: NodeType {
//        .content
//    }
//}
//
//final class RootNode: ElementNode {
//    override final class var type: NodeType {
//        .root
//    }
//}
//
//final class EmphasisNode: ElementNode {
//    override final class var type: NodeType {
//        .emphasis
//    }
//}
//
//final class HeadingNode: ElementNode {
//    let level: Int
//
//    override final class var type: NodeType {
//        .heading
//    }
//
//    init(_ key: NodeKey, level: Int, _ children: [NodeKey]) {
//        precondition(Heading.validate(level: level))
//        self.level = level
//        super.init(key, children)
//    }
//
//    /**
//     Returns extrinsic properties
//     */
//    override func getProperties(with styles: StyleSheet) -> PropertyDict {
//        let matcher = PropertyMatcher(PropertyName.level, PropertyValue.integer(0))
//        let selector = Selector(NodeType.heading, matcher)
//        return styles.getPropertyDict(selector) ?? PropertyDict()
//    }
//}
//
//final class ParagraphNode: ElementNode {
//    override final class var type: NodeType {
//        .paragraph
//    }
//}
//
///**
// TeX calls this a "noad".
// */
//class MathNode: Node { }
//
//final class EquationNode: MathNode {
//    private(set) var isBlock: Bool
//    var nucleus: ContentNode
//
//    init(_ key: NodeKey,
//         isBlock: Bool,
//         _ nucleus: ContentNode)
//    {
//        self.isBlock = isBlock
//        self.nucleus = nucleus
//        super.init(key)
//    }
//
//    override final class var type: NodeType {
//        .equation
//    }
//}
//
//final class ScriptsNode: MathNode {
//    var subScript: ContentNode?
//    var superScript: ContentNode?
//
//    init(
//        _ key: NodeKey,
//        subScript: ContentNode? = nil,
//        superScript: ContentNode? = nil
//    ) {
//        precondition(subScript != nil || superScript != nil)
//
//        self.subScript = subScript
//        self.superScript = superScript
//        super.init(key)
//    }
//
//    override final class var type: NodeType {
//        .scripts
//    }
//}
//
//final class FractionNode: MathNode {
//    let numerator: ContentNode
//    let denominator: ContentNode
//
//    init(
//        _ key: NodeKey,
//        numerator: ContentNode, denominator: ContentNode
//    ) {
//        self.numerator = numerator
//        self.denominator = denominator
//        super.init(key)
//    }
//
//    override final class var type: NodeType {
//        .fraction
//    }
//}
//
//final class MatrixNode: MathNode {
//    struct MatrixRow {
//        private var elements: [ContentNode]
//
//        init(elements: [ContentNode]) {
//            self.elements = elements
//        }
//    }
//
//    private var rows: [MatrixRow]
//
//    init(_ key: NodeKey, rows: [MatrixRow]) {
//        self.rows = rows
//        super.init(key)
//    }
//
//    override final class var type: NodeType {
//        .matrix
//    }
//}
//
//final class ApplyNode: ElementNode {
//    let templateName: TemplateName
//    let variableLocations: [Nano.VariableLocations]
//
//    init(
//        _ key: NodeKey,
//        templateName: TemplateName,
//        variableLocations: [Nano.VariableLocations],
//        _ children: [NodeKey]
//    ) {
//        self.templateName = templateName
//        self.variableLocations = variableLocations
//        super.init(key, children)
//    }
//
//    override class var type: NodeType {
//        .apply
//    }
//}
//
//final class NamelessVariableNode: ElementNode {
//    let index: Int
//
//    init(
//        _ key: NodeKey,
//        index: Int, _ children: [NodeKey]
//    ) {
//        precondition(NamelessVariable.validate(index: index))
//        self.index = index
//        super.init(key, children)
//    }
//
//    override class var type: NodeType {
//        .variable
//    }
//}
