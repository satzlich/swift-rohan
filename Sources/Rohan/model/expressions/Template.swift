// Copyright 2024 Lie Yan

import Foundation

struct Template {
    let name: Identifier
    let parameters: [Identifier]
    let body: [Expression]

    init?(
        name: Identifier,
        parameters: [Identifier],
        body: [Expression]
    ) {
        guard Self.validateParameters(parameters) else {
            return nil
        }

        self.name = name
        self.parameters = parameters
        self.body = body
    }

    #if TESTING
    init?(
        name: String,
        parameters: [String],
        body: [Expression]
    ) {
        guard let name = Identifier(name) else {
            return nil
        }

        let parameters_ = parameters.compactMap(Identifier.init)
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

    static func validateParameters(_ parameters: [Identifier]) -> Bool {
        parameters.count == Set(parameters).count
    }
}
