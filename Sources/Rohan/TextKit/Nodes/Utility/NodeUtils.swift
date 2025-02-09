// Copyright 2024-2025 Lie Yan

import _RopeModule
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

    /**
     Insert `string` into text node at `offset` where text node is the child
     of `parent` at `index

     - Warning: The function is used in ``ContentStorage`` only.
     */
    static func insertString(_ string: String,
                             textNode: TextNode, offset: Int,
                             _ parent: ElementNode, _ index: Int)
    {
        precondition((0 ... textNode.characterCount) ~= offset)
        precondition((0 ..< parent.childCount) ~= index &&
            parent.getChild(index) === textNode)
        let newTextNode = {
            let string = TextNode.spliceString(textNode.bigString, offset, string)
            return TextNode(string as BigString)
        }()
        parent.replaceChild(newTextNode, at: index, inContentStorage: true)
    }

    /**
     Insert string into element node at `index`. This function is generally not
     for root node which requires special treatment.

     - Warning: The function is used in ``ContentStorage`` only.
     */
    static func insertString(_ string: String, elementNode: ElementNode, index: Int) {
        func isTextNode(_ node: Node) -> Bool { node.nodeType == .text }

        let childCount = elementNode.childCount
        if index == childCount {
            // add to the end of the last child if it is a text node; otherwise,
            // create a new text node
            if childCount > 0, isTextNode(elementNode.getChild(childCount - 1)) {
                let textNode = elementNode.getChild(childCount - 1) as! TextNode
                insertString(string, textNode: textNode, offset: textNode.characterCount,
                             elementNode, childCount - 1)
            }
            else {
                elementNode.insertChild(TextNode(string), at: index,
                                        inContentStorage: true)
            }
        }
        else {
            assert(index < elementNode.childCount)
            // add to the start of the index-th child if it is a text node; otherwise,
            // add to the end of the (index-1)-th child if it is a text node;
            // otherwise, create a new text node
            let child = elementNode.getChild(index)
            if isTextNode(child) {
                let textNode = child as! TextNode
                insertString(string, textNode: textNode, offset: 0, elementNode, index)
            }
            else if index > 0, isTextNode(elementNode.getChild(index - 1)) {
                let textNode = elementNode.getChild(index - 1) as! TextNode
                insertString(string, textNode: textNode, offset: textNode.characterCount,
                             elementNode, index - 1)
            }
            else {
                elementNode.insertChild(TextNode(string), at: index,
                                        inContentStorage: true)
            }
        }
    }
}
