// Copyright 2024-2025 Lie Yan

import DequeModule
import Foundation
import _RopeModule

extension NodeUtils {
  /**
   Remove text range from tree.
   - Returns: `nil` if the resulting insertion point is `range.location`;
   the new insertion point otherwise.
   - Throws: SatzError(.InvalidTextLocation), SatzError(.InvalidTextRange)
   */
  static func removeTextRange(_ range: RhTextRange, _ tree: RootNode) throws -> TextLocation? {
    // precondition(NodeUtils.validateTextRange(range, tree))

    let location = range.location.asPartialLocation
    let endLocation = range.endLocation.asPartialLocation
    var insertionPoint = InsertionPoint(range.location.asPath, isRectified: false)

    // do the actual removal
    _ = try removeTextSubrange(location, endLocation, tree, nil, &insertionPoint)
    // ASSERT: _ == false

    guard insertionPoint.isRectified else { return nil }
    if let newLocation = insertionPoint.asTextLocation {
      return newLocation
    }
    else {
      throw SatzError(.InvalidTextLocation)
    }
  }

  /**
   Remove text subrange.

   - Returns: true if `subtree` at (parent, index) should be removed by the caller;
    false otherwise.
   - Precondition: `insertionPoint` is accurate.
   - Postcondition: If the return value is false, `insertionPoint` is accurate.
    Otherwise, `insertionPoint[0, location.indices.startIndex)` is unchanged so
    that the caller can do rectification based on this assumption.
    The phrase __"insertionPoint is accurate"__ means that `insertionPoint`
    points to the target insertion point for the current tree. If the caller
    modifies the tree further, it should update `insertionPoint` accordingly.
   - Throws: SatzError(.InvalidTextLocation), SatzError(.ElementNodeExpected)
   */
  static func removeTextSubrange(
    _ location: PartialLocation, _ endLocation: PartialLocation,
    _ subtree: Node, _ context: (parent: ElementNode, index: Int)?,
    _ insertionPoint: inout InsertionPoint
  ) throws -> Bool {
    // postcondition
    defer { assert(insertionPoint.path.count >= location.indices.startIndex) }

    func isElementNode(_ node: Node) -> Bool { node is ElementNode }
    func isTextNode(_ node: Node) -> Bool { node is TextNode }
    func isRemainderMergeable(_ lhs: Node, _ rhs: Node) -> Bool {
      NodeType.isRemainderMergeable(lhs.nodeType, rhs.nodeType)
    }

    /**
     Remove range and rectify insertion point.
     - Returns: true if the element node should be removed by the caller; false otherwise.
     - Precondition: `insertionPoint` is accurate. `insertionPoint` points to
      `(elementNode, range.lowerBound)`.
     - Postcondition: If return value is false, then `insertionPoint` is accurate.
      Otherwise, `insertionPoint[0, location.indices.startIndex)` is unchanged.
     */
    func removeSubrangeExt(
      _ range: Range<Int>, elementNode: ElementNode, _ insertionPoint: inout InsertionPoint
    ) -> Bool {
      if !elementNode.isVoidable && range == 0..<elementNode.childCount {
        return true
      }
      else {
        let correction = removeSubrange(range, elementNode: elementNode)
        if let (index, offset) = correction {
          insertionPoint.rectify(location.indices.startIndex, with: index, offset)
        }
        return false
      }
    }

    switch subtree {
    case let textNode as TextNode:
      assert(location.indices.isEmpty && endLocation.indices.isEmpty)
      guard let (parent, index) = context else { throw SatzError(.UnexpectedArgument) }
      let range = location.offset..<endLocation.offset
      // ASSERT: insertion point is at `(parent, index, offset)`
      // `removeSubrange(...)` respects the postcondition of this function.
      return removeSubrange(range, textNode: textNode, parent, index)

    case let elementNode as ElementNode:
      if location.count == 1 && endLocation.count == 1 {  // we are at the last node
        // ASSERT: insertion point is at `(elementNode, index)`
        let range = location.offset..<endLocation.offset
        return removeSubrangeExt(range, elementNode: elementNode, &insertionPoint)
      }
      // ASSERT: location.count > 1 ∨ endLocation.count > 1
      else if location.count == 1 {  // ASSERT: endLocation.count > 1
        let index = location.offset
        guard let endIndex = endLocation.indices.first?.index()
        else { throw SatzError(.InvalidTextLocation) }
        assert(0..<elementNode.childCount ~= endIndex)

        let endChild = elementNode.getChild(endIndex)
        let shouldRemoveEnd = try removeTextSubrangeEnd(
          endLocation.dropFirst(), endChild, elementNode, endIndex)
        if shouldRemoveEnd {
          // ASSERT: insertion point is at `(elementNode, index)`
          let range = index..<endIndex + 1
          return removeSubrangeExt(range, elementNode: elementNode, &insertionPoint)
        }
        else {
          // ASSERT: insertion point is at `(elementNode, index)`
          let correction = removeSubrange(index..<endIndex, elementNode: elementNode)
          if let (index, offset) = correction {
            insertionPoint.rectify(location.indices.startIndex, with: index, offset)
          }
          return false
        }
      }
      else if endLocation.count == 1 {  // ASSERT: location.count > 1
        guard let index = location.indices.first?.index()
        else { throw SatzError(.InvalidTextLocation) }
        assert(0..<elementNode.childCount ~= index)
        let endIndex = endLocation.offset
        let child = elementNode.getChild(index)
        // ASSERT: `insertionPoint` is accurate.
        let shouldRemoveStart = try removeTextSubrangeStart(
          location.dropFirst(), child, elementNode, index, &insertionPoint)
        if shouldRemoveStart {
          // ASSERT: by postcondition of `removeTextSubrangeStart(...)`,
          // `insertionPoint[0, location.indices.startIndex+1)` is unchanged.
          insertionPoint.rectify(location.indices.startIndex, with: index)
          // ASSERT: `insertionPoint` is accurate.
          let range = index..<endIndex
          return removeSubrangeExt(range, elementNode: elementNode, &insertionPoint)
        }
        else {
          assert(index < endIndex)
          // ASSERT: `insertionPoint` is accurate.
          // ASSERT: insertion point is at or deeper within `(elementNode, index)`
          _ = removeSubrange((index + 1)..<endIndex, elementNode: elementNode)
          // ASSERT: `insertionPoint` is accurate.
          return false
        }
      }
      else {  // ASSERT: location.count > 1 ∧ endLocation.count > 1
        guard let index = location.indices.first?.index(),
          let endIndex = endLocation.indices.first?.index()
        else { throw SatzError(.InvalidTextLocation) }

        assert(0..<elementNode.childCount ~= index)
        assert(0..<elementNode.childCount ~= endIndex)

        if index == endIndex {
          let child = elementNode.getChild(index)
          // ASSERT: `insertionPoint` is accurate.
          let shouldRemove = try removeTextSubrange(
            location.dropFirst(), endLocation.dropFirst(), child, (elementNode, index),
            &insertionPoint)
          if shouldRemove {
            // ASSERT: by postcondition of `removeTextSubrange(...)`,
            // `insertionPoint[0, location.indices.startIndex+1)` is unchanged.
            insertionPoint.rectify(location.indices.startIndex, with: index)
            // ASSERT: `insertionPoint` is accurate.
            let range = index..<index + 1
            return removeSubrangeExt(range, elementNode: elementNode, &insertionPoint)
          }
          else {
            // ASSERT: by postcondition of `removeTextSubrange(...)`,
            // `insertionPoint` is accurate.
            return false
          }
        }
        // ASSERT: index < endIndex
        else {
          // ASSERT: `insertionPoint` is accurate.

          let child = elementNode.getChild(index)
          let endChild = elementNode.getChild(endIndex)

          // IMPORTANT: make snapshot before modification due to potential merge
          elementNode.makeSnapshotOnce()

          let shouldRemoveStart = try removeTextSubrangeStart(
            location.dropFirst(), child, elementNode, index, &insertionPoint)
          let shouldRemoveEnd = try removeTextSubrangeEnd(
            endLocation.dropFirst(), endChild, elementNode, endIndex)

          switch (shouldRemoveStart, shouldRemoveEnd) {
          case (false, false):
            // ASSERT: by postcondition of `removeTextSubrangeStart(...)`,
            // `insertionPoint` is accurate.

            // convenience alias
            let lhs = child
            let rhs = endChild
            // if remainders are mergeable, move children of the right into the left
            if !isTextNode(lhs) && !isTextNode(rhs) && isRemainderMergeable(lhs, rhs) {
              guard let lhs = lhs as? ElementNode,
                let rhs = rhs as? ElementNode
              else { throw SatzError(.ElementNodeExpected) }
              // check presumption to apply correction
              let presumptionSatisfied: Bool = {
                // path index for the index into lhs
                let pathIndex = location.indices.startIndex + 1
                // true if insertion point is at the right end of lhs.
                // Only in this case, we can apply correction.
                return pathIndex == insertionPoint.path.count - 1
                  && insertionPoint.path[pathIndex].index() == lhs.childCount
              }()

              // do move/merge
              do {
                // take children from rhs
                let children = rhs.takeChildren(inContentStorage: true)
                // append children to lhs
                let correction = appendChildren(contentsOf: children, elementNode: lhs)
                // rectify insertion point if necessary
                if presumptionSatisfied, let (index, offset) = correction {
                  insertionPoint.rectify(location.indices.startIndex, with: index, offset)
                }
              }
              // ASSERT: `insertionPoint` is accurate.
              // remove directly without additional work
              elementNode.removeSubrange(index + 1..<endIndex + 1, inContentStorage: true)
              // ASSERT: `insertionPoint` is accurate.
            }
            else {
              // ASSERT: insertion point is at or deeper within `(elementNode, index)`
              _ = removeSubrange(index + 1..<endIndex, elementNode: elementNode)
              // ASSERT: `insertionPoint` is accurate.
            }
            return false
          case (false, true):
            // ASSERT: insertion point is at or deeper within `(elementNode, index)`
            _ = removeSubrange(index + 1..<endIndex + 1, elementNode: elementNode)
            return false
          case (true, false):
            // ASSERT: `insertionPoint[0, location.indices.startIndex+1)` is unchanged.
            // NOTE: insertion point should be `(elementNode, index)` but immediate
            //  rectify is saved
            let correction = removeSubrange(index..<endIndex, elementNode: elementNode)
            if let (index, offset) = correction {
              insertionPoint.rectify(location.indices.startIndex, with: index, offset)
            }
            else {
              insertionPoint.rectify(location.indices.startIndex, with: index)
            }
            return false
          case (true, true):
            // ASSERT: `insertionPoint[0, location.indices.startIndex+1)` is unchanged.
            // ASSERT: insertion point is at `(elementNode, index)`
            insertionPoint.rectify(location.indices.startIndex, with: index)
            let range = index..<endIndex + 1
            return removeSubrangeExt(range, elementNode: elementNode, &insertionPoint)
          }
        }
      }

    case let applyNode as ApplyNode:
      guard let index = location.indices.first?.argumentIndex(),
        let endIndex = endLocation.indices.first?.argumentIndex(),
        index == endIndex,
        0..<applyNode.argumentCount ~= index
      else { throw SatzError(.InvalidTextLocation) }
      let argumentNode = applyNode.getArgument(index)
      try argumentNode.removeSubrange(
        location.dropFirst(), endLocation.dropFirst(), &insertionPoint)

      // Apply node is never removed due to modification of its argument.
      return false

    default:
      var node: Node = subtree
      var location: PartialLocation = location
      var endLocation: PartialLocation = endLocation

      func isForked(_ location: PartialLocation, _ endLocation: PartialLocation) -> Bool {
        location.indices.first! != endLocation.indices.first!
      }

      repeat {
        // check invariant
        guard location.count > 1 && endLocation.count > 1,
          !isForked(location, endLocation)
        else { throw SatzError(.InvalidTextLocation) }
        // make progress
        guard let child = node.getChild(location.indices.first!)
        else { throw SatzError(.InvalidTextLocation) }
        node = child
        location = location.dropFirst()
        endLocation = endLocation.dropFirst()
      } while !isElementNode(node) && !isTextNode(node)
      // NOTE: ArgumentNode is dealt with in the case of ApplyNode

      // ASSERT: `insertionPoint` is accurate.
      let shouldRemove = try removeTextSubrange(
        location, endLocation, node, nil, &insertionPoint)
      if shouldRemove {
        // ASSERT: `insertionPoint[0, location.indices.startIndex)` is unchanged.

        // At the moment, we only clear the element node. In the future, we may
        // propagate up the deletion to the parent node.
        guard let elementNode = node as? ElementNode
        else { throw SatzError(.ElementNodeExpected) }
        elementNode.removeSubrange(0..<elementNode.childCount, inContentStorage: true)
        insertionPoint.rectify(location.indices.startIndex, with: 0)
        return false
      }
      else {
        // ASSERT: `insertionPoint` is accurate.
        return false
      }
    }
  }

  /**
   Remove `[location, virtualEnd)` where `virtualEnd` is equivalent to `(parent, index+1)`.

   - Returns: true if node at `(parent, index)` should be removed by the caller;
    false otherwise.
   - Precondition: `insertionPoint` is accurate.
   - Postcondition: If the return value is false, `insertionPoint` is accurate.
    Otherwise, `insertionPoint[0, location.indices.startIndex)` is unchanged.
   - Throws: SatzError(.ElementorTextNodeExpected)
   */
  private static func removeTextSubrangeStart(
    _ location: PartialLocation, _ subtree: Node,
    _ parent: ElementNode, _ index: Int, _ insertionPoint: inout InsertionPoint
  ) throws -> Bool {
    precondition(parent.getChild(index) === subtree)

    switch subtree {
    case let textNode as TextNode:
      // ASSERT: insertion point is at `(parent, index, offset)`
      let range = location.offset..<textNode.stringLength
      return removeSubrange(range, textNode: textNode, parent, index)

    case let elementNode as ElementNode:
      if location.count == 1 {
        // ASSERT: insertion point is at `(elementNode, location.offset)`
        let range = location.offset..<elementNode.childCount
        // Since we remove the whole part to the right, no need to update insertion point.
        return removeSubrangeExt(range, elementNode: elementNode)
      }
      else {
        // ASSERT: insertion point is accurate.

        guard let index = location.indices.first?.index(),
          0..<elementNode.childCount ~= index
        else { throw SatzError(.InvalidTextLocation) }
        let child = elementNode.getChild(index)

        let shouldRemoveStart = try removeTextSubrangeStart(
          location.dropFirst(), child, elementNode, index, &insertionPoint)

        if shouldRemoveStart {
          // ASSERT: insertionPoint[0, location.indices.startIndex)` is unchanged.
          insertionPoint.rectify(location.indices.startIndex, with: index)
          // Since we remove the whole part to the right of index, no need to
          // update insertion point.
          let range = index..<elementNode.childCount
          return removeSubrangeExt(range, elementNode: elementNode)
        }
        else {
          // ASSERT: insertion point is accurate.
          // Since we remove the whole part to the right of index, no need to
          // update insertion point.
          let range = index + 1..<elementNode.childCount
          _ = removeSubrange(range, elementNode: elementNode)
          return false
        }
      }

    default:
      throw SatzError(.ElementOrTextNodeExpected)
    }
  }

  /**
   Remove `[0, endLocation)` recursively bottom up.

   - Returns: true if node at `(parent, index)` should be removed by the caller;
    false otherwise.
   - Throws: SatzError(.ElementOrTextNodeExpected)
   */
  private static func removeTextSubrangeEnd(
    _ endLocation: PartialLocation, _ subtree: Node, _ parent: ElementNode, _ index: Int
  ) throws -> Bool {
    precondition(parent.getChild(index) === subtree)

    switch subtree {
    case let textNode as TextNode:
      return removeSubrange(0..<endLocation.offset, textNode: textNode, parent, index)

    case let elementNode as ElementNode:
      if endLocation.count == 1 {
        return removeSubrangeExt(0..<endLocation.offset, elementNode: elementNode)
      }
      else {
        guard let endIndex = endLocation.indices.first?.index(),
          0..<elementNode.childCount ~= endIndex
        else { throw SatzError(.InvalidTextLocation) }

        let endChild = elementNode.getChild(endIndex)
        let shouldRemoveEnd = try removeTextSubrangeEnd(
          endLocation.dropFirst(), endChild, elementNode, endIndex)
        if shouldRemoveEnd {
          return removeSubrangeExt(0..<endIndex + 1, elementNode: elementNode)
        }
        else {
          _ = removeSubrange(0..<endIndex, elementNode: elementNode)
          return false
        }
      }

    default:
      throw SatzError(.ElementOrTextNodeExpected)
    }
  }

  /**
   Remove subrange from element node and merge the previous and the next if possible.
   - Returns: true if node at (parent, index) should be removed by the caller;
    false otherwise.
   */
  private static func removeSubrangeExt(_ range: Range<Int>, elementNode: ElementNode) -> Bool {
    if !elementNode.isVoidable && range == 0..<elementNode.childCount {
      return true
    }
    else {
      _ = removeSubrange(range, elementNode: elementNode)
      return false
    }
  }

  /**
   Remove subrange from element node and merge the previous and the next if possible.

   - Returns: Under the supposition that the insertion point is
    at `(elementNode, range.lowerBound)`, return the new insertion point if
    it is different from `(elementNode, range.lowerBound)`, in the form of
    `(index, offset)` where `index` points to a child in `elementNode`, and
    `offset` is the offset within the child; `nil` otherwise.
   - Invariant: Under the supposition that `(elementNode, range.lowerBound-1)`
    exists, and the insertion point is at or deeper within `(elementNode, range.lowerBound-1)`,
    that insertion point remains valid on return.

   - Warning: The function is used in ``ContentStorage`` only.
   */
  private static func removeSubrange(
    _ range: Range<Int>, elementNode: ElementNode
  ) -> (index: Int, offset: Int)? {
    precondition(range.upperBound <= elementNode.childCount)

    // do nothing if range is empty
    guard !range.isEmpty else { return nil }

    // get nodes before and after the range
    let previous = range.lowerBound > 0 ? range.lowerBound - 1 : nil
    let next = range.upperBound < elementNode.childCount ? range.upperBound : nil

    // if there is a previous node and a next node, and they are both text
    // nodes, merge them
    if let previous,
      let next,
      let lhs = elementNode.getChild(previous) as? TextNode,
      let rhs = elementNode.getChild(next) as? TextNode
    {
      let correction = (previous, lhs.stringLength)

      // concate and replace text nodes
      let string = StringUtils.concate(lhs.bigString, rhs.bigString)
      let newTextNode = TextNode(string)
      elementNode.replaceChild(newTextNode, at: previous, inContentStorage: true)
      // remove range
      let newRange = range.lowerBound..<range.upperBound + 1
      elementNode.removeSubrange(newRange, inContentStorage: true)

      return correction
    }
    else {
      // remove range
      elementNode.removeSubrange(range, inContentStorage: true)
      return nil
    }
  }

  /**
   Append nodes into element node.

   - Returns: Under the supposition that the insertion point is at
    `(elementNode, elementNode.childCount)`, return the new insertion point
    if it is different from `(elementNode, elementNode.childCount)`, in the
    form of `(index, offset)` where `index` points to a child in `elementNode`,
    and `offset` is the offset within the child; `nil` otherwise.
   - Invariant: Under the supposition that `(elementNode, elementNode.childCount-1)`,
    exists, and the insertion point is at or deeper within
    `(elementNode, elementNode.childCount-1)`, that insertion point remains valid on return.
   */
  private static func appendChildren<S>(
    contentsOf nodes: S, elementNode: ElementNode
  ) -> (index: Int, offset: Int)?
  where S: Collection, S.Element == Node {
    guard !nodes.isEmpty else { return nil }

    if elementNode.childCount != 0,
      let previous = elementNode.getChild(elementNode.childCount - 1) as? TextNode,
      let next = nodes.first as? TextNode
    {
      let correction = (elementNode.childCount - 1, previous.stringLength)

      // merge previous and next
      let string = StringUtils.splice(previous.bigString, previous.stringLength, next.bigString)
      let newTextNode = TextNode(string)
      elementNode.replaceChild(newTextNode, at: elementNode.childCount - 1, inContentStorage: true)
      // append the rest
      elementNode.insertChildren(
        contentsOf: nodes.dropFirst(), at: elementNode.childCount, inContentStorage: true)

      return correction
    }
    else {
      // append
      elementNode.insertChildren(
        contentsOf: nodes, at: elementNode.childCount, inContentStorage: true)
      return nil
    }
  }

  /**
   Remove range from text node.
   - Parameters:
     - range: the range to remove
     - textNode: the text node
     - parent: the parent of `textNode`
     - index: the index of `textNode` in `parent`
   - Returns: true if the text node should be removed by the caller; false otherwise
   - Postcondition: An insertion point that points to `[index, range.lowerBound]`
    remains valid when the return value is false. Otherwise, an insertion point
    that points to `[index]` remains valid.
   */
  private static func removeSubrange(
    _ range: Range<Int>, textNode: TextNode,
    _ parent: ElementNode, _ index: Int
  ) -> Bool {
    precondition(parent.getChild(index) === textNode)
    if (0..<textNode.stringLength) == range {
      return true
    }
    else if !range.isEmpty {
      let string = StringUtils.splice(textNode.bigString, range, nil)
      parent.replaceChild(TextNode(string), at: index, inContentStorage: true)
    }
    return false
  }
}
