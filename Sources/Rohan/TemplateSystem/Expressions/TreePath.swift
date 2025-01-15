// Copyright 2024 Lie Yan

import Foundation

struct TreePath: Equatable, Hashable {
    let indices: [RohanIndex]

    init(_ indices: [RohanIndex] = []) {
        self.indices = indices
    }

    func appended(_ tail: RohanIndex) -> TreePath {
        TreePath(indices + [tail])
    }

    /*
     Other operations planned but not yet implemented:

     appended(_ tail: TreePath)
     prepended(_ head: TreePath)
     prepended(_ head: RohanIndex)

     We may not actually need them. Don't bother to implement until necessary.

     */
}
