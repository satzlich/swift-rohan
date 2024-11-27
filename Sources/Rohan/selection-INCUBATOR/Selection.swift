// Copyright 2024 Lie Yan

import Foundation

/*

 - selectable
    - normal or sticky
 - copyable
 - deletable

 */

/**
 A node into which a cursor can be placed
 */
enum MarkableNode {
    case text(TextNode)
    case element(ElementNode)
}

struct Marker {
    let node: MarkableNode
    let offset: Int
}

struct RangeSelection {
    let anchor: Marker
    let focus: Marker
}
