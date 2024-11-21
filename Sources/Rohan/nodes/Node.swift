// Copyright 2024 Lie Yan

import Foundation

protocol NodeProtocol {
    var type: NodeType { get }
}

class Node {
    final var type: NodeType {
        Self.getType()
    }

    weak var parent: Node?

    class func getType() -> NodeType {
        .unknown
    }
}
