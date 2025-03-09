// Copyright 2024-2025 Lie Yan

import Algorithms
import Foundation

extension NodeUtils {
  /**
   Insert a paragraph break at the given location.
   - Returns: new insertion point if successful, nil otherwise. In the case of failure,
   document tree is left unchanged.
   */
  static func insertParagraphBreak(
    at location: TextLocation, _ tree: RootNode
  ) -> TextLocation? {
    guard let trace = traceNodes(location, tree),
      let last = trace.last
    else { return nil }
    if last.node === tree {  // insert at root
      return insertParagraphBreak(at: last.index.index()!, rootNode: tree)
    }
    // compute index of last paragraph-like node
    guard let paragraphIndex = computeParagraphIndex(trace) else { return nil }
    assert(paragraphIndex > 0, "trace[0].node is the root node")

    // current insertion point
    var insertionPoint = InsertionPoint(location.asPath, isRectified: false)
    // insert paragraph break
    let successful = insertParagraphBreak(
      at: location.asPartialLocation, tree, paragraphIndex, &insertionPoint)
    // check and return result
    guard successful else { return nil }
    assert(insertionPoint.isRectified)
    return insertionPoint.asTextLocation
  }

  /**
   Insert a paragraph break at the given location.

   The insertion point is updated to the new location if successful.

   - Returns: true if successful, false otherwise.
   */
  static func insertParagraphBreak(
    at location: PartialLocation, _ subtree: Node,
    _ paragraphIndex: Int, _ insertionPoint: inout InsertionPoint
  ) -> Bool {
    precondition(location.indices.startIndex <= paragraphIndex - 1)

    guard location.indices.startIndex == paragraphIndex - 1 else {
      // recurse
      switch subtree {
      case let applyNode as ApplyNode:
        guard let index = location.indices.first?.argumentIndex(),
          index < applyNode.argumentCount
        else { return false }
        let argumentNode = applyNode.getArgument(index)
        return argumentNode.insertParagraphBreak(
          at: location.dropFirst(), paragraphIndex, &insertionPoint)
      default:
        guard let index = location.indices.first,
          let child = subtree.getChild(index)
        else { return false }
        return insertParagraphBreak(
          at: location.dropFirst(), child, paragraphIndex, &insertionPoint)
      }
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
    else { return false }
    assert(paragraphNode.isParagraphLike)

    guard let result = takeTailSegment(at: location.dropFirst(), paragraphNode)
    else { return false }

    switch result {
    case .empty:
      guard let newElement = paragraphNode.createForAppend() else { return false }
      containerNode.insertChild(newElement, at: index + 1, inStorage: true)
    case .full:
      let newElement = paragraphNode.cloneEmpty()
      containerNode.insertChild(newElement, at: index, inStorage: true)
    case .partial(let wrapped):
      containerNode.insertChild(wrapped, at: index + 1, inStorage: true)
    }
    insertionPoint.rectify(paragraphIndex - 1, with: index + 1, 0)
    return true
  }

  /**
   Determine if the location is valid for inserting a paragraph break.
   - Returns: the index of the last paragraph-like node in the trace if successful,
   nil otherwise.
   */
  private static func computeParagraphIndex(_ trace: [TraceElement]) -> Int? {
    precondition(!trace.isEmpty && isRootNode(trace[0].node))

    func isParagraphLike(_ node: Node) -> Bool {
      (node as? ElementNode)?.isParagraphLike ?? false
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
   - Returns: the tail segment if successful, nil otherwise.
   */
  private static func takeTailSegment(
    at location: PartialLocation, _ elementNode: ElementNode
  ) -> SegmentResult<Node>? {
    if location.count == 1 {
      return takeTailSegment(at: location.offset, elementNode: elementNode)
    }

    guard let index = location.indices.first?.index(),
      index < elementNode.childCount
    else { return nil }
    let child = elementNode.getChild(index)

    let result: SegmentResult<Node>?
    switch child {
    case let child as ElementNode:
      result = takeTailSegment(at: location.dropFirst(), child)
    case let child as TextNode:
      assert(location.count == 2)
      result = takeTailSegment(at: location.offset, textNode: child, elementNode, index)
    default:
      result = nil
    }
    guard let result = result else { return nil }

    switch result {
    case .empty:
      return takeTailSegment(at: index + 1, elementNode: elementNode)
    case .full:
      return takeTailSegment(at: index, elementNode: elementNode)
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
  ) -> SegmentResult<Node>? {
    guard 0...elementNode.childCount ~= index else { return nil }
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
  ) -> SegmentResult<Node>? {
    guard 0...textNode.stringLength ~= offset else { return nil }
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

  /** Insert a paragraph break at the given index in the root node. */
  private static func insertParagraphBreak(
    at index: Int, rootNode: RootNode
  ) -> TextLocation {
    precondition(index >= 0 && index <= rootNode.childCount)

    if rootNode.childCount == 0 {  // empty
      let newElement = ParagraphNode()
      rootNode.insertChild(newElement, at: 0, inStorage: true)
      return TextLocation([.index(0)], 0)
    }
    else if index == rootNode.childCount {  // at the end
      let child = rootNode.getChild(index - 1) as! ElementNode
      let newElement = child.createForAppend() ?? ParagraphNode()
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
