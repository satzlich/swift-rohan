// Copyright 2024 Lie Yan

import Foundation

struct NodeKey: Equatable, Hashable, Codable {
    let rawValue: Int

    init(rawValue: Int = 0) {
        precondition(Self.validate(rawValue: rawValue))
        self.rawValue = rawValue
    }

    static let uninitialized = NodeKey()

    static func validate(rawValue: Int) -> Bool {
        rawValue >= 0
    }
}
