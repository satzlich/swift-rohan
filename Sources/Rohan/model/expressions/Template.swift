// Copyright 2024 Lie Yan

import Collections
import Foundation

struct Template {
    let name: Identifier
    let parameters: [Identifier]
    let body: Content

    init?(
        name: Identifier,
        parameters: [Identifier],
        body: Content
    ) {
        guard Self.validateParameters(parameters) else {
            return nil
        }

        self.name = name
        self.parameters = parameters
        self.body = body
    }

    static func validateParameters(_ parameters: [Identifier]) -> Bool {
        parameters.count == Set(parameters).count
    }
}

struct TemplateWithUses {
    let template: Template
    let templateUses: Set<Identifier>

    var name: Identifier {
        template.name
    }
}

struct TemplateWithVariableUses {
    typealias VariableUseIndex = OrderedDictionary<Identifier, OrderedSet<TreePath>>

    let template: Template
    let variableUses: VariableUseIndex

    var name: Identifier {
        template.name
    }
}

struct NamelessTemplate {
    let name: Identifier
    let parameterCount: Int
    let body: Content

    static func validateBody(_ body: Content, _ parameterCount: Int) -> Bool {
        true
    }
}
