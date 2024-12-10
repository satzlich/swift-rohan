// Copyright 2024 Lie Yan

import Foundation

struct TreePath: Equatable, Hashable {
    let indices: [Int]

    init?(_ indices: [Int]) {
        guard TreePath.validateIndices(indices) else {
            return nil
        }
        self.init(validated: indices)
    }

    init(validated indices: [Int]) {
        precondition(TreePath.validateIndices(indices))
        self.indices = indices
    }

    func appended(_ tail: TreePath) -> TreePath {
        TreePath(validated: indices + tail.indices)
    }

    func appended(validated tail: Int) -> TreePath {
        precondition(TreePath.validateIndex(tail))
        return TreePath(validated: indices + [tail])
    }

    func prepended(_ head: TreePath) -> TreePath {
        TreePath(validated: head.indices + indices)
    }

    func prepended(validated head: Int) -> TreePath {
        precondition(TreePath.validateIndex(head))
        return TreePath(validated: [head] + indices)
    }

    // MARK: - Validation

    static func validateIndex(_ index: Int) -> Bool {
        index >= 0
    }

    static func validateIndices(_ indices: [Int]) -> Bool {
        !indices.isEmpty &&
            indices.allSatisfy(TreePath.validateIndex)
    }
}
