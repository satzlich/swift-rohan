// Copyright 2024-2025 Lie Yan

import Algorithms
import _RopeModule

extension NodeUtils {
  // MARK: - Insert inline content

  /// Insert inline content into a tree at given location.
  /// - Returns: The range of inserted content if insertion is successful;
  ///     otherwise, an error.
  static func insertInlineContent(
    _ nodes: [Node], at location: TextLocation, _ tree: RootNode
  ) -> SatzResult<InsertionRange> {
    precondition(!nodes.isEmpty)
    precondition(isSingleTextNode(nodes) == false)

    do {
      let range = try insertInlineContent(nodes, at: location.asPartialLocation, tree)
      return .success(range)
    }
    catch let error as SatzError {
      return .failure(error)
    }
    catch {
      return .failure(SatzError(.InsertNodesFailure))
    }
  }

  /// Insert inline content into subtree at given location.
  /// - Returns: The range of inserted content
  /// - Throws: `SatzError`
  internal static func insertInlineContent(
    _ nodes: [Node], at location: PartialLocation, _ subtree: ElementNode
  ) throws -> InsertionRange {
    precondition(!nodes.isEmpty)
    precondition(isSingleTextNode(nodes) == false)

    let traceResult = tryBuildTrace(for: location, subtree, until: isArgumentNode(_:))
    guard let (trace, truthMaker) = traceResult
    else { throw SatzError(.InvalidTextLocation) }

    // if truthMaker is not nil, ArgumentNode is found
    if truthMaker != nil {
      let argumentNode = truthMaker as! ArgumentNode
      let newLocation = location.dropFirst(trace.count)
      let newRange = try argumentNode.insertInlineContent(nodes, at: newLocation)
      return InsertionRange.concate(trace.map(\.index), newRange)
    }
    assert(truthMaker == nil)
    // otherwise, the final location is found
    guard let lastNode = trace.last?.node
    else { throw SatzError(.InvalidTextLocation) }
    // Consider three cases:
    //  1) text node,
    //  2) paragraph container, or
    //  3) element node (other than paragraph container).
    switch lastNode {
    case let textNode as TextNode:
      let offset = location.offset
      guard trace.count >= 2,
        // get parent and index
        let secondLast = trace.dropLast().last,
        let parent = secondLast.node as? ElementNode,
        let index = secondLast.index.index(),
        // check offset
        offset <= textNode.stringLength
      else { throw SatzError(.InvalidTextLocation) }
      // perform insertion
      let (from, to) = insertInlineContent(
        nodes, textNode: textNode, offset: offset, parent, index)
      // compose insertion range
      let newLocation = composeLocation(trace.dropLast(2).map(\.index), from)
      let newEnd = composeLocation(trace.dropLast(2).map(\.index), to)
      guard let range = InsertionRange(newLocation, newEnd)
      else { throw SatzError(.InsertNodesFailure) }
      return range

    case let container as ElementNode where isParagraphContainerLike(container):
      let index = location.offset
      guard index <= container.childCount
      else { throw SatzError(.InvalidTextLocation) }
      let (from, to) =
        insertInlineContent(nodes, paragraphContainer: container, index: index)
      // compose insertion range
      let newLocation = composeLocation(trace.dropLast().map(\.index), from)
      let newEnd = composeLocation(trace.dropLast().map(\.index), to)
      guard let range = InsertionRange(newLocation, newEnd)
      else { throw SatzError(.InsertNodesFailure) }
      return range

    case let elementNode as ElementNode:
      let index = location.offset
      guard index <= elementNode.childCount
      else { throw SatzError(.InvalidTextLocation) }
      let (from, to) = insertInlineContent(nodes, elementNode: elementNode, index: index)
      // compose insertion range
      let newLocation = composeLocation(trace.dropLast().map(\.index), from)
      let newEnd = composeLocation(trace.dropLast().map(\.index), to)
      guard let range = InsertionRange(newLocation, newEnd)
      else { throw SatzError(.InsertNodesFailure) }
      return range

    default:
      throw SatzError(.InvalidTextLocation, message: "element or text node expected")
    }
  }

  /// Insert inline content into text node at given offset.
  /// - Returns: The range of inserted content (starting at the depth of given
  ///     index, not offset)
  private static func insertInlineContent<C>(
    _ nodes: C, textNode: TextNode, offset: Int,
    _ parent: ElementNode, _ index: Int
  ) -> ([Int], [Int])
  where
    C: BidirectionalCollection & MutableCollection,
    C.Element == Node, C.Index == Int
  {
    precondition(nodes.isEmpty == false)
    precondition(parent.getChild(index) === textNode)

    // for single text node
    if let string = getSingleTextNode(nodes)?.string {
      return insertString(string, textNode: textNode, offset: offset, parent, index)
    }
    // if offset is at the end of the text
    else if offset == textNode.stringLength {
      return insertInlineContent(nodes, elementNode: parent, index: index + 1)
    }
    // if offset is at the beginning of the text
    else if offset == 0 {
      return insertInlineContent(nodes, elementNode: parent, index: index)
    }
    // otherwise (offset is in the middle of the text)
    assert(offset > 0 && offset < textNode.stringLength)

    let (part0, part1) = StringUtils.strictSplit(textNode.string, at: offset)

    // first and last node to insert
    let firstNode = nodes.first as? TextNode
    let lastNode = nodes.last as? TextNode

    // the code work for nodes.count >= 1
    switch (firstNode, lastNode) {
    case (.none, .none):
      // replace with part0
      parent.replaceChild(TextNode(part0), at: index, inStorage: true)
      // append part1 to nodes
      let nodesPlus = chain(nodes, CollectionOfOne(TextNode(part1)))
      // insert nodesPlus
      _ = insertInlineContent(nodesPlus, elementNode: parent, index: index + 1)
      return ([index, part0.stringLength], [index + 1 + nodes.count])

    case (.none, .some(let lastNode)):
      // replace with part0
      parent.replaceChild(TextNode(part0), at: index, inStorage: true)
      // append part1 to nodes
      let toOffset = lastNode.stringLength
      var nodesPlus = nodes
      nodesPlus[nodes.endIndex - 1] = TextNode(lastNode.string + part1)
      // insert nodesPlus
      _ = insertInlineContent(nodesPlus, elementNode: parent, index: index + 1)
      return ([index, part0.stringLength], [index + 1 + nodes.count - 1, toOffset])

    case (.some(let firstNode), .none):
      // concate part0 with the first node
      let fromOffset = part0.stringLength
      let concated = TextNode(part0 + firstNode.string)
      parent.replaceChild(concated, at: index, inStorage: true)
      // append part1 to nodes
      let nodesPlus = chain(nodes[1...], CollectionOfOne(TextNode(part1)))
      // insert nodesPlus
      _ = insertInlineContent(nodesPlus, elementNode: parent, index: index + 1)
      return ([index, fromOffset], [index + 1 + nodes.count - 1])

    case (.some(let firstNode), .some(let lastNode)):
      assert(firstNode !== lastNode)
      // concate part0 with the first node
      let fromOffset = part0.stringLength
      let prevConcated = TextNode(part0 + firstNode.string)
      parent.replaceChild(prevConcated, at: index, inStorage: true)
      // concate the last node with part1
      let toOffset = lastNode.stringLength
      let nextConcated = TextNode(lastNode.string + part1)
      var nodesPlus = Array(nodes[1...])
      nodesPlus[nodesPlus.endIndex - 1] = nextConcated
      // insert nodesPlus
      _ = insertInlineContent(nodesPlus, elementNode: parent, index: index + 1)
      return ([index, fromOffset], [index + 1 + nodesPlus.count - 1, toOffset])
    }
  }

  /// Insert inline content into paragraph container at given index.
  /// - Returns: The range of inserted content (starting at the depth of given index)
  private static func insertInlineContent(
    _ nodes: [Node], paragraphContainer container: ElementNode, index: Int
  ) -> ([Int], [Int]) {
    precondition(nodes.isEmpty == false)
    precondition(isSingleTextNode(nodes) == false)

    // insert at the end (including empty container)
    if container.childCount == index {
      let paragraph = ParagraphNode(nodes)
      container.insertChild(paragraph, at: index, inStorage: true)
      return ([index, 0], [index + 1])
    }
    // insert at the beginning or in the middle
    else {
      let element = container.getChild(index) as! ElementNode
      let (from, to) = insertInlineContent(nodes, elementNode: element, index: 0)
      return ([index] + from, [index] + to)
    }
  }

  /// Insert inline content into element node at given index.
  /// - Returns: The range of inserted content (starting at the depth of given index)
  private static func insertInlineContent<C>(
    _ nodes: C, elementNode: ElementNode, index: Int
  ) -> ([Int], [Int])
  where C: BidirectionalCollection, C.Element == Node {
    precondition(index <= elementNode.childCount)

    // for empty nodes, return immediately
    if nodes.isEmpty {
      return ([index], [index])
    }
    // for single text node
    else if let textNode = getSingleTextNode(nodes) {
      return insertString(textNode.string, elementNode: elementNode, index: index)
    }
    // element node is empty
    else if elementNode.childCount == 0 {
      assert(index == 0)
      elementNode.insertChildren(contentsOf: nodes, at: 0, inStorage: true)
      return ([0], [0 + nodes.count])
    }
    // insert at the end
    else if elementNode.childCount == index {
      let lastNode = elementNode.getChild(index - 1)
      let firstToInsert = nodes.first!
      if let lastNode = lastNode as? TextNode,
        let firstToInsert = firstToInsert as? TextNode
      {
        let fromOffset = lastNode.stringLength
        let concated = TextNode(lastNode.string + firstToInsert.string)
        elementNode.replaceChild(concated, at: index - 1, inStorage: true)
        elementNode.insertChildren(
          contentsOf: nodes.dropFirst(), at: index, inStorage: true)
        return ([index - 1, fromOffset], [index + nodes.count - 1])
      }
      else {
        elementNode.insertChildren(contentsOf: nodes, at: index, inStorage: true)
        assert(elementNode.childCount == index + nodes.count)
        return ([index], [index + nodes.count])
      }
    }
    // insert at the beginning
    else if index == 0 {
      let lastToInsert = nodes.last!
      let firstNode = elementNode.getChild(0)
      if let lastToInsert = lastToInsert as? TextNode,
        let firstNode = firstNode as? TextNode
      {
        let toOffset = lastToInsert.stringLength
        let concated = TextNode(lastToInsert.string + firstNode.string)
        elementNode.replaceChild(concated, at: 0, inStorage: true)
        elementNode.insertChildren(contentsOf: nodes.dropLast(), at: 0, inStorage: true)
        return ([0], [nodes.count - 1, toOffset])
      }
      else {
        elementNode.insertChildren(contentsOf: nodes, at: 0, inStorage: true)
        return ([0], [nodes.count])
      }
    }
    // insert in the middle
    else {
      let prevNode = elementNode.getChild(index - 1)
      let nextNode = elementNode.getChild(index)
      // two neighbouring text nodes is invalid
      assert(!isTextNode(prevNode) || !isTextNode(nextNode))
      if let prevNode = prevNode as? TextNode,
        let firstToInsert = nodes.first as? TextNode
      {
        let fromOffset = prevNode.stringLength
        let concated = TextNode(prevNode.string + firstToInsert.string)
        elementNode.replaceChild(concated, at: index - 1, inStorage: true)
        elementNode.insertChildren(
          contentsOf: nodes.dropFirst(), at: index, inStorage: true)
        return ([index - 1, fromOffset], [index + nodes.count - 1])
      }
      else if let lastToInsert = nodes.last as? TextNode,
        let nextNode = nextNode as? TextNode
      {
        let toOffset = lastToInsert.stringLength
        let concated = TextNode(lastToInsert.string + nextNode.string)
        elementNode.replaceChild(concated, at: index, inStorage: true)
        elementNode.insertChildren(
          contentsOf: nodes.dropLast(), at: index, inStorage: true)
        return ([index], [index + nodes.count - 1, toOffset])
      }
      else {
        elementNode.insertChildren(contentsOf: nodes, at: index, inStorage: true)
        return ([index], [index + nodes.count])
      }
    }
  }

  // MARK: - Insert paragraph nodes

  /// Insert paragraph nodes into a tree at given location.
  /// (The method also applies to `topLevelNodes`.)
  /// - Returns: The range of inserted content.
  static func insertParagraphNodes(
    _ nodes: [Node], at location: TextLocation, _ tree: RootNode
  ) -> SatzResult<InsertionRange> {
    precondition(!nodes.isEmpty)
    precondition(nodes.allSatisfy(isTopLevelNode(_:)))

    // if the content is empty, return the original location
    guard !nodes.isEmpty else {
      return .success(InsertionRange(location))
    }

    do {
      let partialLocation = location.asPartialLocation
      let range = try insertParagraphNodes(nodes, at: partialLocation, tree)
      return .success(range)
    }
    catch let error as SatzError {
      return .failure(error)
    }
    catch {
      return .failure(SatzError(.InsertNodesFailure))
    }
  }

  /// Insert paragraph nodes into subtree at given location.
  /// - Returns: The range of inserted content
  internal static func insertParagraphNodes(
    _ nodes: [Node], at location: PartialLocation, _ subtree: ElementNode
  ) throws -> InsertionRange {
    precondition(!nodes.isEmpty)
    precondition(nodes.allSatisfy(isTopLevelNode(_:)))

    let traceResult = tryBuildTrace(for: location, subtree, until: isArgumentNode(_:))
    guard let (trace, truthMaker) = traceResult else {
      throw SatzError(.InvalidTextLocation)
    }

    // if truthMaker is not nil, the location is into ArgumentNode
    if truthMaker != nil {
      let argumentNode = truthMaker as! ArgumentNode
      let newLocation = location.dropFirst(trace.count)
      let newRange = try argumentNode.insertParagraphNodes(nodes, at: newLocation)
      return InsertionRange.concate(trace.map(\.index), newRange)
    }
    assert(truthMaker == nil)
    // otherwise, the final location is found and the insertion is performed.
    let lastNode = trace.last!.node
    // Consider three cases:
    //  1) text node,
    //  2) paragraph container, or
    //  3) element node (other than paragraph container).
    switch lastNode {
    case let textNode as TextNode:
      let offset = location.offset
      guard trace.count >= 3,
        // get grand parent and index
        let thirdLast = trace.dropLast(2).last,
        let grandParent = thirdLast.node as? ElementNode,
        isParagraphContainerLike(grandParent),
        let grandIndex = thirdLast.index.index(),
        // get parent and index
        let secondLast = trace.dropLast().last,
        let parent = secondLast.node as? ParagraphNode,
        let index = secondLast.index.index(),
        // check index and offset
        offset <= textNode.stringLength
      else { throw SatzError(.InvalidTextLocation) }
      // perform insertion
      let (from, to) = try insertParagraphNodes(
        nodes, textNode: textNode, offset: offset, parent, index, grandParent, grandIndex)
      // compose new location and end
      let newLocation = composeLocation(trace.dropLast(3).map(\.index), from)
      let newEnd = composeLocation(trace.dropLast(3).map(\.index), to)
      guard let range = InsertionRange(newLocation, newEnd)
      else { throw SatzError(.InsertNodesFailure) }
      return range

    case let paragraphContainer as ElementNode
    where isParagraphContainerLike(paragraphContainer):
      let index = location.offset
      guard index <= paragraphContainer.childCount else {
        throw SatzError(.InvalidTextLocation, message: "index out of range")
      }
      let (from, to) = insertParagraphNodes(
        nodes, paragraphContainer: paragraphContainer, index: index)
      // compose
      let newLocation = composeLocation(trace.dropLast().map(\.index), from)
      let newEnd = composeLocation(trace.dropLast().map(\.index), to)
      guard let range = InsertionRange(newLocation, newEnd)
      else { throw SatzError(.InsertNodesFailure) }
      return range

    case let paragraphNode as ParagraphNode:
      let offset = location.offset
      guard trace.count >= 2,
        // get parent and index
        let secondLast = trace.dropLast().last,
        let parent = secondLast.node as? ElementNode,
        let index = secondLast.index.index(),
        isParagraphContainerLike(parent),
        // check offset
        offset <= paragraphNode.childCount
      else { throw SatzError(.InvalidTextLocation) }
      let (from, to) = try insertParagraphNodes(
        nodes, paragraphNode: paragraphNode, offset: offset, parent, index)
      // compose
      let newLocation = composeLocation(trace.dropLast(2).map(\.index), from)
      let newEnd = composeLocation(trace.dropLast(2).map(\.index), to)
      guard let range = InsertionRange(newLocation, newEnd)
      else { throw SatzError(.InsertNodesFailure) }
      return range

    default:
      throw SatzError(.InvalidTextLocation, message: "element or text node expected")
    }
  }

  /// Insert paragraph nodes into text node at given offset.
  /// - Returns: The range of the inserted content (starting at the depth of
  ///     given grandIndex, not index or offset).
  private static func insertParagraphNodes(
    _ nodes: [Node], textNode: TextNode, offset: Int,
    _ paragraphNode: ParagraphNode, _ index: Int,
    _ grandParent: ElementNode, _ grandIndex: Int
  ) throws -> ([Int], [Int]) {
    precondition(nodes.allSatisfy(isTopLevelNode(_:)))
    precondition(grandParent.getChild(grandIndex) === paragraphNode)
    precondition(paragraphNode.getChild(index) === textNode)
    precondition(isParagraphContainerLike(grandParent))

    // if offset is at the end of the text, forward to another
    // `insertParagraphNodes(...)`
    if offset == textNode.stringLength {
      return try insertParagraphNodes(
        nodes, paragraphNode: paragraphNode, offset: index + 1, grandParent, grandIndex)
    }
    // if offset is at the beginning of the text, forward to another
    // `insertParagraphNodes(...)`
    else if offset == 0 {
      return try insertParagraphNodes(
        nodes, paragraphNode: paragraphNode, offset: index, grandParent, grandIndex)
    }

    assert(offset > 0 && offset < textNode.stringLength)

    // get the part of paragraph node after (index, offset) and
    // location before (index, offset) starting from the depth of index
    func takeTailPart() -> (ElementNode.Store, [Int]) {
      // split the text node at offset
      let (text0, text1) = StringUtils.strictSplit(textNode.string, at: offset)
      // replace the text node at index with text0
      paragraphNode.replaceChild(TextNode(text0), at: index, inStorage: true)
      // get the children of paragraph node after index
      let childCount = paragraphNode.childCount
      var children = paragraphNode.takeSubrange(index + 1..<childCount, inStorage: true)
      // prepend text1 to the children
      children.insert(TextNode(text1), at: 0)
      return (children, [index, offset])
    }

    if nodes.count == 1 {
      let node = nodes[0]
      // if paragraphNode and node are mergeable, splice the node with paragraphNode
      if isMergeableNodes(paragraphNode, node) {
        guard let node = node as? ElementNode
        else { throw SatzError(.ElementNodeExpected) }
        let children = node.takeChildren(inStorage: false)
        let (from, to) = insertInlineContent(
          children, textNode: textNode, offset: offset, paragraphNode, index)
        return ([grandIndex] + from, [grandIndex] + to)
      }
      // otherwise, insert the node
      else {
        let (tailPart, from) = takeTailPart()
        let nodesPlus = [node, ParagraphNode(tailPart)]
        grandParent.insertChildren(
          contentsOf: nodesPlus, at: grandIndex + 1, inStorage: true)
        return ([grandIndex] + from, [grandIndex + 2])
      }
    }
    else {
      // pass `offset:= index+1` as we must insert after the node at `index`
      return try insertParagraphNodes_helper(
        nodes, paragraphNode: paragraphNode, offset: index + 1, grandParent, grandIndex,
        takeTailPart: takeTailPart)
    }
  }

  /// Insert paragraph nodes into paragraph container at given index.
  /// - Returns: The range of inserted content (starting at the depth of given index)
  private static func insertParagraphNodes(
    _ nodes: [Node], paragraphContainer container: ElementNode, index: Int
  ) -> ([Int], [Int]) {
    precondition(index <= container.childCount)
    precondition(nodes.isEmpty == false)
    precondition(nodes.allSatisfy(isTopLevelNode(_:)))

    // insert at the end (including empty container)
    if index == container.childCount {
      container.insertChildren(contentsOf: nodes, at: index, inStorage: true)
      return ([index], [container.childCount])
    }
    // insert at the beginning or in the middle
    else {
      let lastToInsert = nodes.last!
      let firstNode = container.getChild(index)
      if let lastToInsert = lastToInsert as? ElementNode,
        let firstNode = firstNode as? ElementNode,
        isMergeableNodes(lastToInsert, firstNode)
      {
        let children = lastToInsert.takeChildren(inStorage: false)
        let (_, to) = insertInlineContent(children, elementNode: firstNode, index: 0)
        container.insertChildren(
          contentsOf: nodes.dropLast(), at: index, inStorage: true)
        return ([index], [index + nodes.count - 1] + to)
      }
      else {
        container.insertChildren(contentsOf: nodes, at: index, inStorage: true)
        return ([index], [index + nodes.count])
      }
    }
  }

  /// Insert paragraph nodes into `paragraphNode` at given offset.
  /// - Returns: The range of inserted content (starting at the depth of given index,
  ///    not offset).
  private static func insertParagraphNodes(
    _ nodes: [Node], paragraphNode: ParagraphNode, offset: Int,
    _ parent: ElementNode, _ index: Int
  ) throws -> ([Int], [Int]) {
    precondition(offset <= paragraphNode.childCount)
    precondition(nodes.isEmpty == false)
    precondition(nodes.allSatisfy(isTopLevelNode(_:)))
    precondition(parent.getChild(index) === paragraphNode)

    // if offset is at the beginning of the paragraph node, forward to another
    // `insertParagraphNodes(...)`
    if offset == 0 {
      return insertParagraphNodes(nodes, paragraphContainer: parent, index: index)
    }

    // get the part of paragrpah node after offset and the location before
    // offset starting from the depth of offset
    func takeTailPart() -> (ElementNode.Store, [Int]) {
      let childCount = paragraphNode.childCount
      let tailPart =
        paragraphNode.takeSubrange(offset..<childCount, inStorage: true)
      return (tailPart, [offset])
    }

    if nodes.count == 1 {
      let node = nodes[0]
      // if paragraphNode and node are mergeable, splice the node with paragraphNode
      if isMergeableNodes(paragraphNode, node) {
        guard let node = node as? ElementNode
        else { throw SatzError(.ElementNodeExpected) }
        let children = node.takeChildren(inStorage: false)
        let (from, to) =
          insertInlineContent(children, elementNode: paragraphNode, index: offset)
        return ([index] + from, [index] + to)
      }
      // otherwise, insert the node
      else {
        let (tailPart, from) = takeTailPart()
        let nodesPlus = [node, ParagraphNode(tailPart)]
        parent.insertChildren(contentsOf: nodesPlus, at: index + 1, inStorage: true)
        return ([index] + from, [index + 2])
      }
    }
    else {
      return try insertParagraphNodes_helper(
        nodes, paragraphNode: paragraphNode, offset: offset, parent, index,
        takeTailPart: takeTailPart)
    }
  }

  /**
   Helper function for inserting paragraph nodes into `paragraphNode` at given offset.

   - Parameters:
      - nodes: The nodes to insert.
      - paragraphNode: The paragraph node to insert into.
      - offset: The offset to insert at.
      - parent: The parent of `paragraphNode`.
      - index: The index of `paragraphNode` in `parent`.
      - takeTailPart: A closure that returns the part of `paragraphNode` after
          split point (offset or deeper) as an array of nodes, and the location
          before split point starting from the depth of offset.
   - Returns: The range of the inserted content if the insertion is successful;
      otherwise, nil.
   - Precondition: `nodes` contains more than one node.
   */
  private static func insertParagraphNodes_helper(
    _ nodes: [Node], paragraphNode: ParagraphNode, offset: Int,
    _ parent: ElementNode, _ index: Int,
    takeTailPart: () -> (ElementNode.Store, [Int])
  ) throws -> ([Int], [Int]) {
    precondition(nodes.count > 1, "single node should be handled elsewhere")
    precondition(nodes.allSatisfy(isTopLevelNode(_:)))
    precondition(offset != 0)

    let firstToInsert = nodes.first!
    let lastToInsert = nodes.last!
    assert(firstToInsert !== lastToInsert)
    // mergeable
    let mergeable0 = isMergeableNodes(paragraphNode, firstToInsert)
    let mergeable1 = isMergeableNodes(lastToInsert, paragraphNode)

    switch (mergeable0, mergeable1) {
    case (false, false):
      let (tailPart, from) = takeTailPart()
      let nodesPlus = chain(nodes, [ParagraphNode(tailPart)])
      parent.insertChildren(contentsOf: nodesPlus, at: index + 1, inStorage: true)
      return ([index] + from, [index + 1 + nodes.count])

    case (false, true):
      guard let lastToInsert = lastToInsert as? ElementNode
      else { throw SatzError(.ElementNodeExpected) }
      // 1) take the part of paragraph node after split point
      let (tailPart, from0) = takeTailPart()
      // 2) insert nodes int parent
      parent.insertChildren(contentsOf: nodes, at: index + 1, inStorage: true)
      // 3) insert tail part into lastToInsert
      let (from1, _) = insertInlineContent(
        tailPart, elementNode: lastToInsert, index: lastToInsert.childCount)
      return ([index] + from0, [index + 1 + nodes.count - 1] + from1)

    case (true, false):
      guard let firstToInsert = firstToInsert as? ElementNode
      else { throw SatzError(.ElementNodeExpected) }
      // 1) take the part of paragraph node after split point
      let (tailPart, _) = takeTailPart()
      // 2) insert the children of firstToInsert into paragraphNode
      let (from1, _) = insertInlineContent(
        firstToInsert.takeChildren(inStorage: false), elementNode: paragraphNode,
        index: offset)
      // 3) insert the tail part and the rest of nodes into parent
      let nodesPlus = chain(nodes.dropFirst(), [ParagraphNode(tailPart)])
      parent.insertChildren(contentsOf: nodesPlus, at: index + 1, inStorage: true)
      return ([index] + from1, [index + 1 + nodes.count - 1])

    case (true, true):
      guard let firstToInsert = firstToInsert as? ElementNode,
        let lastToInsert = lastToInsert as? ElementNode
      else { throw SatzError(.ElementNodeExpected) }
      // 1) take the part of paragraph node after split point
      let (tailPart, _) = takeTailPart()
      // 2) insert the children of firstToInsert into paragraphNode
      let (from1, _) = insertInlineContent(
        firstToInsert.takeChildren(inStorage: false), elementNode: paragraphNode,
        index: offset)
      // 3) insert the rest of nodes into parent
      parent.insertChildren(
        contentsOf: nodes.dropFirst(), at: index + 1, inStorage: true)
      // 4) insert tail part into lastToInsert
      let (from2, _) = insertInlineContent(
        tailPart, elementNode: lastToInsert, index: lastToInsert.childCount)
      return ([index] + from1, [index + 1 + nodes.count - 2] + from2)
    }
  }

  // MARK: - Insert String

  /// Insert string at location in tree.
  /// - Returns: The range of inserted content.
  /// - Throws: `SatzError(.InvalidTextLocation)`, `SatzError(.InsertStringFailure)`.
  static func insertString(
    _ string: BigString, at location: TextLocation, _ tree: RootNode
  ) -> SatzResult<InsertionRange> {
    precondition(string.isEmpty == false)

    do {
      let range = try insertString(string, at: location.asPartialLocation, tree)
      return .success(range)
    }
    catch let error as SatzError {
      return .failure(error)
    }
    catch {
      return .failure(SatzError(.InsertStringFailure))
    }
  }

  /// Insert string into subtree at given location.
  /// - Returns: The range of inserted content.
  /// - Throws: `SatzError(.InvalidTextLocation)`, `SatzError(.InsertStringFailure)`.
  /// - Precondition: `string` is not empty.
  internal static func insertString(
    _ string: BigString, at location: PartialLocation, _ subtree: ElementNode
  ) throws -> InsertionRange {
    precondition(!string.isEmpty)

    let traceResult = tryBuildTrace(for: location, subtree, until: isArgumentNode(_:))
    guard let (trace, truthMaker) = traceResult
    else { throw SatzError(.InvalidTextLocation) }

    // if truthMaker is not nil, ArgumentNode is found
    if truthMaker != nil {
      let argumentNode = truthMaker as! ArgumentNode
      let newLocation = location.dropFirst(trace.count)
      let newRange = try argumentNode.insertString(string, at: newLocation)
      return InsertionRange.concate(trace.map(\.index), newRange)
    }
    assert(truthMaker == nil)
    // otherwise, the final location is found
    let lastNode = trace.last!.node
    // Consider three cases:
    //  1) text node,
    //  2) paragraph container, or
    //  3) element node (other than paragraph container).
    switch lastNode {
    case let textNode as TextNode:
      let offset = location.offset
      guard
        // get parent and index
        let secondLast = trace.dropLast().last,
        let parent = secondLast.node as? ElementNode,
        let index = secondLast.index.index(),
        // check offset
        offset <= textNode.stringLength
      else { throw SatzError(.InvalidTextLocation) }
      // perform insertion
      let (from, to) =
        insertString(string, textNode: textNode, offset: offset, parent, index)
      // compose new location and end
      let newLocation = composeLocation(trace.dropLast(2).map(\.index), from)
      let newEnd = composeLocation(trace.dropLast(2).map(\.index), to)
      guard let range = InsertionRange(newLocation, newEnd)
      else { throw SatzError(.InsertStringFailure) }
      return range

    case let container as ElementNode where isParagraphContainerLike(container):
      let index = location.offset
      guard index <= container.childCount
      else { throw SatzError(.InvalidTextLocation) }
      let (from, to) =
        insertString(string, paragraphContainer: container, index: index)
      // compose
      let newLocation = composeLocation(trace.dropLast().map(\.index), from)
      let newEnd = composeLocation(trace.dropLast().map(\.index), to)
      guard let range = InsertionRange(newLocation, newEnd)
      else { throw SatzError(.InsertStringFailure) }
      return range

    case let elementNode as ElementNode:
      let index = location.offset
      guard index <= elementNode.childCount
      else { throw SatzError(.InvalidTextLocation) }
      let (from, to) = insertString(string, elementNode: elementNode, index: index)
      // compose
      let newLocation = composeLocation(trace.dropLast().map(\.index), from)
      let newEnd = composeLocation(trace.dropLast().map(\.index), to)
      guard let range = InsertionRange(newLocation, newEnd)
      else { throw SatzError(.InsertStringFailure) }
      return range

    default:
      throw SatzError(.InvalidTextLocation, message: "element or text node expected")
    }
  }

  /// Insert string into text node at given offset.
  /// - Returns: the range of inserted content (starting from the depth of given index,
  ///     not offset).
  /// - Precondition: `textNode` is a child of parent at index.
  private static func insertString(
    _ string: BigString, textNode: TextNode, offset: Int,
    _ parent: ElementNode, _ index: Int
  ) -> ([Int], [Int]) {
    precondition(offset <= textNode.stringLength)
    precondition(parent.getChild(index) === textNode)
    let newTextNode = textNode.inserted(string, at: offset)
    parent.replaceChild(newTextNode, at: index, inStorage: true)
    return ([index, offset], [index, offset + string.stringLength])
  }

  /// Insert string into container at given index.
  /// - Returns: the range of inserted content (starting from the depth of given
  ///     index, not offset).
  private static func insertString(
    _ string: BigString, paragraphContainer container: ElementNode, index: Int
  ) -> ([Int], [Int]) {
    precondition(isParagraphContainerLike(container))
    precondition(index <= container.childCount)

    if index < container.childCount,
      let element = container.getChild(index) as? ElementNode,
      element.isTransparent
    {
      let (from, to) = insertString(string, elementNode: element, index: 0)
      return ([index] + from, [index] + to)
    }
    else {
      let paragraph = ParagraphNode([TextNode(string)])
      container.insertChild(paragraph, at: index, inStorage: true)
      return ([index, 0, 0], [index + 1])
    }
  }

  /// Insert string into element node at given index.
  /// - Returns: the range of inserted content (starting from the depth of given index,
  ///     not offset).
  private static func insertString(
    _ string: BigString, elementNode: ElementNode, index: Int
  ) -> ([Int], [Int]) {
    precondition(isParagraphContainerLike(elementNode) == false)
    precondition(index <= elementNode.childCount)

    let childCount = elementNode.childCount

    if index == childCount {
      // add to the end of the last child if it is a text node;
      if index > 0,
        let textNode = elementNode.getChild(index - 1) as? TextNode
      {
        return insertString(
          string, textNode: textNode, offset: textNode.stringLength,
          elementNode, index - 1)
      }
      // otherwise, create a new text node
      else {
        elementNode.insertChild(TextNode(string), at: index, inStorage: true)
        return ([index, 0], [index, string.stringLength])
      }
    }
    else {
      // add to the beginning of the index-th child if it is a text node;
      if let textNode = elementNode.getChild(index) as? TextNode {
        return insertString(string, textNode: textNode, offset: 0, elementNode, index)
      }
      // otherwise, add to the end of the (index-1)-th child if it is a text node;
      else if index > 0,
        let textNode = elementNode.getChild(index - 1) as? TextNode
      {
        return insertString(
          string, textNode: textNode, offset: textNode.stringLength,
          elementNode, index - 1)
      }
      // otherwise, create a new text node
      else {
        elementNode.insertChild(TextNode(string), at: index, inStorage: true)
        return ([index, 0], [index, string.stringLength])
      }
    }
  }

  // MARK: - Helper

  /// Compose location from `prefix` and `location`.
  private static func composeLocation(
    _ prefix: [RohanIndex], _ location: [Int]
  ) -> TextLocation {
    precondition(!location.isEmpty)
    let indices = prefix + location.dropLast().map(RohanIndex.index)
    let offset = location.last!
    return TextLocation(indices, offset)
  }
}
