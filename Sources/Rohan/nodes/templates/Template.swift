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

        Template.indexNodes(body)
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
    static func indexNodes(_ nodes: [Node]) {
        for (index, node) in nodes.enumerated() {
            node.branchIndex = index
            // Recurse
            indexChildren(node)
        }
    }

    /**
     Assigns a sequential index to each child node
     */
    static func indexChildren(_ node: Node) {
        if let element = node as? ElementNode {
            indexNodes(element.children)
        }
        else if node.hasRegularIndex {
            for i in node.startIndex ..< node.endIndex {
                let child = node.child(at: i)
                child.branchIndex = i
                // Recurse
                indexChildren(child)
            }
        }
        else {
            preconditionFailure("not implemented")
        }
    }

    static func validateParameters(_ parameters: [IdentifierName]) -> Bool {
        parameters.count == Set(parameters).count
    }
}
