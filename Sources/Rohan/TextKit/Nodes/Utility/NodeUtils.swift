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

    /**  insert string into text node at `offset` where text node is the child
     of `parent` at `index */
    static func insert(_ string: String,
                       textNode: TextNode, offset: Int,
                       _ parent: ElementNode, _ index: Int)
    {
        precondition(offset <= textNode.characterCount)
        // remove the text node
        parent.removeChild(at: index, inContentStorage: true)
        // insert the new text node
        let newTextNode = {
            let string = TextNode.spliceString(textNode.bigString, offset, string)
            return TextNode(string)
        }()
        parent.insertChild(newTextNode, at: index, inContentStorage: true)
    }

    /** insert string into element node at `index */
    static func insert(_ string: String, elementNode: ElementNode, index: Int) {
        func isTextNode(_ node: Node) -> Bool { node.nodeType == .text }

        let childCount = elementNode.childCount()
        if index == childCount {
            // add to the end of the last child if it is a text node; otherwise,
            // create a new text node
            if childCount > 0, isTextNode(elementNode.getChild(childCount - 1)) {
                let textNode = elementNode.getChild(childCount - 1) as! TextNode
                insert(string, textNode: textNode, offset: textNode.characterCount,
                       elementNode, childCount - 1)
            }
            else {
                elementNode.insertChild(TextNode(string), at: index,
                                        inContentStorage: true)
            }
        }
        else {
            assert(index < elementNode.childCount())
            // add to the start of the index-th child if it is a text node; otherwise,
            // add to the end of the (index-1)-th child if it is a text node;
            // otherwise, create a new text node
            let child = elementNode.getChild(index)
            if isTextNode(child) {
                let textNode = child as! TextNode
                insert(string, textNode: textNode, offset: 0, elementNode, index)
            }
            else if index > 0, isTextNode(elementNode.getChild(index - 1)) {
                let textNode = elementNode.getChild(index - 1) as! TextNode
                insert(string, textNode: textNode, offset: textNode.characterCount,
                       elementNode, index - 1)
            }
            else {
                elementNode.insertChild(TextNode(string), at: index,
                                        inContentStorage: true)
            }
        }
    }
}
