// Copyright 2024 Lie Yan

import Foundation

/**
 A range in a document.
 */
struct RangeSelection {
    let anchor: Marker
    let focus: Marker
}

/**
 A position in a document.
 */
struct Marker {
    /*
     Fields:
        - container node
        - parent selection
     */

    /**
     Offset within the container node.
     
     - Invariant: `offset >= 0`
     */
    let offset: Int
}
