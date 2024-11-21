// Copyright 2024 Lie Yan

import Foundation

final class RootNode: ElementNode {
    override final class func getType() -> NodeType {
        .root
    }

    override final func isInline() -> Bool {
        // For root node, the return value is unused.
        true
    }
}
