// Copyright 2024-2025 Lie Yan

import DequeModule
import Foundation
import _RopeModule

extension NodeUtils {
  /**
   Remove text range from tree.

   - Returns: `nil` if the resulting insertion point is `range.location`;
   the new insertion point otherwise.
   */
  static func removeTextRange(_ range: RhTextRange, _ tree: RootNode) throws -> TextLocation? {
    // precondition(NodeUtils.validateTextRange(range, tree))
    // assert(tree.isAllowedToBeEmpty)

    // trace nodes
    guard let trace = traceNodes(range.location, tree),
      let endTrace = traceNodes(range.endLocation, tree)
    else { throw SatzError(.InvalidTextRange) }
    // assert(!trace.isEmpty && !endTrace.isEmpty)

    // create initial out trace
    var outTrace = OutTrace(trace.map(\.index), isRectified: false)
    // do the actual removal
    let shouldRemove = try removeTextSubrange(trace[...], endTrace[...], nil, &outTrace)
    guard !shouldRemove else {
      throw SatzError(
        .GenericInternalError, message: "there is a bug in removeTextSubrange(...)")
    }

    // if outTrace is NOT rectified, return nil
    guard outTrace.isRectified else { return nil }
    // otherwise, create a new text location
    do {
      let outTrace = outTrace.trace
      guard let offset = outTrace.last?.index()
      else { throw SatzError(.InvalidTextLocation) }
      return TextLocation(outTrace.dropLast(), offset)
    }
  }

  private struct OutTrace {
    var trace: Array<RohanIndex>
    var isRectified: Bool

    init(_ trace: Array<RohanIndex>, isRectified: Bool = false) {
      self.trace = trace
      self.isRectified = isRectified
    }

    var count: Int { trace.count }
    subscript(index: Int) -> RohanIndex { trace[index] }

    mutating func rectify(_ i: Int, with index: Int...) {
      precondition(i < trace.count)
      trace.removeLast(trace.count - i)
      index.forEach { trace.append(.index($0)) }
      isRectified = true
    }

    mutating func rectify(_ i: Int, with result: (index: Int, offset: Int)) {
      self.rectify(i, with: result.index, result.offset)
    }
  }

  /**
   Remove text subrange.

   - Returns: true if node at (parent, index) should be removed by the caller;
    false otherwise.
   - Precondition: `outTrace` is accurate.
   - Postcondition: If the return value is false, `outTrace` is accurate.
    Otherwise, `outTrace[0, trace.startIndex)` is unchanged so that the caller
    can do rectification based on this assumption.
    The phrase __"outTrace is accurate"__ means that `outTrace` points to the
    target insertion point for the current tree. If the caller modifies the
    tree further, it should update `outTrace` accordingly.
   - Throws: SatzError(.InvalidTextLocation), SatzError(.ElementNodeExpected)
   */
  private static func removeTextSubrange(
    _ trace: ArraySlice<AnnotatedNode>,
    _ endTrace: ArraySlice<AnnotatedNode>,
    _ context: (parent: ElementNode, index: Int)?,
    _ outTrace: inout OutTrace
  ) throws -> Bool {
    precondition(!trace.isEmpty && !endTrace.isEmpty)
    precondition(trace.first!.node === endTrace.first!.node)
    precondition(context == nil || context!.parent.getChild(context!.index) === trace.first!.node)

    // postcondition
    defer { assert(outTrace.count >= trace.startIndex) }

    func isElementNode(_ node: Node) -> Bool { node is ElementNode }
    func isTextNode(_ node: Node) -> Bool { node is TextNode }
    func isRemainderMergeable(_ lhs: Node, _ rhs: Node) -> Bool {
      NodeType.isRemainderMergeable(lhs.nodeType, rhs.nodeType)
    }

    /**
     Remove range and rectify out trace.
     - Returns: true if the element node should be removed by the caller; false otherwise.
     - Precondition: `outTrace` is accurate. `outTrace` points to `(elementNode, range.lowerBound)`.
     - Postcondition: If return value is false, then `outTrace` is accurate.
      Otherwise, `outTrace[0, trace.startIndex)` is unchanged.
     */
    func removeSubrangeExt(
      _ range: Range<Int>,
      elementNode: ElementNode,
      _ outTrace: inout OutTrace
    ) -> Bool {
      if !elementNode.isAllowedToBeEmpty && range == 0..<elementNode.childCount {
        return true
      }
      else {
        removeSubrange(range, elementNode: elementNode)
          .map { outTrace.rectify(trace.startIndex, with: $0) }
        return false
      }
    }

    let node = trace.first!
    let endNode = endTrace.first!

    switch node.node {
    case let textNode as TextNode:
      guard let offset = node.index.index(),
        let endOffset = endNode.index.index()
      else { throw SatzError(.InvalidTextLocation) }
      guard let (parent, index) = context else { throw SatzError(.InsaneNodeContext) }
      // ASSERT: insertion point is at `(parent, index, offset)`
      // `removeSubrange(...)` respects the postcondition of this function.
      return removeSubrange(offset..<endOffset, textNode: textNode, parent, index)

    case let elementNode as ElementNode:
      guard let index = node.index.index(),
        let endIndex = endNode.index.index()
      else { throw SatzError(.InvalidTextLocation) }

      if trace.count == 1 && endTrace.count == 1 {  // we are at the last node
        // ASSERT: insertion point is at `(elementNode, index)`
        return removeSubrangeExt(index..<endIndex, elementNode: elementNode, &outTrace)
      }
      // ASSERT: start.count > 1 ∨ end.count > 1
      else if trace.count == 1 {  // ASSERT: end.count > 1
        assert(0..<elementNode.childCount ~= endIndex)

        let shouldRemoveEnd = try removeTextSubrangeEnd(endTrace.dropFirst(), elementNode, endIndex)
        if shouldRemoveEnd {
          // ASSERT: insertion point is at `(elementNode, index)`
          return removeSubrangeExt(index..<endIndex + 1, elementNode: elementNode, &outTrace)
        }
        else {
          // ASSERT: insertion point is at `(elementNode, index)`
          removeSubrange(index..<endIndex, elementNode: elementNode)
            .map { outTrace.rectify(trace.startIndex, with: $0) }
          return false
        }
      }
      else if endTrace.count == 1 {  // ASSERT: start.count > 1
        assert(0..<elementNode.childCount ~= index)
        // ASSERT: `outTrace` is accurate.
        let shouldRemoveStart = try removeTextSubrangeStart(
          trace.dropFirst(), elementNode, index, &outTrace)
        if shouldRemoveStart {
          // by postcondition of `removeTextSubrangeStart(...)`
          // ASSERT: `outTrace[0, trace.startIndex+1)` is unchanged.
          outTrace.rectify(trace.startIndex, with: index)
          // ASSERT: `outTrace` is accurate.
          return removeSubrangeExt(index..<endIndex, elementNode: elementNode, &outTrace)
        }
        else {
          assert(index < endIndex)
          // ASSERT: `outTrace` is accurate.
          // ASSERT: insertion point is at or deeper within `(elementNode, index)`
          _ = removeSubrange((index + 1)..<endIndex, elementNode: elementNode)
          // ASSERT: `outTrace` is accurate.
          return false
        }
      }
      else {  // ASSERT: start.count > 1 ∧ end.count > 1
        if index == endIndex {
          // ASSERT: `outTrace` is accurate.
          let shouldRemove = try removeTextSubrange(
            trace.dropFirst(), endTrace.dropFirst(), (elementNode, index), &outTrace)
          if shouldRemove {
            // by postcondition of `removeTextSubrange(...)`
            // ASSERT: `outTrace[0, trace.startIndex+1)` is unchanged.
            outTrace.rectify(trace.startIndex, with: index)
            // ASSERT: `outTrace` is accurate.
            return removeSubrangeExt(index..<index + 1, elementNode: elementNode, &outTrace)
          }
          else {
            // by postcondition of `removeTextSubrange(...)`
            // ASSERT: `outTrace` is accurate.
            return false
          }
        }
        // ASSERT: index < endIndex
        else {
          // ASSERT: `outTrace` is accurate.
          let shouldRemoveStart = try removeTextSubrangeStart(
            trace.dropFirst(), elementNode, index, &outTrace)
          let shouldRemoveEnd = try removeTextSubrangeEnd(
            endTrace.dropFirst(), elementNode, endIndex)

          switch (shouldRemoveStart, shouldRemoveEnd) {
          case (false, false):
            // by postcondition of `removeTextSubrangeStart(...)`
            // ASSERT: `outTrace` is accurate.
            let lhs = elementNode.getChild(index)
            let rhs = elementNode.getChild(endIndex)
            // if remainders are mergeable, move children of the right into the left
            if !isTextNode(lhs) && !isTextNode(rhs) && isRemainderMergeable(lhs, rhs) {
              guard let lhs = lhs as? ElementNode,
                let rhs = rhs as? ElementNode
              else { throw SatzError(.ElementNodeExpected) }
              // check presumption to apply rectified result
              let presumptionSatisfied: Bool = {
                trace.startIndex + 2 == outTrace.count
                  && outTrace[trace.startIndex + 1].index() == lhs.childCount
              }()
              // do move
              let children = rhs.takeChildren(inContentStorage: true)
              let rectifiedResult = appendChildren(contentsOf: children, elementNode: lhs)
              // do rectify
              if presumptionSatisfied && rectifiedResult != nil {
                outTrace.rectify(trace.startIndex, with: rectifiedResult!)
              }
              // ASSERT: `outTrace` is accurate.
              // remove directly without additional work
              elementNode.removeSubrange((index + 1)..<(endIndex + 1), inContentStorage: true)
              // ASSERT: `outTrace` is accurate.
            }
            else {
              // ASSERT: insertion point is at or deeper within `(elementNode, index)`
              _ = removeSubrange((index + 1)..<endIndex, elementNode: elementNode)
              // ASSERT: `outTrace` is accurate.
            }
            return false
          case (false, true):
            // ASSERT: insertion point is at or deeper within `(elementNode, index)`
            _ = removeSubrange((index + 1)..<(endIndex + 1), elementNode: elementNode)
            return false
          case (true, false):
            // ASSERT: `outTrace[0, trace.startIndex+1)` is unchanged.
            // ASSERT: insertion point is at `(elementNode, index)`
            let rectifiedResult = removeSubrange(index..<endIndex, elementNode: elementNode)
            if rectifiedResult != nil {
              outTrace.rectify(trace.startIndex, with: rectifiedResult!)
            }
            else {
              outTrace.rectify(trace.startIndex, with: index)
            }
            return false
          case (true, true):
            // ASSERT: `outTrace[0, trace.startIndex+1)` is unchanged.
            // ASSERT: insertion point is at `(elementNode, index)`
            outTrace.rectify(trace.startIndex, with: index)
            return removeSubrangeExt(index..<endIndex + 1, elementNode: elementNode, &outTrace)
          }
        }
      }

    default:
      var start = trace
      var end = endTrace
      var node: AnnotatedNode = node

      // invariant:
      //  a) node.node === end.first!.node
      //  b) node.index == end.first!.index

      // Returns true if the range is forked at the first node
      func isForked(_ start: ArraySlice<AnnotatedNode>, _ end: ArraySlice<AnnotatedNode>) -> Bool {
        start.first!.index != end.first!.index
      }

      // check invariant
      guard !isForked(start, end) else { throw SatzError(.InvalidTextLocation) }

      // assert(!isElementNode(node.node) && !isTextNode(node.node))
      repeat {
        // make progress
        start = start.dropFirst()
        end = end.dropFirst()
        node = start.first!
        // check invariant
        guard !isForked(start, end) else { throw SatzError(.InvalidTextLocation) }
      } while !isElementNode(node.node) && !isTextNode(node.node)

      // ASSERT: `outTrace` is accurate.
      let shouldRemove = try removeTextSubrange(start, end, nil, &outTrace)
      if shouldRemove {
        // ASSERT: `outTrace[0, trace.startIndex)` is unchanged.

        // At the moment, we only clear the element node. In the future, we may
        // propagate up the deletion to the parent node.
        guard let elementNode = node.node as? ElementNode
        else { throw SatzError(.ElementNodeExpected) }
        elementNode.removeSubrange(0..<elementNode.childCount, inContentStorage: true)
        outTrace.rectify(start.startIndex, with: 0)
        return false
      }
      else {
        // ASSERT: `outTrace` is accurate.
        return false
      }
    }
  }

  /**
   Remove the `[trace, end)` where `end` points to `(parent, index+1)`.

   - Returns: true if node at (parent, index) should be removed by the caller; false otherwise.
   - Precondition: `outTrace` is accurate.
   - Postcondition: If return value is false, then `outTrace` is accurate. Otherwise,
    `outTrace[0, trace.startIndex)` is unchanged.
   - Throws: SatzError(.ElementOrTextNodeExpected)
   */
  private static func removeTextSubrangeStart(
    _ trace: ArraySlice<AnnotatedNode>,
    _ parent: ElementNode, _ index: Int,
    _ outTrace: inout OutTrace
  ) throws -> Bool {
    precondition(!trace.isEmpty && trace.first!.node === parent.getChild(index))

    let node = trace.first!
    switch node.node {
    case let textNode as TextNode:
      guard let offset = node.index.index() else { throw SatzError(.InvalidTextLocation) }
      // ASSERT: insertion point is at `(parent, index, offset)`
      return removeSubrange(offset..<textNode.characterCount, textNode: textNode, parent, index)
    case let elementNode as ElementNode:
      guard let index = node.index.index() else { throw SatzError(.InvalidTextLocation) }
      if trace.count == 1 {
        // ASSERT: insertion point is at `(elementNode, index)`
        // Since we remove the whole part to the right, no need to update outTrace.
        return NodeUtils.removeSubrangeExt(index..<elementNode.childCount, elementNode: elementNode)
      }
      else {
        assert(trace.count > 1)
        // ASSERT: outTrace is accurate.
        let shouldRemoveStart = try removeTextSubrangeStart(
          trace.dropFirst(), elementNode, index, &outTrace)

        if shouldRemoveStart {
          // ASSERT: outTrace[0, trace.startIndex)` is unchanged.
          outTrace.rectify(trace.startIndex, with: index)
          // Since we remove the whole part to the right, no need to update outTrace.
          return NodeUtils.removeSubrangeExt(
            index..<elementNode.childCount, elementNode: elementNode)
        }
        else {
          // ASSERT: outTrace is accurate.
          // Since we remove the whole part to the right, no need to update outTrace.
          _ = removeSubrange((index + 1)..<elementNode.childCount, elementNode: elementNode)
          return false
        }
      }
    default:
      throw SatzError(.ElementOrTextNodeExpected)
    }
  }

  /**
   Remove the `[0, last)` where `last` is the initial node in `trace`.
   - Returns: true if node at (parent, index) should be removed by the caller;
    false otherwise.
   - Throws: SatzError(.ElementOrTextNodeExpected)
   */
  static func removeTextSubrangeEnd(
    _ endTrace: ArraySlice<AnnotatedNode>, _ parent: ElementNode, _ index: Int
  ) throws -> Bool {
    precondition(!endTrace.isEmpty)
    precondition(endTrace.first!.node === parent.getChild(index))

    let endNode = endTrace.first!
    switch endNode.node {
    case let textNode as TextNode:
      guard let endOffset = endNode.index.index()
      else { throw SatzError(.InvalidTextLocation) }
      return removeSubrange(0..<endOffset, textNode: textNode, parent, index)

    case let elementNode as ElementNode:
      guard let endIndex = endNode.index.index()
      else { throw SatzError(.InvalidTextLocation) }

      if endTrace.count == 1 {
        return removeSubrangeExt(0..<endIndex, elementNode: elementNode)
      }
      else {
        // assert(endTrace.count > 1)
        let shouldRemoveEnd = try removeTextSubrangeEnd(endTrace.dropFirst(), elementNode, endIndex)
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
  static func removeSubrangeExt(_ range: Range<Int>, elementNode: ElementNode) -> Bool {
    if !elementNode.isAllowedToBeEmpty && range == 0..<elementNode.childCount {
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
      // NOTE:  the rectified insertion point: (previous, lhs.characterCount)
      let rectifiedResult = (previous, lhs.characterCount)

      // concate and replace text nodes
      let string = StringUtils.concate(lhs.bigString, rhs.bigString)
      let newTextNode = TextNode(string)
      elementNode.replaceChild(newTextNode, at: previous, inContentStorage: true)
      // remove range
      let newRange = range.lowerBound..<range.upperBound + 1
      elementNode.removeSubrange(newRange, inContentStorage: true)

      return rectifiedResult
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
  static func appendChildren(
    contentsOf nodes: [Node], elementNode: ElementNode
  ) -> (index: Int, offset: Int)? {
    guard !nodes.isEmpty else { return nil }

    if elementNode.childCount != 0,
      let previous = elementNode.getChild(elementNode.childCount - 1) as? TextNode,
      let next = nodes.first as? TextNode
    {
      // NOTE:  the rectified insertion point: (elementNode.childCount-1, lhs.characterCount)
      let rectifiedResult = (elementNode.childCount - 1, previous.characterCount)

      // merge previous and next
      let string = StringUtils.splice(previous.bigString, previous.characterCount, next.bigString)
      let newTextNode = TextNode(string)
      elementNode.replaceChild(newTextNode, at: elementNode.childCount - 1, inContentStorage: true)
      // Reallocate the node ids (which is necessary) for the rest
      nodes.dropFirst().forEach { $0.reallocateId() }
      // append the rest
      elementNode.insertChildren(
        contentsOf: nodes.dropFirst(), at: elementNode.childCount, inContentStorage: true)
      // return the new insertion point
      return rectifiedResult
    }
    else {
      // reallocate the node ids (which is necessary)
      nodes.forEach { $0.reallocateId() }
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
    if (0..<textNode.characterCount) == range {
      return true
    }
    else if !range.isEmpty {
      let string = StringUtils.splice(textNode.bigString, range, nil)
      parent.replaceChild(TextNode(string), at: index, inContentStorage: true)
    }
    return false
  }
}
