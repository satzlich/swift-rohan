// Copyright 2024-2025 Lie Yan

import Foundation

enum NodeUtils {
  /**
   Trace nodes along given location from root node so that each index/offset is
   paired with its parent node.
   - Returns: the trace elements if the location is valid; otherwise, `nil`.
   */
  static func traceNodes(_ location: TextLocation, _ tree: RootNode) -> [TraceElement]? {
    var trace = [TraceElement]()
    trace.reserveCapacity(location.indices.count + 1)

    var node: Node = tree
    for index in location.indices {
      guard let child = node.getChild(index) else { return nil }
      trace.append(TraceElement(node, index))
      node = child
    }
    guard validateOffset(location.offset, node) else { return nil }
    trace.append(TraceElement(node, .index(location.offset)))
    return trace
  }

  /**
   Trace nodes along given location from subtree so that each index is paired
   with its parent node until predicate is satisfied, or the path is exhausted.

   - Postcondition: In the case that tracing is interrupted by `predicate`,
    trace.last!.getChild() = truthMaker ∧ predicate(truthMaker) ∧
    trace.dropLast().map(\.getChild()).allSatisfy(!predicate)
   */
  static func traceNodes(
    _ location: PartialLocation, _ subtree: Node, until predicate: (Node) -> Bool
  ) -> ([TraceElement], truthMaker: Node?)? {
    var trace = [TraceElement]()
    trace.reserveCapacity(location.indices.count + 1)

    var node: Node = subtree
    for index in location.indices {
      guard let child = node.getChild(index) else { return nil }
      trace.append(TraceElement(node, index))
      // check predicate
      if predicate(child) {
        return (trace, child)
      }
      node = child
    }
    guard validateOffset(location.offset, node) else { return nil }
    trace.append(TraceElement(node, .index(location.offset)))
    return (trace, nil)
  }

  /**
   Trace nodes along given path from subtree so that each index is paired with
   its parent node.

   - Returns: the (quasi-valid) trace elements; otherwise, `nil`.
   - Note: By __quasi-valid__, we mean that the trace is valid except for the last
            element, which may be out of bound for `getChild()` method.
   */
  static func traceNodes(_ path: ArraySlice<RohanIndex>, _ subtree: Node) -> [TraceElement]? {
    // empty path is valid, so return []
    guard !path.isEmpty else { return [] }

    var trace = [TraceElement]()
    trace.reserveCapacity(path.count)

    var node: Node = subtree
    for index in path.dropLast() {
      guard let child = node.getChild(index) else { return nil }
      trace.append(TraceElement(node, index))
      node = child
    }
    trace.append(TraceElement(node, path[path.endIndex - 1]))
    return trace
  }

  /**
   Trace nodes that contain `[layoutOffset, _ + 1)` from subtree until meeting
   a character of text node or a __pivotal__ child.

   - Returns: the trace elements if the layout offset is valid; otherwise, `nil`.
   */
  static func traceNodes(_ layoutOffset: Int, _ subtree: Node) -> ([TraceElement], consumed: Int)? {
    guard 0..<subtree.layoutLength ~= layoutOffset else { return nil }

    var result: [TraceElement] = []

    var node = subtree
    var unconsumed = layoutOffset
    while true {
      guard let (index, consumed) = node.getRohanIndex(unconsumed) else { break }
      // add element and update unconsumed
      result.append(TraceElement(node, index))
      unconsumed -= consumed
      // NOTE: for text node, `getChild(_:)` always returns nil
      guard let child = node.getChild(index), !child.isPivotal else { break }
      // make progress
      node = child
    }
    return (result, layoutOffset - unconsumed)
  }

  /**
   Build __normalized__ location from trace.
   - Note: By __"normalized"__, we mean (a) the location must be placed within a child
    of root node unless the root node is empty; (b) the offset must be placed within
    a text node unless there is no text node available around.
   */
  static func buildLocation(from trace: [TraceElement]) -> TextLocation? {
    // ensure there is a last element and its index is the kind of normal
    guard let last = trace.last,
      let offset = last.index.index()
    else { return nil }
    // get the path excluding the last element
    var path = trace.dropLast().map(\.index)

    // fix the last node if it is root node
    if let rootNode = last.node as? RootNode {
      if rootNode.childCount == 0 {
        return TextLocation(path, offset)
      }
      else if offset < rootNode.childCount {
        path.append(.index(offset))
        let child = rootNode.getChild(offset) as! ElementNode
        return fixLast(child, 0)
      }
      else {
        path.append(.index(rootNode.childCount - 1))
        let child = rootNode.getChild(rootNode.childCount - 1) as! ElementNode
        return fixLast(child, child.childCount)
      }
    }
    // fix node of other kinds
    else {
      return fixLast(last.node, offset)
    }

    func fixLast(_ node: Node, _ offset: Int) -> TextLocation {
      switch node {
      case let elementNode as ElementNode:
        if offset < elementNode.childCount,
          elementNode.getChild(offset) is TextNode
        {
          path.append(.index(offset))
          return TextLocation(path, 0)
        }
        else if offset > 0,
          let textNode = elementNode.getChild(offset - 1) as? TextNode
        {
          path.append(.index(offset - 1))
          return TextLocation(path, textNode.stringLength)
        }
      // FALL THROUGH
      case let argumentNode as ArgumentNode:
        if offset < argumentNode.childCount,
          argumentNode.getChild(offset) is TextNode
        {
          path.append(.index(offset))
          return TextLocation(path, 0)
        }
        else if offset > 0,
          let textNode = argumentNode.getChild(offset - 1) as? TextNode
        {
          path.append(.index(offset - 1))
          return TextLocation(path, textNode.stringLength)
        }
      // FALL THROUGH
      default:
        break
      // FALL THROUGH
      }

      return TextLocation(path, offset)
    }
  }
}
