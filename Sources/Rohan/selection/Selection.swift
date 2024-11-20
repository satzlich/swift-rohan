// Copyright 2024 Lie Yan

import Foundation

/**
 A range in a document.
 */
struct RangeSelection {
    let anchor: Cursor
    let focus: Cursor
}

/**
 A point in a document.
 */
struct Cursor {
}
