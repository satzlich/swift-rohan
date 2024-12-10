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
        guard parameters.count == Set(parameters).count else {
            return nil
        }

        self.name = name
        self.parameters = parameters

        Template.indexNodes(body)
        self.body = body
    }

    convenience init?(
        name: String,
        parameters: [String],
        body: [Node]
    ) {
        guard let name = IdentifierName(name) else {
            return nil
        }

        let newParameters = parameters.compactMap(IdentifierName.init)
        guard newParameters.count == parameters.count else {
            return nil
        }

        self.init(
            name: name,
            parameters: newParameters,
            body: body
        )
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
}
