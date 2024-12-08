// Copyright 2024 Lie Yan

import Collections
import Foundation

final class Template {
    let name: String
    let parameters: [String]
    let body: [Node]

    init?(
        name: String,
        parameters: [String],
        body: [Node]
    ) {
        guard Template.validateArguments(name, parameters, body) else {
            return nil
        }

        self.name = name
        self.parameters = parameters

        Template.indexNodes(body)
        self.body = body
    }

    /**
     Assigns a sequential index to each node
     */
    static func indexNodes(_ nodes: [Node]) {
        for (index, node) in nodes.enumerated() {
            precondition(node.tIndex == nil)

            node.tIndex = index
            // TODO: index children recursively
        }
    }

    static func validateArguments(
        _ name: String,
        _ parameters: [String],
        _ body: [Node]
    ) -> Bool {
        LexerUtils.validateIdentifier(name) &&
            // parameters are identifiers and distinct
            parameters.allSatisfy(LexerUtils.validateIdentifier) &&
            parameters.count == Set(parameters).count
    }
}
