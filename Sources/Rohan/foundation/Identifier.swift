// Copyright 2024 Lie Yan

import Foundation

struct Identifier: Equatable, Hashable, Codable {
    let name: String

    init?(_ name: String) {
        guard Identifier.validateName(name) else {
            return nil
        }

        self.name = name
    }

    static func validateName(_ string: String) -> Bool {
        try! #/[a-zA-Z_][a-zA-Z0-9_]*/#.wholeMatch(in: string) != nil
    }
}
