// Copyright 2024 Lie Yan

import Foundation

class TextNode: Node {
    var text: String

    override final class func getType() -> NodeType {
        .text
    }

    init(_ text: String) {
        self.text = text
        super.init()
    }
}
