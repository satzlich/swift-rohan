// Copyright 2024 Lie Yan

import Foundation

struct NodeKey: Equatable, Hashable, Codable {
    let rawValue: Int

    init(rawValue: Int) {
        self.rawValue = rawValue
    }

    init() {
        self.rawValue = -1
    }

    static let uninitialized = NodeKey()
}
