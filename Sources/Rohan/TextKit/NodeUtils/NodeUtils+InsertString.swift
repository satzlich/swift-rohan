// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

extension NodeUtils {
  /**
   Insert `string` at `location` in `tree`.

   - Returns: nil if string is empty, or if `location` is into a text node and
      equals to the resulting insertion point; the new insertion point otherwise,
      in which case it is guaranteed to be into a text node.
   - Throws: SatzError(.InvalidTextLocation)
   */
  static func insertString(
    _ string: String, at location: TextLocation, _ tree: RootNode
  ) throws -> TextLocation? {
    // if the string is empty, do nothing
    guard !string.isEmpty else { return nil }

    let locationCorrection = try insertString(
      string, at: location.asPartialLocation, tree)
    // if there is no location correction, the insertion point is unchanged
    guard let locationCorrection else { return nil }
    let indices = location.indices + locationCorrection.dropLast().map({ .index($0) })
    let offset = locationCorrection[locationCorrection.endIndex - 1]
    return TextLocation(indices, offset)
  }

  /**
   Insert `string` at `location` in `subtree`.

   - Returns: an optional location correction which is applicable when the
      initial insertion point is `location` and the return value is not nil.
      When applicable, the new insertion point becomes `location.indices ++ correction`.
   - Throws: SatzError(.InvalidTextLocation)
   - Precondition: string is not empty.
   - Note: The caller is responsible for applying the location correction.
   */
  static func insertString(
    _ string: String, at location: PartialLocation, _ subtree: ElementNode
  ) throws -> [Int]? {
    precondition(!string.isEmpty)

    guard
      let (trace, truthMaker) = traceNodes(location, subtree, until: isArgumentNode(_:))
    else { return nil }

    if truthMaker == nil {  // the final location is found
      guard let lastNode = trace.last?.node else { throw SatzError(.InvalidTextLocation) }
      // Consider three cases:
      //  1) text node, 2) root node, or 3) element node (other than root).
      switch lastNode {
      case let textNode as TextNode:
        let offset = location.offset
        // get parent and index
        guard let secondLast = trace.dropLast().last,
          let parent = secondLast.node as? ElementNode,
          let index = secondLast.index.index(),
          // check index and offset
          index < parent.childCount,
          offset <= textNode.stringLength
        else { throw SatzError(.InvalidTextLocation) }
        // perform insertion
        insertString(string, textNode: textNode, offset: offset, parent, index)
        // ASSERT: location remains valid
        return nil

      case let rootNode as RootNode:
        let index = location.offset
        guard index <= rootNode.childCount else { throw SatzError(.InvalidTextLocation) }
        let (i0, i1, i2) = try insertString(string, rootNode: rootNode, index: index)
        return [i0, i1, i2]

      case let elementNode as ElementNode:
        let index = location.offset
        guard index <= elementNode.childCount else {
          throw SatzError(.InvalidTextLocation)
        }
        let (i0, i1) = insertString(string, elementNode: elementNode, index: index)
        return [i0, i1]

      default:
        throw SatzError(
          .InvalidTextLocation,
          message: "location should point into text or element node")
      }
    }
    else {
      let argumentNode = truthMaker as! ArgumentNode
      let newLocation = location.dropFirst(trace.count)
      return try argumentNode.insertString(string, at: newLocation)
    }
  }

  /**
   Insert `string` into text node at `offset` where text node is the child
   of `parent` at `index
   - Postcondition: Insertion point `(parent, index, offset)` remains valid.
   - Warning: The function is used only when `inStorage=true`.
   */
  private static func insertString(
    _ string: String, textNode: TextNode, offset: Int,
    _ parent: ElementNode, _ index: Int
  ) {
    precondition(offset <= textNode.stringLength)
    precondition(index < parent.childCount && parent.getChild(index) === textNode)
    let newTextNode = textNode.inserted(string, at: offset)
    parent.replaceChild(newTextNode, at: index, inStorage: true)
  }

  /**
   Insert string into root node at `index`.
   - Returns: insertion point correction (i0, i1, i2) which is applicable when
      the initial insertion point is (rootNode, index).
      When applicable, the new insertion point becomes (rootNode, i0, i1, i2).
   - Throws: SatzError(.InsaneRootChild)
   - Warning: The function is used only when `inStorage=true`.
   */
  private static func insertString(
    _ string: String, rootNode: RootNode, index: Int
  ) throws -> (Int, Int, Int) {
    precondition(index <= rootNode.childCount)

    let childCount = rootNode.childCount
    // if there is no existing node to insert into, create a paragraph
    if childCount == 0 {
      let paragraph = ParagraphNode([TextNode(string)])
      rootNode.insertChild(paragraph, at: index, inStorage: true)
      return (index, 0, 0)
    }
    // if the index is the last index, add to the end of the last child
    else if index == childCount {
      assert(childCount > 0)
      guard let lastChild = rootNode.getChild(childCount - 1) as? ElementNode
      else { throw SatzError(.InvalidRootChild) }
      let (i0, i1) = insertString(
        string, elementNode: lastChild, index: lastChild.childCount)
      return (childCount - 1, i0, i1)
    }
    // otherwise, add to the start of index-th child
    else {
      guard let element = rootNode.getChild(index) as? ElementNode
      else { throw SatzError(.InvalidRootChild) }

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
        element.insertChild(TextNode(string), at: 0, inStorage: true)
        return (index, 0, 0)
      }
    }
  }

  /**
   Insert string into element node at `index`. This function is generally not
   for root node which requires special treatment.
   - Returns: inertion point correction (i0, i1) which is applicable when the
      initial insertion point is (elementNode, index).
      When applicable, the new insertion point becomes (elementNode, i0, i1).
   - Warning: The function is used only when `inStorage=true`.
   */
  private static func insertString(
    _ string: String, elementNode: ElementNode, index: Int
  ) -> (Int, Int) {
    precondition(elementNode.type != .root && index <= elementNode.childCount)

    let childCount = elementNode.childCount

    if index == childCount {
      // add to the end of the last child if it is a text node; otherwise,
      // create a new text node
      if childCount > 0,
        let textNode = elementNode.getChild(childCount - 1) as? TextNode
      {
        let characterCount = textNode.stringLength  // save in case text node is mutable
        insertString(
          string, textNode: textNode, offset: textNode.stringLength,
          elementNode, childCount - 1)
        return (childCount - 1, characterCount)
      }
      else {
        let textNode = TextNode(string)
        elementNode.insertChild(textNode, at: index, inStorage: true)
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
        let characterCount = textNode.stringLength  // save in case text node is mutable
        insertString(
          string, textNode: textNode, offset: textNode.stringLength,
          elementNode, index - 1)
        return (index - 1, characterCount)
      }
      else {
        let textNode = TextNode(string)
        elementNode.insertChild(textNode, at: index, inStorage: true)
        return (index, 0)
      }
    }
  }
}
