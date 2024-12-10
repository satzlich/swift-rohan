// Copyright 2024 Lie Yan

import Foundation

struct TreePath: Equatable, Hashable {
    let branches: [Int]

    init?(_ branches: [Int]) {
        guard TreePath.validateBranches(branches) else {
            return nil
        }
        self.init(validated: branches)
    }

    init(validated branches: [Int]) {
        precondition(TreePath.validateBranches(branches))
        self.branches = branches
    }

    func appended(_ tail: TreePath) -> TreePath {
        TreePath(validated: branches + tail.branches)
    }

    func appended(validated tail: Int) -> TreePath {
        precondition(TreePath.validateBranch(tail))
        return TreePath(validated: branches + [tail])
    }

    func prepended(_ head: TreePath) -> TreePath {
        TreePath(validated: head.branches + branches)
    }

    func prepended(validated head: Int) -> TreePath {
        precondition(TreePath.validateBranch(head))
        return TreePath(validated: [head] + branches)
    }

    // MARK: - Validation

    static func validateBranch(_ branch: Int) -> Bool {
        branch >= 0
    }

    static func validateBranches(_ branches: [Int]) -> Bool {
        !branches.isEmpty &&
            branches.allSatisfy(TreePath.validateBranch)
    }
}
