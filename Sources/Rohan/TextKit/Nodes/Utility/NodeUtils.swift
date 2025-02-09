// Copyright 2024-2025 Lie Yan

import Foundation

enum NodeUtils {
    typealias AnnotatedNode = (node: Node, index: RohanIndex?)

    /**
     Given a path and a subtree, return the nodes along the path. If the path
     is invalid for the subtree, return `nil`.

     - Postcondition: `result == nil ∨ result!.count > 0`

     ## Example
     Given a path `[1, 2, 3]` and subtree, return
     ```swift
     [(subtree, 1), (node1, 2), (node2, 3), (node3, nil)]
     ```
     */
    static func traceNodes<C>(along path: C, _ subtree: Node) -> [AnnotatedNode]?
    where C: Collection, C.Element == RohanIndex {
        var result = [AnnotatedNode]()
        result.reserveCapacity(path.count + 1)

        var node = subtree
        for index in path {
            guard let child = node.getChild(index) else { return nil }
            result.append((node, index))
            node = child
        }
        result.append((node, nil))

        return result
    }
}
