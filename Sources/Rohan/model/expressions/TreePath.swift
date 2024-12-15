// Copyright 2024 Lie Yan

import Foundation

struct TreePath: Equatable, Hashable {
    let indices: [GeneralIndex]

    init(_ indices: [GeneralIndex] = []) {
        self.indices = indices
    }

    init(_ indices: ArraySlice<GeneralIndex>) {
        self.indices = Array(indices)
    }

    func appended(_ tail: TreePath) -> TreePath {
        TreePath(indices + tail.indices)
    }

    func appended(_ tail: GeneralIndex) -> TreePath {
        TreePath(indices + [tail])
    }

    func prepended(_ head: TreePath) -> TreePath {
        TreePath(head.indices + indices)
    }

    func prepended(_ head: GeneralIndex) -> TreePath {
        TreePath([head] + indices)
    }
}
