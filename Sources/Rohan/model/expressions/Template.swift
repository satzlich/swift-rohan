// Copyright 2024 Lie Yan

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
