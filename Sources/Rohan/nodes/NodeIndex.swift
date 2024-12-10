// Copyright 2024 Lie Yan

import Foundation

struct NodeIndex: Equatable, Hashable, Codable {
    let rawValue: Int

    init?(_ rawValue: Int) {
        guard NodeIndex.validateRawValue(rawValue) else {
            return nil
        }
        self.rawValue = rawValue
    }

    static func validateRawValue(_ rawValue: Int) -> Bool {
        rawValue >= 0
    }
}
