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

    /**
     True if this marker is before the other.
     
     - Note: The signature is provisional. It is possible that we need more context to
     carry out the comparison.
     */
    func isBefore(_ other: Marker) -> Bool {
        // TODO: Implement
        false
    }
}
