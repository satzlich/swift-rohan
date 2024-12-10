// Copyright 2024 Lie Yan

import Collections
import Foundation

final class Template {
    let name: IdentifierName
    let parameters: [IdentifierName]
    let body: [Node]

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

