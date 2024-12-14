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
        guard Template.validateParameters(parameters) else {
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

