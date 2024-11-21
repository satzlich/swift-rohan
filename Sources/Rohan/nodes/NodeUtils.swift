// Copyright 2024 Lie Yan

import Foundation

enum NodeUtils {
    /** Returns true if the given node is a text node. */
    static func isTextNode(_ node: Node) -> Bool {
        node is TextNode
    }
}
