// Copyright 2024 Lie Yan

import Foundation

struct TreePath: Equatable, Hashable {
    let indices: [NodeIndex]

    init(_ indices: [NodeIndex]) {
        self.indices = indices
    }

    func appended(_ tail: TreePath) -> TreePath {
        TreePath(indices + tail.indices)
    }

    func appended(_ tail: NodeIndex) -> TreePath {
        TreePath(indices + [tail])
    }

    func prepended(_ head: TreePath) -> TreePath {
        TreePath(head.indices + indices)
    }

    func prepended(_ head: NodeIndex) -> TreePath {
        TreePath([head] + indices)
    }
}
