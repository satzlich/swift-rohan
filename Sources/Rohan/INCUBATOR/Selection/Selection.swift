// Copyright 2024 Lie Yan

import Foundation

struct SelectionPoint {
    /**
     A node into which a cursor can be placed
     */
    enum TaggedNode {
        case text(TextNode)
        case element(ElementNode)
        case math(MathNode)
    }

    let node: TaggedNode
    let offset: Int
}

struct RangeSelection {
    let anchor: SelectionPoint
    let focus: SelectionPoint
}
