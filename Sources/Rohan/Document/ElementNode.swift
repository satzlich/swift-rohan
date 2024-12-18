// Copyright 2024 Lie Yan

import Collections
import Foundation

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

    init(level: Int, _ children: [Node]) {
        precondition(Heading.validate(level: level))
        self.level = level
        super.init(children)
    }

    /**
     Returns extrinsic properties
     */
    override func getPropertyDict(with styles: StyleSheet) -> PropertyDict {
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
