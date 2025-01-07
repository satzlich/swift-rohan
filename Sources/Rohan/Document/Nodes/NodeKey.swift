// Copyright 2024-2025 Lie Yan

import Foundation

struct NodeKey: Equatable, Hashable, Codable {
    let rawValue: Int

    init(rawValue: Int = 0) {
        precondition(NodeKey.validate(rawValue: rawValue))
        self.rawValue = rawValue
    }

    static let uninitialized = NodeKey()

    static func validate(rawValue: Int) -> Bool {
        rawValue >= 0
    }

    static func nextKey() -> NodeKey {
        NodeKeyAllocator.nextKey()
    }

    private final class NodeKeyAllocator {
        private static var counter = 1

        static func nextKey() -> NodeKey {
            defer { counter += 1 }
            return NodeKey(rawValue: counter)
        }
    }
}
