// Copyright 2024 Lie Yan

import Foundation

class Node {
    final var type: NodeType {
        Self.getType()
    }

    weak var parent: Node?

    class func getType() -> NodeType {
        .unknown
    }
}
