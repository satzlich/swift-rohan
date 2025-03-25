// Copyright 2024-2025 Lie Yan

import Algorithms
import Foundation

extension NodeUtils {
  /**
   Insert a paragraph break at the given location.
   - Returns: The new insertion point with `isSame=false` if successful;
      The new insertion point with `isSame=true` if the location is valid but
      a paragraph break is not allowed at the given location.
      A SatzError if the operation fails.
   */
  static func insertParagraphBreak(
    at location: TextLocation, _ tree: RootNode
  ) -> SatzResult<InsertionPoint> {
    guard let trace = buildTrace(for: location, tree),
      let last = trace.last
    else {
      return .failure(SatzError(.InvalidTextLocation))
    }

    if last.node === tree {  // insert at root
      guard let index = last.index.index(),
        0...tree.childCount ~= index
      else {
        return .failure(SatzError(.InvalidTextLocation))
      }
      let insertionPoint = insertParagraphBreak(at: index, rootNode: tree)
      return .success(InsertionPoint(insertionPoint, isSame: false))
    }
    // compute index of last paragraph-like node
    guard let paragraphIndex = computeParagraphIndex(trace) else {
      // paragraph break not allowed at the given location
      return .success(InsertionPoint(location, isSame: true))
    }
    // paragraphIndex > 0 since the root node is not paragraph-like
    assert(paragraphIndex > 0)

    // current insertion point
    var insertionPoint = MutableTextLocation(location, isRectified: false)
    // insert paragraph break
    do {
      try insertParagraphBreak(
        at: location.asPartialLocation, tree, paragraphIndex, &insertionPoint)
      assert(insertionPoint.isRectified)
      guard let newLocation = insertionPoint.asTextLocation else {
        return .failure(SatzError(.InsertParagraphBreakFailure))
      }
      return .success(InsertionPoint(newLocation, isSame: false))
    }
    catch let error as SatzError {
      return .failure(error)
    }
    catch {
      return .failure(SatzError(.InsertParagraphBreakFailure))
    }
  }

  /**
   Insert a paragraph break at the given location.

   The insertion point is updated to the new location if successful.

   - Returns: true if successful, false otherwise.
   */
  static func insertParagraphBreak(
    at location: PartialLocation, _ subtree: Node,
    _ paragraphIndex: Int, _ insertionPoint: inout MutableTextLocation
  ) throws {
    precondition(location.indices.startIndex <= paragraphIndex - 1)

    guard location.indices.startIndex == paragraphIndex - 1 else {
      // recurse
      switch subtree {
      case let applyNode as ApplyNode:
        guard let index = location.indices.first?.argumentIndex(),
          index < applyNode.argumentCount
        else {
          throw SatzError(.InvalidTextLocation)
        }
        let argumentNode = applyNode.getArgument(index)
        try argumentNode.insertParagraphBreak(
          at: location.dropFirst(), paragraphIndex, &insertionPoint)
      default:
        guard let index = location.indices.first,
          let child = subtree.getChild(index)
        else {
          throw SatzError(.InvalidTextLocation)
        }
        try insertParagraphBreak(
          at: location.dropFirst(), child, paragraphIndex, &insertionPoint)
      }
      return
    }
    // ASSERT: we are at the container of the paragraph-like node

    guard
      // the container of the paragraph-like node must be an element
      let containerNode = subtree as? ElementNode,
      // check validity of index
      let index = location.indices.first?.index(),
      index < containerNode.childCount,
      // obtain the paragraph-like node
      let paragraphNode = containerNode.getChild(index) as? ElementNode
    else {
      throw SatzError(.InvalidTextLocation)
    }
    assert(isParagraphContainerLike(containerNode))
    assert(paragraphNode.isParagraphLike)

    let result = try takeTailSegment(at: location.dropFirst(), paragraphNode)

    switch result {
    case .empty:
      guard let newElement = paragraphNode.createSuccessor() else {
        assertionFailure("createSuccessor() must not return nil for paragraph-like node")
        throw SatzError(.InsertParagraphBreakFailure)
      }
      containerNode.insertChild(newElement, at: index + 1, inStorage: true)
    case .full:
      let newElement = paragraphNode.cloneEmpty()
      containerNode.insertChild(newElement, at: index, inStorage: true)
    case .partial(let wrapped):
      containerNode.insertChild(wrapped, at: index + 1, inStorage: true)
    }
    insertionPoint.rectify(paragraphIndex - 1, with: index + 1, 0)
  }

  /**
   Determine if the location is valid for inserting a paragraph break.
   - Returns: the index of the last paragraph-compatible node in the trace if
      an insertion is allowed at the location; nil otherwise.
   */
  private static func computeParagraphIndex(_ trace: [TraceElement]) -> Int? {
    precondition(!trace.isEmpty && isRootNode(trace[0].node))

    func isParagraphLike(_ node: Node) -> Bool {
      (node as? ElementNode)?.isParagraphLike == true
    }
    // i st. trace[i] is the last paragraph-like node and trace[i+1...] is transparent
    var i = trace.endIndex - 1
    while i > 0 {
      if isParagraphLike(trace[i].node) { break }
      if !trace[i].node.isTransparent { return nil }
      i -= 1
    }
    return i > 0 ? i : nil
  }

  /**
   Take the tail segment of the element node at the given location.
   - Returns: the tail segment.
   - Throws: SatzError(.InvalidTextLocation) if the location is invalid.
   */
  private static func takeTailSegment(
    at location: PartialLocation, _ elementNode: ElementNode
  ) throws -> SegmentResult<Node> {
    if location.count == 1 {
      return try takeTailSegment(at: location.offset, elementNode: elementNode)
    }

    guard let index = location.indices.first?.index(),
      index < elementNode.childCount
    else {
      throw SatzError(.InvalidTextLocation)
    }
    let child = elementNode.getChild(index)

    let result: SegmentResult<Node>
    switch child {
    case let child as ElementNode:
      result = try takeTailSegment(at: location.dropFirst(), child)
    case let child as TextNode:
      assert(location.count == 2)
      result = try takeTailSegment(
        at: location.offset, textNode: child, elementNode, index)
    default:
      throw SatzError(.ElementOrTextNodeExpected)
    }

    switch result {
    case .empty:
      return try takeTailSegment(at: index + 1, elementNode: elementNode)
    case .full:
      return try takeTailSegment(at: index, elementNode: elementNode)
    case .partial(let wrapped):
      // take right siblings
      let range = index + 1..<elementNode.childCount
      let siblings = elementNode.takeSubrange(range, inStorage: true)
      // chain the wrapped node with the siblings
      let children = chain(CollectionOfOne(wrapped), siblings)
      let newElement = elementNode.cloneEmpty()
      // safe to insert with inStorage = false since the new element is unattached
      newElement.insertChildren(contentsOf: children, at: 0, inStorage: false)
      return .partial(newElement)
    }
  }

  private static func takeTailSegment(
    at index: Int, elementNode: ElementNode
  ) throws -> SegmentResult<Node> {
    guard 0...elementNode.childCount ~= index else {
      throw SatzError(.InvalidTextLocation)
    }
    // prefer empty to full
    if index == elementNode.childCount {  // at the end
      return .empty
    }
    else if index == 0 {  // at the beginning
      return .full
    }
    else {
      let range = index..<elementNode.childCount
      let segment = elementNode.takeSubrange(range, inStorage: true)
      let newElement = elementNode.cloneEmpty()
      newElement.insertChildren(contentsOf: segment, at: 0, inStorage: false)
      return .partial(newElement)
    }
  }

  private static func takeTailSegment(
    at offset: Int, textNode: TextNode, _ parent: ElementNode, _ index: Int
  ) throws -> SegmentResult<Node> {
    guard 0...textNode.stringLength ~= offset else {
      throw SatzError(.InvalidTextLocation)
    }
    // prefer empty to full
    if offset == textNode.stringLength {  // at the end
      return .empty
    }
    else if offset == 0 {  // at the beginning
      return .full
    }
    else {
      let (t0, t1) = textNode.strictSplit(at: offset)
      parent.replaceChild(t0, at: index, inStorage: true)
      return .partial(t1)
    }
  }

  /// Insert a paragraph break at the given index in the root node.
  /// - Precondition: index is in the range [0, rootNode.childCount].
  private static func insertParagraphBreak(
    at index: Int, rootNode: RootNode
  ) -> TextLocation {
    precondition(0...rootNode.childCount ~= index)

    if rootNode.childCount == 0 {  // empty
      let newElement = ParagraphNode()
      rootNode.insertChild(newElement, at: 0, inStorage: true)
      return TextLocation([.index(0)], 0)
    }
    else if index == rootNode.childCount {  // at the end
      let child = rootNode.getChild(index - 1) as! ElementNode
      let newElement = child.createSuccessor() ?? ParagraphNode()
      rootNode.insertChild(newElement, at: index, inStorage: true)
      return TextLocation([.index(index)], 0)
    }
    else {
      let child = rootNode.getChild(index) as! ElementNode
      let newElement = child.cloneEmpty()
      rootNode.insertChild(newElement, at: index, inStorage: true)
      return TextLocation([.index(index + 1)], 0)
    }
  }
}
