// Copyright 2024 Lie Yan

import Foundation

class TextNode: Node {
    override final class func getType() -> NodeType {
        .text
    }
}
