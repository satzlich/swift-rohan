// Copyright 2024 Lie Yan

import Foundation

struct NodeKey: Equatable, Hashable, Codable {
    let rawValue: Int

    init(_ rawValue: Int) {
        self.rawValue = rawValue
    }
}
