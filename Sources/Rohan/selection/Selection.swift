// Copyright 2024 Lie Yan

import Foundation

/*

 # Selection Model

 Segment selectable:
 - text: yes
 - element: yes
 - variable-value: yes
 - apply: no
 - math: no

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
    
    /*
     
     func isBefore(other: Marker) -> Bool? {
        nil
     }
     
     */
}

struct RangeSelection {
    let anchor: Marker
    let focus: Marker

    /*

     var isCollapsed: Bool {
        // anchor == focus
     }

     */
}
