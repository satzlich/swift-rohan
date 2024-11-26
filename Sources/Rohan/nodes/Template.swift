// Copyright 2024 Lie Yan

import Foundation

final class Template {
    let name: String
    let parameters: [String]
    let body: [Node]

    init(
        name: String,
        parameters: [String],
        body: [Node]
    ) {
        self.name = name
        self.parameters = parameters
        self.body = body
    }
}
