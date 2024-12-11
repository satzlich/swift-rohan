// Copyright 2024 Lie Yan

import Foundation

enum ChildIndex: Equatable, Hashable {
    case regular(Int)
    case grid(row: Int, column: Int)
}

struct TreePath: Equatable, Hashable {
    let indices: [ChildIndex]

    init(_ indices: [ChildIndex]) {
        self.indices = indices
    }

    func appended(_ tail: TreePath) -> TreePath {
        TreePath(indices + tail.indices)
    }

    func appended(_ tail: ChildIndex) -> TreePath {
        TreePath(indices + [tail])
    }

    func prepended(_ head: TreePath) -> TreePath {
        TreePath(head.indices + indices)
    }

    func prepended(_ head: ChildIndex) -> TreePath {
        TreePath([head] + indices)
    }
}
