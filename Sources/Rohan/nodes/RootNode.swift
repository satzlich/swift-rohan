// Copyright 2024 Lie Yan

import Foundation

final class RootNode: ElementNode {
    override final class func getType() -> NodeType {
        .root
    }
}
