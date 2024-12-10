// Copyright 2024 Lie Yan

import Collections
import Foundation

final class Template {
    let name: IdentifierName
    let parameters: [IdentifierName]
    let body: [Node]

    // Computed properties

    let expansion: [Node]
    let parameterPaths: [IdentifierName: TreePath]

    init?(
        name: IdentifierName,
        parameters: [IdentifierName],
        body: [Node]
    ) {
        guard Template.validateParameters(parameters) else {
            return nil
        }

        self.name = name
        self.parameters = parameters

        Template.indexBranches(body)
        self.body = body

        // TODO: implement

        self.expansion = []
        self.parameterPaths = [:]
    }

    #if TESTING
    convenience init?(
        name: String,
        parameters: [String],
        body: [Node]
    ) {
        guard let name = IdentifierName(name) else {
            return nil
        }

        let parameters_ = parameters.compactMap(IdentifierName.init)
        guard parameters_.count == parameters.count else {
            return nil
        }

        self.init(
            name: name,
            parameters: parameters_,
            body: body
        )
    }
    #endif

    // MARK: - Utilities

    /**
     Assigns a sequential index to each node
     */
    static func indexBranches(_ nodes: [Node]) {
        for (index, node) in nodes.enumerated() {
            precondition(node.branchIndex == nil)

            node.branchIndex = index
            // TODO: index children recursively
        }
    }

    static func validateParameters(_ parameters: [IdentifierName]) -> Bool {
        parameters.count == Set(parameters).count
    }
}

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

    static func validateBranch(_ branch: Int) -> Bool {
        branch >= 0
    }

    static func validateBranches(_ branches: [Int]) -> Bool {
        !branches.isEmpty &&
            branches.allSatisfy(TreePath.validateBranch)
    }
}
