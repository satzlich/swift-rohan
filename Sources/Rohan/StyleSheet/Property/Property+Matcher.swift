// Copyright 2024-2025 Lie Yan

import Foundation

extension Property {
    // MARK: - Matcher

    public struct Matcher: Equatable, Hashable, Codable {
        public let name: Name
        public let value: Value

        init(_ name: Name, _ value: Value) {
            self.name = name
            self.value = value
        }
    }
}
