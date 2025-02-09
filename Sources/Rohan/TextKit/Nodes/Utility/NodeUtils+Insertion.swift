// Copyright 2024-2025 Lie Yan

import _RopeModule
import Foundation

extension NodeUtils {
    /**
     Insert `string` into text node at `offset` where text node is the child
     of `parent` at `index

     - Warning: The function is used in ``ContentStorage`` only.
     */
    static func insertString(_ string: String, textNode: TextNode, offset: Int,
                             _ parent: ElementNode, _ index: Int)
    {
        precondition(offset <= textNode.characterCount)
        precondition(index < parent.childCount && parent.getChild(index) === textNode)
        let string: BigString = StringUtils.splice(textNode.bigString, offset, string)
        parent.replaceChild(TextNode(string), at: index, inContentStorage: true)
    }

    /**
     Insert string into root node at `index`.

     - Throws: SatzError(.InsaneRootChild)
     - Warning: The function is used in ``ContentStorage`` only.
     */
    static func insertString(_ string: String, rootNode: RootNode, index: Int) throws {
        precondition(index <= rootNode.childCount)

        let childCount = rootNode.childCount
        // if there is no existing node to insert into, create a paragraph
        if childCount == 0 {
            let paragraph = ParagraphNode([TextNode(string)])
            rootNode.insertChild(paragraph, at: index, inContentStorage: true)
        }
        // if the index is the last index, add to the end of the last child
        else if index == childCount {
            assert(childCount > 0)
            guard let lastChild = rootNode.getChild(childCount - 1) as? ElementNode
            else { throw SatzError(.InsaneRootChild) }
            NodeUtils.insertString(string, elementNode: lastChild,
                                   index: lastChild.childCount)
        }
        // otherwise, add to the start of index-th child
        else {
            guard let element = rootNode.getChild(index) as? ElementNode
            else { throw SatzError(.InsaneRootChild) }

            // cases:
            //  1) there is a text node to insert into
            //  2) we need create a new text node
            if element.childCount > 0,
               let textNode = element.getChild(0) as? TextNode
            {
                NodeUtils.insertString(string, textNode: textNode, offset: 0,
                                       element, 0)
            }
            else {
                element.insertChild(TextNode(string), at: 0, inContentStorage: true)
            }
        }
    }

    /**
     Insert string into element node at `index`. This function is generally not
     for root node which requires special treatment.

     - Warning: The function is used in ``ContentStorage`` only.
     */
    static func insertString(_ string: String, elementNode: ElementNode, index: Int) {
        precondition(elementNode.nodeType != .root && index <= elementNode.childCount)

        let childCount = elementNode.childCount

        if index == childCount {
            // add to the end of the last child if it is a text node; otherwise,
            // create a new text node
            if childCount > 0,
               let textNode = elementNode.getChild(childCount - 1) as? TextNode
            {
                insertString(string, textNode: textNode, offset: textNode.characterCount,
                             elementNode, childCount - 1)
            }
            else {
                let textNode = TextNode(string)
                elementNode.insertChild(textNode, at: index, inContentStorage: true)
            }
        }
        else {
            // add to the start of the index-th child if it is a text node; otherwise,
            // add to the end of the (index-1)-th child if it is a text node;
            // otherwise, create a new text node
            if let textNode = elementNode.getChild(index) as? TextNode {
                insertString(string, textNode: textNode, offset: 0, elementNode, index)
            }
            else if index > 0,
                    let textNode = elementNode.getChild(index - 1) as? TextNode
            {
                insertString(string, textNode: textNode, offset: textNode.characterCount,
                             elementNode, index - 1)
            }
            else {
                let textNode = TextNode(string)
                elementNode.insertChild(textNode, at: index, inContentStorage: true)
            }
        }
    }
}
