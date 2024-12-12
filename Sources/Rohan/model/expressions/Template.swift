// Copyright 2024 Lie Yan

import Collections
import Foundation

struct Template {
    let name: TemplateName
    let parameters: [Identifier]
    let body: Content

    init?(
        name: TemplateName,
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

// MARK: - TemplateWithUses

struct TemplateWithUses {
    let template: Template
    let templateUses: Set<TemplateName>

    var name: TemplateName {
        template.name
    }
}

// MARK: - TemplateWithVariableUses

struct TemplateWithVariableUses {
    /**
     variable name -> variable use paths
     */
    typealias VariableUseIndex = OrderedDictionary<Identifier, OrderedSet<TreePath>>

    let template: Template
    let variableUses: VariableUseIndex

    var name: TemplateName {
        template.name
    }
}

// MARK: - NamelessTemplate

struct NamelessTemplate {
    let parameterCount: Int
    let body: Content

    static func validateBody(_ body: Content, _ parameterCount: Int) -> Bool {
        // contains no apply
        // variables are nameless
        // variable indices are in range
        true
    }
}
