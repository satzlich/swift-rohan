// Copyright 2024 Lie Yan

import Foundation

/**
 Essentially, it is a linear sequence of nodes.
 */
class ElementNode: Node {
    var children: [Node]

    override convenience init() {
        self.init([])
    }

    init(_ children: [Node]) {
        self.children = children
        super.init()
    }
}
