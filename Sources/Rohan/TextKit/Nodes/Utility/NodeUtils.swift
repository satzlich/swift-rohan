// Copyright 2024-2025 Lie Yan

import _RopeModule
import Foundation

enum NodeUtils {
    typealias AnnotatedNode = (node: Node, index: RohanIndex?)

    /**
     Given a path, return the nodes along the path.

     ## Example
     Given a path `[1, 2, 3]` and subtree, return
     ```
     [(subtree, 1), (node1, 2), (node2, 3), (node3, nil)]
     ```
     */
    static func traceNodes(along path: [RohanIndex], _ subtree: Node) -> [AnnotatedNode] {
        var result = [AnnotatedNode]()

        var node = subtree
        for index in path {
            guard let child = node.getChild(index) else { return [] }
            result.append((node, index))
            node = child
        }
        result.append((node, nil))

        return result
    }
}
