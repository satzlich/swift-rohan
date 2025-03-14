// Copyright 2024-2025 Lie Yan

import Foundation

enum NodeUtils {
  /**
   Trace nodes along given location from root node so that each index/offset is
   paired with its parent node.
   - Returns: the trace elements if the location is valid; otherwise, `nil`.
   */
  static func buildTrace(for location: TextLocation, _ tree: RootNode) -> [TraceElement]?
  {
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
   Obtain node at the given location specified by path from subtree.
   - Note: This method is used for supporting template.
   */
  static func getNode(at path: [RohanIndex], _ subtree: ElementNode) -> Node? {
    // empty path is valid, so return subtree directly
    guard !path.isEmpty else { return subtree }
    var node: Node = subtree
    for index in path.dropLast() {
      guard let child = node.getChild(index) else { return nil }
      node = child
    }
    return node.getChild(path[path.endIndex - 1])
  }

  /**
   Trace nodes along given location from subtree so that each index is paired
   with its parent node until predicate is satisfied, or the path is exhausted.

   - Returns: the trace elements if the location is valid; or `nil` otherwise.

   - Postcondition: Assumming the location is valid, the following holds:
      (a) In the case that tracing is interrupted by `predicate`,
      `truthMaker` equals the node that satisfies the predicate. And further,
      `trace.last!.getChild() = truthMaker` ∧ `predicate(truthMaker)` ∧
      `trace.dropLast().map(\.getChild()).allSatisfy(!predicate)`.
      (b) Otherwise, `truthMaker` is `nil`.
   */
  static func tryBuildTrace(
    for location: PartialLocation, _ subtree: ElementNode, until predicate: (Node) -> Bool
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
   Trace nodes that contain `[layoutOffset, _ + 1)` from subtree so that either
   of the following holds:
   (a) the node of the last trace element is a text node, and the other nodes
       in the interior of the trace are not __interrupting__.
       This is a must as we want to use this method to locate with layout offset
       a character in text node from an ElementNode.
   (b) a child can be obtained from the last trace element, and that child is
        __interrupting__.

   - Note: A node is __interrupting__ if it is a __pivotal__ node or a node with
      no child, either a __simple__ node which cannot have a child or an
      element node with no child.
   - Note: ApplyNode, EquationNode, FractionNode are pivotal nodes. UnknownNode
      is a simple node. TextNode is not simple.
   - Returns: the trace elements if the layout offset is valid; otherwise, `nil`.
   */
  static func tryBuildTrace(
    from layoutOffset: Int, _ subtree: ElementNode
  ) -> ([TraceElement], consumed: Int)? {

    guard 0..<subtree.layoutLength ~= layoutOffset else { return nil }

    var trace: [TraceElement] = []
    var node: Node = subtree
    var unconsumed = layoutOffset

    /* let n := trace.count
     Invariant:
          n=0 ⇒ true
          n=1 ⇒ trace[0].node = subtree
          n>1 ⇒ trace[0].node = subtree ∧
              ∀x:trace[1..<n-1]:((x.node is not pivotal) ∧ (x.node has child))
     On exit:
          trace[n-1].node is a text node ∨
          trace[n-1].getChild() is a pivotal node or a node with no child.
     */
    while true {
      // For method `getRohanIndex(_:)`,
      // (a) TextNode always return non-nil;
      // (b) EleemntNode returns non-nil iff it has child;
      // (c) "SimpleNode" always return nil.
      guard let (index, consumed) = node.getRohanIndex(unconsumed) else { break }
      assert(isElementNode(node) || isTextNode(node))
      // add trace element, that is, n ← n + 1
      trace.append(TraceElement(node, index))
      // update unconsumed
      unconsumed -= consumed
      // For method `getChild(_:)` and index obtained with `getRohanIndex(_:)`,
      //  (i) ElementNode always return non-nil;
      // (ii) TextNode always return nil.
      guard let child = node.getChild(index),
        !child.isPivotal
      else { break }
      // ASSERT: ¬(child is pivotal)
      // ApplyNode, MathNode's are pivotal nodes.
      // ASSERT: ¬(child is ApplyNode ∨ child is MathNode)
      node = child
      assert(isElementNode(node) || isSimpleNode(node) || isTextNode(node))
    }
    return (trace, layoutOffset - unconsumed)
  }

  /**
   Build __normalized__ location from trace.
   - Note: By __"normalized"__, we mean (a) the location must be placed within
      a child of root node unless the root node is empty; (b) the offset must
      be placed within a text node unless there is no text node available around.
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

    // Helper function to fix the last element of the path

    func fixLast(_ node: Node, _ offset: Int) -> TextLocation {
      switch node {
      case let elementNode as ElementNode:
        if offset < elementNode.childCount, isTextNode(elementNode.getChild(offset)) {
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
        if offset < argumentNode.childCount, isTextNode(argumentNode.getChild(offset)) {
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
