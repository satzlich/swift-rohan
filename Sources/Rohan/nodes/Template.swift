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

        for (index, node) in body.enumerated() {
            precondition(node.tIndex == nil)
            node.tIndex = index
        }
        self.body = body
    }

    static func validateArguments(
        _ name: String,
        _ parameters: [String],
        _ body: [Node]
    ) -> Bool {
        LexUtils.validateIdentifier(name) &&
            // parameters are identifiers and distinct
            parameters.allSatisfy(LexUtils.validateIdentifier) &&
            parameters.count == Set(parameters).count
    }
}
