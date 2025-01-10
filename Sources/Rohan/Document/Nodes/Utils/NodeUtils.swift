// Copyright 2024-2025 Lie Yan

import Foundation

enum NodeUtils {
    public static func synopsis(of node: Node, _ version: VersionId?) -> String {
        let visitor = NodeSynopsisVisitor(version: version)
        return node.accept(visitor, ())
    }
}

extension Node {
    public func synopsis(for version: VersionId? = nil) -> String {
        NodeUtils.synopsis(of: self, version)
    }
}
