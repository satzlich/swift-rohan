// Copyright 2024 Lie Yan

import Collections
import Foundation

struct Template {
    let name: TemplateName
    let parameters: [Identifier]
    let body: Content

    init(
        name: TemplateName,
        parameters: [Identifier],
        body: Content
    ) {
        precondition(Template.validate(parameters: parameters))

        self.name = name
        self.parameters = parameters
        self.body = body
    }

    func with(body: Content) -> Template {
        Template(name: name, parameters: parameters, body: body)
    }

    static func validate(parameters: [Identifier]) -> Bool {
        parameters.count == Set(parameters).count
    }
}
