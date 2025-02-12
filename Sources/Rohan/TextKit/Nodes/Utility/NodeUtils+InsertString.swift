// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

extension NodeUtils {
  /**
   Insert `string` at `location` in `tree`.

   - Returns: nil if `location` is into a text node and equals to the resulting
    insertion point; the new insertion point otherwise, in which case it guaranteed
    to be into a text node.
   - Throws: SatzError(.InvalidTextLocation)
   */
  static func insertString(
    _ string: String,
    _ location: TextLocation,
    _ tree: RootNode
  ) throws -> TextLocation? {
    // if the string is empty, do nothing
    guard !string.isEmpty else { return nil }

    guard let nodes = NodeUtils.traceNodes(location, tree),
      let lastNode = nodes.last?.node
    else { throw SatzError(.InvalidTextLocation) }

    // Consider three cases:
    //  1) text node, 2) root node, or 3) element node (other than root).
    switch lastNode {
    case let textNode as TextNode:
      let offset = location.offset
      // get parent and index
      guard let parent_ = nodes.dropLast().last,  // "_" suffix to avoid name conflict
        let parent = parent_.node as? ElementNode,
        let index = parent_.index.index(),
        // check index and offset
        index < parent.childCount,
        offset <= textNode.characterCount
      else { throw SatzError(.InvalidTextLocation) }
      // perform insertion
      insertString(string, textNode: textNode, offset: offset, parent, index)
      // ASSERT: location remains valid
      return nil

    case let rootNode as RootNode:
      let index = location.offset
      guard index <= rootNode.childCount else { throw SatzError(.InvalidTextLocation) }
      let (i0, i1, i2) = try insertString(string, rootNode: rootNode, index: index)
      return TextLocation(location.path + [.index(i0), .index(i1)], i2)

    case let elementNode as ElementNode:
      let index = location.offset
      guard index <= elementNode.childCount else { throw SatzError(.InvalidTextLocation) }
      let (i0, i1) = insertString(string, elementNode: elementNode, index: index)
      return TextLocation(location.path + [.index(i0)], i1)

    default:
      throw SatzError(
        .InvalidTextLocation, message: "location should point into text or element node")
    }
  }

  /**
   Insert `string` into text node at `offset` where text node is the child
   of `parent` at `index
   - Warning: The function is used in ``ContentStorage`` only.
   - Postcondition: Insertion point `(parent, index, offset)` remains valid.
   */
  private static func insertString(
    _ string: String, textNode: TextNode, offset: Int,
    _ parent: ElementNode, _ index: Int
  ) {
    precondition(offset <= textNode.characterCount)
    precondition(index < parent.childCount && parent.getChild(index) === textNode)
    let string: BigString = StringUtils.splice(textNode.bigString, offset, string)
    parent.replaceChild(TextNode(string), at: index, inContentStorage: true)
  }

  /**
   Insert string into root node at `index`.
   - Returns: assuming insertion point is at (rootNode, index), return (i0, i1, i2)
    so that (rootNode, i0, i1, i2) is the new insertion point.
   - Throws: SatzError(.InsaneRootChild)
   - Warning: The function is used in ``ContentStorage`` only.
   */
  private static func insertString(
    _ string: String, rootNode: RootNode, index: Int
  ) throws -> (Int, Int, Int) {
    precondition(index <= rootNode.childCount)

    let childCount = rootNode.childCount
    // if there is no existing node to insert into, create a paragraph
    if childCount == 0 {
      let paragraph = ParagraphNode([TextNode(string)])
      rootNode.insertChild(paragraph, at: index, inContentStorage: true)
      return (index, 0, 0)
    }
    // if the index is the last index, add to the end of the last child
    else if index == childCount {
      assert(childCount > 0)
      guard let lastChild = rootNode.getChild(childCount - 1) as? ElementNode
      else { throw SatzError(.InsaneRootChild) }
      let (i0, i1) = insertString(
        string, elementNode: lastChild, index: lastChild.childCount)
      return (childCount - 1, i0, i1)
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
        insertString(string, textNode: textNode, offset: 0, element, 0)
        return (index, 0, 0)
      }
      else {
        element.insertChild(TextNode(string), at: 0, inContentStorage: true)
        return (index, 0, 0)
      }
    }
  }

  /**
   Insert string into element node at `index`. This function is generally not
   for root node which requires special treatment.
   - Returns: (i0, i1) assuming insertion point is (elementNode, index), so that
    the new insertion point is (elementNode, i0, i1)
   - Warning: The function is used in ``ContentStorage`` only.
   */
  private static func insertString(
    _ string: String, elementNode: ElementNode, index: Int
  ) -> (Int, Int) {
    precondition(elementNode.nodeType != .root && index <= elementNode.childCount)

    let childCount = elementNode.childCount

    if index == childCount {
      // add to the end of the last child if it is a text node; otherwise,
      // create a new text node
      if childCount > 0,
        let textNode = elementNode.getChild(childCount - 1) as? TextNode
      {
        let characterCount = textNode.characterCount  // save in case text node is mutable
        insertString(
          string, textNode: textNode, offset: textNode.characterCount,
          elementNode, childCount - 1)
        return (childCount - 1, characterCount)
      }
      else {
        let textNode = TextNode(string)
        elementNode.insertChild(textNode, at: index, inContentStorage: true)
        return (index, 0)
      }
    }
    else {
      // add to the start of the index-th child if it is a text node; otherwise,
      // add to the end of the (index-1)-th child if it is a text node;
      // otherwise, create a new text node
      if let textNode = elementNode.getChild(index) as? TextNode {
        insertString(string, textNode: textNode, offset: 0, elementNode, index)
        return (index, 0)
      }
      else if index > 0,
        let textNode = elementNode.getChild(index - 1) as? TextNode
      {
        let characterCount = textNode.characterCount  // save in case text node is mutable
        insertString(
          string, textNode: textNode, offset: textNode.characterCount,
          elementNode, index - 1)
        return (index - 1, characterCount)
      }
      else {
        let textNode = TextNode(string)
        elementNode.insertChild(textNode, at: index, inContentStorage: true)
        return (index, 0)
      }
    }
  }
}
