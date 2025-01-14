// Copyright 2024 Lie Yan

import Foundation

struct TreePath: Equatable, Hashable {
    let indices: [GeneralIndex]

    init(_ indices: [GeneralIndex] = []) {
        self.indices = indices
    }

    func appended(_ tail: GeneralIndex) -> TreePath {
        TreePath(indices + [tail])
    }

    /*
     Other operations planned but not yet implemented:

     appended(_ tail: TreePath)
     prepended(_ head: TreePath)
     prepended(_ head: GeneralIndex)

     We may not actually need them. Don't bother to implement until necessary.

     */
}
