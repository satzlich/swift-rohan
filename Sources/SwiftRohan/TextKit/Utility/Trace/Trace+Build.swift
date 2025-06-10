// Copyright 2024-2025 Lie Yan

import Foundation

extension Trace {
  /// Build a trace from a location in a tree.
  /// - Returns: The trace if the location is valid, otherwise nil.
  static func from(_ location: TextLocation, _ tree: RootNode) -> Trace? {
    var trace = Trace()
    trace.reserveCapacity(location.indices.count + 1)

    var node: Node = tree
    for index in location.indices {
      guard let child = node.getChild(index) else { return nil }
      trace.emplaceBack(node, index)
      node = child
    }
    guard NodeUtils.validateOffset(location.offset, node) else { return nil }
    trace.emplaceBack(node, .index(location.offset))
    return trace
  }

  /// Build a trace from a location in a subtree until given predicate is met, or
  /// the end of the path specified by location is reached.
  /// - Returns: The trace if the probed part of location is valid, otherwise nil.
  /// - Postcondition: In the case that the location is valid, the following holds:
  ///   (a) If tracing is interrupted by the predicate, truthMaker equals the node
  ///       that satisfies the predicate.
  ///       Let n:= trace.count, p(x):= predicate(x.getChild()), it holds that:
  ///       `¬p(x)` for all `x∈trace[0..n-2)`  ∧ `p(trace[n-1])`. In other words,
  ///       the child of the last node in the trace satisfies the predicate,
  ///   (b) Otherwise, `truthMaker == nil`.
  static func tryFrom(
    _ location: TextLocationSlice, _ subtree: ElementNode,
    until predicate: (Node) -> Bool
  ) -> (Trace, truthMaker: Node?)? {
    var trace = Trace()
    trace.reserveCapacity(location.indices.count + 1)

    var node: Node = subtree
    for index in location.indices {
      guard let child = node.getChild(index) else { return nil }
      trace.emplaceBack(node, index)
      if predicate(child) {
        return (trace, child)
      }
      node = child
    }
    guard NodeUtils.validateOffset(location.offset, node) else { return nil }
    trace.emplaceBack(node, .index(location.offset))
    return (trace, nil)
  }

  /// Trace nodes with `[layoutOffset, _ + 1)` in a subtree so that either of the
  /// following holds:
  /// a) the node of the last trace element is a text node, and the interior of
  ///    the trace (first element excluded) are NOT __pivotal__.
  /// b) a child can be obtained from the last element of the trace and that
  ///    child is pivotal, or is a child-free element node or a simple node.
  ///
  /// - Returns: The trace and consumed offset for the trace if the probed part
  ///     of location is valid, otherwise nil.
  /// - Note: It is possible that consumed > layoutOffset, in which case the caller
  ///     should make adjustment accordingly.
  /// - Warning: The implementation is very __tricky__. Don't change it unless you
  ///     understand it well.
  static func tryFrom(
    _ layoutOffset: Int, _ subtree: ElementNode
  ) -> (Trace, consumed: Int)? {
    // ensure [layoutOffset, _ + 1) is a valid range in the subtree.
    guard 0..<subtree.layoutLength() ~= layoutOffset else { return nil }
    // ASSERT:  ¬CF(subtree)

    var trace = Trace()
    var node: Node = subtree
    var unconsumed = layoutOffset

    /*
     Define notations as follows.
      n:= trace.count
      $node[k]:= trace[k].node
      $child[k]:= trace[k].getChild()
    
     Define predicates as follows.
      T(node):= node is TextNode
      P(node):= node is pivotal
      CF(node):= node is child-free ElementNode ∨ is SimpleNode
      ETS(node):= node is ElementNode ∨ is TextNode ∨ is SimpleNode
    
     Invariant:
      n>=2 ⇒ ∀x∈$node[1...n-1]:¬P(x)
    
     On exit:
      n>=1 ∧ (n>=2 ⇒ ∀x∈$node[1...n-1]:¬P(x)) ∧
        (T($node[n-1]) ∨ P($child[n-1]) ∨ CF($child[n-1]))
     */
    while true {
      // ASSERT: n=0  ⇒ node = subtree ∧ ¬CF(node)
      // ASSERT: n>=1 ⇒ node = $child[n-1] ∧ ETS(node)
      // ASSERT: n>=1 ⇒ ¬P(node)

      assert(isElementNode(node) || isTextNode(node) || isSimpleNode(node))

      // For method `getRohanIndex(_:)`,
      // (a) TextNode always return non-nil;
      // (b) ElementNode returns nil iff it is child-free.
      // (c) Simple node always return nil.
      guard let (index, consumed) = node.getRohanIndex(unconsumed) else {
        // ASSERT: node = $child[n-1] ∧ CF(node)
        break
      }
      assert(isElementNode(node) || isTextNode(node))

      // n ← n+1
      trace.emplaceBack(node, index)
      unconsumed -= consumed

      // For method `getChild(_:)`, and index obtained with `getRohanIndex(_:)`,
      // (a) TextNode always return nil;
      // (b) ElementNode always return non-nil.
      guard let child = node.getChild(index),
        child.isPivotal == false
      else {
        // ASSERT: node = $node[n-1]  ∧ (T(node) ∨ (child = $child[n-1] ∧ P(child)))
        break
      }
      // ASSERT: ¬P(child)

      // Since ApplyNode and MathNode's are pivotal, it holds that `child` is
      // not ApplyNode or MathNode. And more, ArgumentNode must be a child
      // of ApplyNode, so `child` cannot be ArgumentNode. So ETS(child) is true.

      // ASSERT: ETS(child)
      node = child
      // ASSERT: ¬P(node)
      // ASSERT: ETS(node)
    }

    return (trace, layoutOffset - unconsumed)
  }

  /// Returns the trace segment picked by the given layout offset in a subtree.
  /// - Postcondition:
  ///     (a) terminal => last.node is ElementNode/TextNode, or last.getChild() is
  ///         SimpleNode;
  ///     (b) halfway => last.getChild() is pivotal.
  static func getTraceSegment(
    _ layoutOffset: Int, _ subtree: ElementNode
  ) -> PositionResult<Trace> {

    var trace = Trace()
    var current: Node = subtree
    var accumulated = 0

    while true {
      assert(isElementNode(current) || isTextNode(current))

      let result: PositionResult<RohanIndex> = current.getPosition(layoutOffset)

      switch result {
      case .terminal(let value, let target):
        assert(isElementNode(current) || isTextNode(current))
        trace.emplaceBack(current, value)
        accumulated += target
        return .terminal(value: trace, target: accumulated)

      case .halfway(let value, let consumed):
        assert(isElementNode(current))
        // ASSERT: current.isEmpty == false

        trace.emplaceBack(current, value)
        accumulated += consumed

        guard let next = current.getChild(value),  // getChild() must return non-nil
          next.isPivotal == false
        else {
          // next is pivotal.
          return .halfway(value: trace, consumed: accumulated)
        }
        // Since ApplyNode/MathNode/ArrayNode are pivotal, it holds that `next` is
        // not any of them. And more, ArgumentNode must be a child of ApplyNode,
        // so `next` cannot be ArgumentNode.

        if isSimpleNode(next) {
          return .terminal(value: trace, target: accumulated)
        }
        assert(isElementNode(next) || isTextNode(next))
        current = next

      case .null:
        assertionFailure("unexpected case")
        return .null

      case .failure(let satzError):
        assert(satzError.code == .InvalidLayoutOffset)
        return .failure(satzError)
      }
    }
  }

  /// Build a text location from a trace without relocation.
  func toRawLocation() -> TextLocation? {
    guard let last,
      let lastIndex = last.index.index()
    else { return nil }
    let indices = _elements.dropLast().map(\.index)
    return TextLocation(indices, lastIndex)
  }

  /// Build a **normal** text location from a trace.
  /// - Note: A **normal** text location satisfies the following properties:
  ///     (a) if a location points to a transparent element, it is relocated to
  ///         the beginning of its children;
  ///     (b) if a location points to a text node, it is relocated to the beginning
  ///         of the text node;
  ///     (c) if a location points to a node having a text node as its left neighbour,
  ///         it is relocated to the end of the text node.
  /// - Invariant: The returned text location should be equivalent to the trace for
  ///     the purpose of text editing.
  func toNormalLocation() -> TextLocation? {
    guard let last,
      var lastIndex = last.index.index()
    else { return nil }

    var lastNode: Node = last.node
    var indices = _elements.dropLast().map(\.index)

    // Invariant: (indices, lastIndex) forms a location in the tree.
    //            (lastNode, lastIndex) are paired.
    while true {
      switch lastNode {
      case let container as ElementNode where container.isParagraphContainer:
        if lastIndex < container.childCount,
          let child = container.getChild(lastIndex) as? ElementNode,
          child.isTransparent
        {
          // make progress
          indices.append(.index(lastIndex))
          lastNode = child
          lastIndex = 0
          continue
        }
        else {
          return TextLocation(indices, lastIndex)
        }

      case let node as GenElementNode:
        assert(isElementNode(node) || isArgumentNode(node))
        if lastIndex < node.childCount,
          isTextNode(node.getChild(lastIndex))
        {
          indices.append(.index(lastIndex))
          return TextLocation(indices, 0)
        }
        else if lastIndex > 0,
          let textNode = node.getChild(lastIndex - 1) as? TextNode
        {
          indices.append(.index(lastIndex - 1))
          return TextLocation(indices, textNode.length)
        }
        else {
          return TextLocation(indices, lastIndex)
        }

      default:
        return TextLocation(indices, lastIndex)
      }
    }
  }

  /// Build a **user-space** text location from a trace.
  /// - Note: A **user-space** text location satisfies the following properties
  ///     where the first three items are the same as those of a canonical:
  ///     (a) if a location points to a transparent element, it is relocated to
  ///         the beginning of its children;
  ///     (b) if a location points to a text node, it is relocated to the beginning
  ///         of the text node;
  ///     (c) if a location points to a node having a text node as its left neighbour,
  ///         it is relocated to the end of the text node.
  ///     (d) if a location points to the end of a root node whose last child is a
  ///         paragraph node, it is relocated to the end of the last paragraph node.
  mutating func toUserSpaceLocation() -> TextLocation? {
    guard let last,
      let lastIndex = last.index.index()
    else { return nil }

    let lastNode = last.node

    if let root = lastNode as? RootNode {
      let childCount = root.childCount
      if childCount > 0,
        lastIndex == childCount,
        let paragraph = root.getChild(childCount - 1) as? ParagraphNode
      {
        self.moveTo(.index(childCount - 1))
        self.emplaceBack(paragraph, .index(paragraph.childCount))
        return self.toNormalLocation()
      }
      // FALL THROUGH
    }
    return self.toNormalLocation()
  }
}
