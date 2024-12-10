// Copyright 2024 Lie Yan

import Foundation

struct IdentifierName: Equatable, Hashable, Codable {
    let name: String

    init?(_ name: String) {
        guard IdentifierName.validateIdentifierName(name) else {
            return nil
        }

        self.name = name
    }

    static func validateIdentifierName(_ text: String) -> Bool {
        try! #/[a-zA-Z_][a-zA-Z0-9_]*/#.wholeMatch(in: text) != nil
    }
}
