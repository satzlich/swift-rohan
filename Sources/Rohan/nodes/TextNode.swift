// Copyright 2024 Lie Yan

import Foundation

class TextNode: Node {
    var text: Text

    override final class func getType() -> NodeType {
        .text
    }

    init(_ text: String) {
        self.text = Text(text)
        super.init()
    }
}
