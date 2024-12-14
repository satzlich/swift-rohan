// Copyright 2024 Lie Yan

import Foundation

struct Identifier: Equatable, Hashable, Codable {
    let name: String

    init(_ name: String) {
        precondition(Identifier.validateName(name))
        self.name = name
    }

    static func validateName(_ string: String) -> Bool {
        try! #/[a-zA-Z_][a-zA-Z0-9_]*/#.wholeMatch(in: string) != nil
    }
}
