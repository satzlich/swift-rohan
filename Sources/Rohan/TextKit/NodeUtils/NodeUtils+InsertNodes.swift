// Copyright 2024-2025 Lie Yan

import Algorithms

extension NodeUtils {
  /**
   Insert inline content into a tree at given location.
   The method also applies to `containsBlock` and `mathListContent`.
   - Returns: The range of the inserted content if the insertion is successful;
      otherwise, an error.
   */
  static func insertInlineContent(
    _ nodes: [Node], at location: TextLocation, _ tree: RootNode
  ) -> SatzResult<InsertionRange> {
    precondition(!nodes.isEmpty)
    precondition(isSingleTextNode(nodes) == false)

    // if the content is empty, return the original location
    guard !nodes.isEmpty else {
      return .success(InsertionRange(location))
    }

    do {
      let range = try insertInlineContent(nodes, at: location.asPartialLocation, tree)
      guard let range else {
        return .failure(SatzError(.InsertNodesFailure))
      }
      return .success(range)
    }
    catch let error as SatzError {
      return .failure(error)
    }
    catch {
      return .failure(SatzError(.InsertNodesFailure))
    }
  }

  /**
   Insert inline content into subtree at given location.
   - Returns: The range of the inserted content if the insertion is successful;
      otherwise, nil.
   */
  internal static func insertInlineContent(
    _ nodes: [Node], at location: PartialLocation, _ subtree: ElementNode
  ) throws -> InsertionRange? {
    precondition(!nodes.isEmpty)
    precondition(isSingleTextNode(nodes) == false)

    let traceResult = tryBuildTrace(for: location, subtree, until: isArgumentNode(_:))
    guard let (trace, truthMaker) = traceResult else { return nil }

    // if truthMaker is not nil, the location is into ArgumentNode
    if truthMaker != nil {
      let argumentNode = truthMaker as! ArgumentNode
      let newLocation = location.dropFirst(trace.count)
      guard let newRange = try argumentNode.insertInlineContent(nodes, at: newLocation)
      else { return nil }
      return InsertionRange.concate(trace.map(\.index), newRange)
    }
    assert(truthMaker == nil)
    // otherwise, the final location is found and the insertion is performed.
    guard let lastNode = trace.last?.node else {
      throw SatzError(.InvalidTextLocation)
    }
    // Consider three cases:
    //  1) text node, 2) root node, or 3) element node (other than root).
    switch lastNode {
    case let textNode as TextNode:
      let offset = location.offset
      guard trace.count > 1,
        // get parent and index
        let secondLast = trace.dropLast().last,
        let parent = secondLast.node as? ElementNode,
        let index = secondLast.index.index(),
        // check offset
        offset <= textNode.stringLength
      else { throw SatzError(.InvalidTextLocation) }
      // perform insertion
      let range = insertInlineContent(
        nodes, textNode: textNode, offset: offset, parent, index)
      guard let (from, to) = range else { return nil }
      // compose the new location and end
      let newLocation = composeLocation(trace.dropLast(2).map(\.index), from)
      let newEnd = composeLocation(trace.dropLast(2).map(\.index), to)
      return InsertionRange(newLocation, newEnd)

    case let paragraphContainer as ElementNode
    where isParagraphContainerLike(paragraphContainer):
      let index = location.offset
      guard index <= paragraphContainer.childCount else {
        throw SatzError(.InvalidTextLocation, message: "index out of range")
      }
      let range = insertInlineContent(
        nodes, paragraphContainer: paragraphContainer, index: index)
      guard let (from, to) = range else { return nil }
      // compose
      let newLocation = composeLocation(trace.dropLast().map(\.index), from)
      let newEnd = composeLocation(trace.dropLast().map(\.index), to)
      return InsertionRange(newLocation, newEnd)

    case let elementNode as ElementNode:
      let index = location.offset
      guard index <= elementNode.childCount else {
        throw SatzError(.InvalidTextLocation, message: "index out of range")
      }
      let range = insertInlineContent(nodes, elementNode: elementNode, index: index)
      guard let (from, to) = range else { return nil }
      // compose
      let newLocation = composeLocation(trace.dropLast().map(\.index), from)
      let newEnd = composeLocation(trace.dropLast().map(\.index), to)
      return InsertionRange(newLocation, newEnd)

    default:
      throw SatzError(.InvalidTextLocation, message: "element or text node expected")
    }
  }

  /**
   Insert inline content into text node at given offset.
   - Returns: The range of the inserted content (starting at the depth of given index,
      not offset) if the insertion is successful; otherwise, nil.
   */
  private static func insertInlineContent<C>(
    _ nodes: C, textNode: TextNode, offset: Int,
    _ parent: ElementNode, _ index: Int
  ) -> ([Int], [Int])?
  where
    C: BidirectionalCollection & RangeReplaceableCollection & MutableCollection,
    C.Element == Node, C.Index == Int
  {
    precondition(nodes.isEmpty == false)
    precondition(parent.getChild(index) === textNode)

    // if offset is at the end of the text
    if offset == textNode.stringLength {
      return insertInlineContent(nodes, elementNode: parent, index: index + 1)
    }
    // if offset is at the beginning of the text
    else if offset == 0 {
      return insertInlineContent(nodes, elementNode: parent, index: index)
    }

    assert(offset > 0 && offset < textNode.stringLength)

    // otherwise (offset is in the middle of the text)
    let (part0, part1) = StringUtils.split(textNode.string, at: offset)

    // first and last node to insert
    let firstNode = nodes.first as? TextNode
    let lastNode = nodes.last as? TextNode

    switch (firstNode, lastNode) {
    case (.none, .none):
      // replace part0
      let part0Node = TextNode(part0)
      parent.replaceChild(part0Node, at: index, inStorage: true)
      // append part1 to nodes
      let nodesPlus = chain(nodes, CollectionOfOne(TextNode(part1)))
      // insert nodesPlus
      let range = insertInlineContent(nodesPlus, elementNode: parent, index: index + 1)
      guard range != nil else { return nil }
      return ([index, part0.stringLength], [index + 1 + nodes.count])

    case (.none, .some(let lastNode)):
      // replace part0
      let part0Node = TextNode(part0)
      parent.replaceChild(part0Node, at: index, inStorage: true)
      // append part1 to nodes
      let toOffset = lastNode.stringLength
      let concated = TextNode(lastNode.string + part1)
      var nodesPlus = nodes
      nodesPlus[nodes.endIndex - 1] = concated
      // insert nodesPlus
      let range = insertInlineContent(nodesPlus, elementNode: parent, index: index + 1)
      guard range != nil else { return nil }
      return ([index, part0.stringLength], [index + 1 + nodes.count - 1, toOffset])

    case (.some(let firstNode), .none):
      // concate part0 with the first node
      let fromOffset = part0.stringLength
      let concated = TextNode(part0 + firstNode.string)
      parent.replaceChild(concated, at: index, inStorage: true)
      // append part1 to nodes
      let nodesPlus = chain(nodes[1...], CollectionOfOne(TextNode(part1)))
      // insert nodesPlus
      let range = insertInlineContent(nodesPlus, elementNode: parent, index: index + 1)
      guard range != nil else { return nil }
      return ([index, fromOffset], [index + 1 + nodes.count - 1])

    case (.some(let firstNode), .some(let lastNode)):
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
      let range = insertInlineContent(nodesPlus, elementNode: parent, index: index + 1)
      guard range != nil else { return nil }
      return ([index, fromOffset], [index + 1 + nodesPlus.count - 1, toOffset])
    }
  }

  /**
   Insert inline content into paragraph container at given index.
   - Returns: The range of the inserted content (starting at the depth of given index)
      if the insertion is successful; otherwise, nil.
   */
  private static func insertInlineContent(
    _ nodes: [Node], paragraphContainer: ElementNode, index: Int
  ) -> ([Int], [Int])? {
    precondition(nodes.isEmpty == false)
    precondition(isSingleTextNode(nodes) == false)

    // root node is empty
    if paragraphContainer.childCount == 0 {
      assert(index == 0)
      let paragraphNode = ParagraphNode(nodes)
      paragraphContainer.insertChild(paragraphNode, at: 0, inStorage: true)
      return ([0, 0], [0, paragraphNode.childCount])
    }
    // insert at the end
    else if paragraphContainer.childCount == index {
      if let lastNode = paragraphContainer.getChild(index - 1) as? ElementNode {
        let range = insertInlineContent(
          nodes, elementNode: lastNode, index: lastNode.childCount)
        guard let (from, to) = range else { return nil }
        return ([index - 1] + from, [index - 1] + to)
      }
      else {
        let paragraphNode = ParagraphNode(nodes)
        paragraphContainer.insertChild(paragraphNode, at: index, inStorage: true)
        return ([index, 0], [index, paragraphNode.childCount])
      }
    }
    // insert at the beginning or in the middle
    else {
      if let paragraphLike = paragraphContainer.getChild(index) as? ElementNode {
        let range = insertInlineContent(nodes, elementNode: paragraphLike, index: 0)
        guard let (from, to) = range else { return nil }
        return ([index] + from, [index] + to)
      }
      else {
        let paragraphNode = ParagraphNode(nodes)
        paragraphContainer.insertChild(paragraphNode, at: index, inStorage: true)
        return ([index, 0], [index, paragraphNode.childCount])
      }
    }
  }

  /**
   Insert inline content into element node at given index.
   - Returns: The range of the inserted content (starting at the depth of given index)
      if the insertion is successful; otherwise, nil.
   */
  private static func insertInlineContent<C>(
    _ nodes: C, elementNode: ElementNode, index: Int
  ) -> ([Int], [Int])?
  where C: BidirectionalCollection, C.Element == Node {
    // for empty nodes, return immediately
    if nodes.isEmpty {
      return ([index], [index])
    }
    else if nodes.count == 1, let textNode = nodes.first as? TextNode {
      // TODO: implement
    }

    // element node is empty
    if elementNode.childCount == 0 {
      assert(index == 0)
      elementNode.insertChildren(contentsOf: nodes, at: 0, inStorage: true)
      return ([0], [nodes.count])
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

  // MARK: - insert paragraph nodes

  /**
   Insert paragraph nodes into a text tree at a given location.
   The method also applies to `topLevelNodes`.
    - Returns: The new insertion point if the insertion is successful; otherwise, nil.
   */
  static func insertParagraphNodes(
    _ nodes: [Node], at location: TextLocation, _ tree: RootNode
  ) -> SatzResult<InsertionRange> {
    precondition(!nodes.isEmpty)
    precondition(isSingleTextNode(nodes) == false)
    precondition(nodes.allSatisfy(isTopLevelNode(_:)))

    // if the content is empty, return the original location
    guard !nodes.isEmpty else {
      return .success(InsertionRange(location))
    }

    do {
      let range = try insertParagraphNodes(nodes, at: location.asPartialLocation, tree)
      guard let range else {
        return .failure(SatzError(.InsertNodesFailure))
      }
      return .success(range)
    }
    catch let error as SatzError {
      return .failure(error)
    }
    catch {
      return .failure(SatzError(.InsertNodesFailure))
    }
  }

  /**
   Insert paragraph nodes into subtree at given location.
   - Returns: The range of inserted content if the insertion is successful;
      otherwise, nil.
   */
  internal static func insertParagraphNodes(
    _ nodes: [Node], at location: PartialLocation, _ subtree: ElementNode
  ) throws -> InsertionRange? {
    precondition(!nodes.isEmpty)
    precondition(isSingleTextNode(nodes) == false)

    let traceResult = tryBuildTrace(for: location, subtree, until: isArgumentNode(_:))
    guard let (trace, truthMaker) = traceResult else { return nil }

    // if truthMaker is not nil, the location is into ArgumentNode
    if truthMaker != nil {
      let argumentNode = truthMaker as! ArgumentNode
      let newLocation = location.dropFirst(trace.count)
      guard let newRange = try argumentNode.insertParagraphNodes(nodes, at: newLocation)
      else { return nil }
      return InsertionRange.concate(trace.map(\.index), newRange)
    }
    assert(truthMaker == nil)
    // otherwise, the final location is found and the insertion is performed.
    guard let lastNode = trace.last?.node else {
      throw SatzError(.InvalidTextLocation)
    }
    // Consider three cases:
    //  1) text node, 2) root node, or 3) element node (other than root).
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
      let range = insertParagraphNodes(
        nodes, textNode: textNode, offset: offset, parent, index, grandParent, grandIndex)
      guard let (from, to) = range else { return nil }
      // compose new location and end
      let newLocation = composeLocation(trace.dropLast(3).map(\.index), from)
      let newEnd = composeLocation(trace.dropLast(3).map(\.index), to)
      return InsertionRange(newLocation, newEnd)

    case let paragraphContainer as ElementNode
    where isParagraphContainerLike(paragraphContainer):
      let index = location.offset
      guard index <= paragraphContainer.childCount else {
        throw SatzError(.InvalidTextLocation, message: "index out of range")
      }
      let range = insertParagraphNodes(
        nodes, paragraphContainer: paragraphContainer, index: index)
      guard let (from, to) = range else { return nil }
      // compose
      let newLocation = composeLocation(trace.dropLast().map(\.index), from)
      let newEnd = composeLocation(trace.dropLast().map(\.index), to)
      return InsertionRange(newLocation, newEnd)

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
      let range = insertParagraphNodes(
        nodes, paragraphNode: paragraphNode, offset: offset, parent, index)
      guard let (from, to) = range else { return nil }
      // compose
      let newLocation = composeLocation(trace.dropLast(2).map(\.index), from)
      let newEnd = composeLocation(trace.dropLast(2).map(\.index), to)
      return InsertionRange(newLocation, newEnd)

    default:
      throw SatzError(.InvalidTextLocation, message: "element or text node expected")
    }
  }

  /**
   Insert paragraph nodes into text node at given offset.
   - Returns: The range of the inserted content (starting at the depth of
      given grandIndex, not index or offset) if the insertion is successful;
      otherwise, nil.
   */
  private static func insertParagraphNodes(
    _ nodes: [Node], textNode: TextNode, offset: Int,
    _ paragraphNode: ParagraphNode, _ index: Int,
    _ grandParent: ElementNode, _ grandIndex: Int
  ) -> ([Int], [Int])? {
    precondition(grandParent.getChild(grandIndex) === paragraphNode)
    precondition(paragraphNode.getChild(index) === textNode)
    precondition(isParagraphContainerLike(grandParent))

    // if offset is at the end of the text, forward to another
    // `insertParagraphNodes(...)`
    if offset == textNode.stringLength {
      return insertParagraphNodes(
        nodes, paragraphNode: paragraphNode, offset: index + 1, grandParent, grandIndex)
    }
    // if offset is at the beginning of the text, forward to another
    // `insertParagraphNodes(...)`
    else if offset == 0 {
      return insertParagraphNodes(
        nodes, paragraphNode: paragraphNode, offset: index, grandParent, grandIndex)
    }

    assert(offset > 0 && offset < textNode.stringLength)

    // get the part of paragraph node after (index, offset)
    func takeTailPart() -> ElementNode.Store {
      // split the text node at offset
      let (text0, text1) = StringUtils.split(textNode.string, at: offset)
      // replace the text node at index with text0
      paragraphNode.replaceChild(TextNode(text0), at: index, inStorage: true)
      // get the children of paragraph node after index
      let childCount = paragraphNode.childCount
      var children = paragraphNode.takeSubrange(index + 1..<childCount, inStorage: true)
      // prepend text1 to the children
      children.insert(TextNode(text1), at: 0)
      return children
    }

    if nodes.count == 1 {
      let node = nodes[0]
      // if paragraphNode and node are mergeable, splice the node with paragraphNode
      if isMergeableNodes(paragraphNode, node) {
        guard let node = node as? ElementNode else { return nil }
        let children = node.takeChildren(inStorage: false)
        let range = insertInlineContent(
          children, textNode: textNode, offset: offset, paragraphNode, index)
        guard let (from, to) = range else { return nil }
        return ([grandIndex] + from, [grandIndex] + to)
      }
      // otherwise, insert the node
      else {
        let tailPart = takeTailPart()
        let nodesPlus = [node, ParagraphNode(tailPart)]
        grandParent.insertChildren(
          contentsOf: nodesPlus, at: grandIndex + 1, inStorage: true)
        return ([grandIndex + 1], [grandIndex + 2])
      }
    }
    else {
      return insertParagraphNodes_helper(
        nodes, paragraphNode: paragraphNode, offset: index, grandParent, grandIndex,
        takeTailPart: takeTailPart)
    }
  }

  /**
   Insert paragraph nodes into paragraph container at given index.
   - Returns: the range of the inserted content (starting at the depth of given index)
      if the insertion is successful; otherwise, nil.
   */
  private static func insertParagraphNodes(
    _ nodes: [Node], paragraphContainer: ElementNode, index: Int
  ) -> ([Int], [Int])? {
    precondition(nodes.isEmpty == false)
    precondition(nodes.allSatisfy(isTopLevelNode(_:)))
    // container is empty
    if paragraphContainer.childCount == 0 {
      paragraphContainer.insertChildren(contentsOf: nodes, at: 0, inStorage: true)
      return ([0], [nodes.count])
    }
    // insert at the end
    else if index == paragraphContainer.childCount {
      let lastNode = paragraphContainer.getChild(index - 1)
      let firstToInsert = nodes.first!
      if let lastNode = lastNode as? ElementNode,
        let firstToInsert = firstToInsert as? ElementNode,
        isMergeableNodes(lastNode, firstToInsert)
      {
        let children = firstToInsert.takeChildren(inStorage: false)
        let range = insertInlineContent(
          children, elementNode: lastNode, index: lastNode.childCount)
        guard let (from, _) = range else { return nil }
        paragraphContainer.insertChildren(
          contentsOf: nodes.dropFirst(), at: index, inStorage: true)
        return ([index - 1] + from, [index + nodes.count - 1])
      }
      else {
        paragraphContainer.insertChildren(contentsOf: nodes, at: index, inStorage: true)
        return ([index], [paragraphContainer.childCount])
      }
    }
    // insert at the beginning or in the middle
    else {
      let lastToInsert = nodes.last!
      // first node to the right of `lastToInsert`
      let firstNode = paragraphContainer.getChild(index)
      if let lastToInsert = lastToInsert as? ElementNode,
        let firstNode = firstNode as? ElementNode,
        isMergeableNodes(lastToInsert, firstNode)
      {
        let children = lastToInsert.takeChildren(inStorage: false)
        let range = insertInlineContent(children, elementNode: firstNode, index: 0)
        guard let (_, to) = range else { return nil }
        paragraphContainer.insertChildren(
          contentsOf: nodes.dropLast(), at: index, inStorage: true)
        return ([index], [index + nodes.count - 1] + to)
      }
      else {
        paragraphContainer.insertChildren(contentsOf: nodes, at: index, inStorage: true)
        return ([index], [index + nodes.count])
      }
    }
  }

  /**
   Insert paragraph nodes into `paragraphNode` at given offset.
   - Returns: the range of inserted content (starting at the depth of given index,
      not offset) if the insertion is successful; otherwise, nil.
   */
  private static func insertParagraphNodes(
    _ nodes: [Node], paragraphNode: ParagraphNode, offset: Int,
    _ parent: ElementNode, _ index: Int
  ) -> ([Int], [Int])? {
    precondition(nodes.isEmpty == false)
    precondition(parent.getChild(index) === paragraphNode)

    // get the part of paragrpah node after offset
    func takeTailPart() -> ElementNode.Store {
      let childCount = paragraphNode.childCount
      return paragraphNode.takeSubrange(offset..<childCount, inStorage: true)
    }

    if nodes.count == 1 {
      let node = nodes[0]
      // if paragraphNode and node are mergeable, splice the node with paragraphNode
      if isMergeableNodes(paragraphNode, node) {
        guard let node = node as? ElementNode else { return nil }
        let children = node.takeChildren(inStorage: false)
        let range = insertInlineContent(
          children, elementNode: paragraphNode, index: offset)
        guard let (from, to) = range else { return nil }
        return ([index] + from, [index] + to)
      }
      // otherwise, insert the node
      else {
        let tailPart = takeTailPart()
        let nodesPlus = [node, ParagraphNode(tailPart)]
        parent.insertChildren(contentsOf: nodesPlus, at: index + 1, inStorage: true)
        return ([index + 1], [index + 2])
      }
    }
    else {
      return insertParagraphNodes_helper(
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
          split point (offset or deeper) as an array of nodes.
   - Returns: The range of the inserted content if the insertion is successful;
      otherwise, nil.
   - Precondition: `nodes` contains more than one node.
   */
  private static func insertParagraphNodes_helper(
    _ nodes: [Node], paragraphNode: ParagraphNode, offset: Int,
    _ parent: ElementNode, _ index: Int,
    takeTailPart: () -> ElementNode.Store
  ) -> ([Int], [Int])? {
    precondition(nodes.count > 1, "single node should be handled elsewhere")

    let firstToInsert = nodes.first!
    let lastToInsert = nodes.last!
    assert(firstToInsert !== lastToInsert)
    // mergeable
    let mergeable0 = isMergeableNodes(paragraphNode, firstToInsert)
    let mergeable1 = isMergeableNodes(lastToInsert, paragraphNode)

    switch (mergeable0, mergeable1) {
    case (false, false):
      let tailPart: ElementNode.Store = takeTailPart()
      let nodesPlus = chain(nodes, [ParagraphNode(tailPart)])
      parent.insertChildren(contentsOf: nodesPlus, at: index + 1, inStorage: true)
      return ([index + 1], [index + 1 + nodes.count])

    case (false, true):
      guard let lastToInsert = lastToInsert as? ElementNode else { return nil }
      // 1) take the part of paragraph node after split point
      let tailPart: ElementNode.Store = takeTailPart()
      // 2) insert nodes int parent
      parent.insertChildren(contentsOf: nodes, at: index + 1, inStorage: true)
      // 3) insert tail part into lastToInsert
      let range = insertInlineContent(
        tailPart, elementNode: lastToInsert, index: lastToInsert.childCount)
      guard let (from, _) = range else { return nil }
      return ([index + 1], [index + 1 + nodes.count - 1] + from)

    case (true, false):
      guard let firstToInsert = firstToInsert as? ElementNode else { return nil }
      // 1) take the part of paragraph node after split point
      let tailPart: ElementNode.Store = takeTailPart()
      // 2) insert the children of firstToInsert into paragraphNode
      let range = insertInlineContent(
        firstToInsert.takeChildren(inStorage: false), elementNode: paragraphNode,
        index: offset)
      guard let (from, _) = range else { return nil }
      // 3) insert the tail part and the rest of nodes into parent
      let nodesPlus = chain(nodes.dropFirst(), [ParagraphNode(tailPart)])
      parent.insertChildren(contentsOf: nodesPlus, at: index + 1, inStorage: true)
      return ([index] + from, [index + 1 + nodes.count - 1])

    case (true, true):
      guard let firstToInsert = firstToInsert as? ElementNode,
        let lastToInsert = lastToInsert as? ElementNode
      else { return nil }
      // 1) take the part of paragraph node after split point
      let tailPart: ElementNode.Store = takeTailPart()
      // 2) insert the children of firstToInsert into paragraphNode
      let range0 = insertInlineContent(
        firstToInsert.takeChildren(inStorage: false), elementNode: paragraphNode,
        index: offset)
      guard let (from0, _) = range0 else { return nil }
      // 3) insert the rest of nodes into parent
      parent.insertChildren(
        contentsOf: nodes.dropFirst(), at: index + 1, inStorage: true)
      // 4) insert tail part into lastToInsert
      let range1 = insertInlineContent(
        tailPart, elementNode: lastToInsert, index: lastToInsert.childCount)
      guard let (from1, _) = range1 else { return nil }
      return ([index] + from0, [index + 1 + nodes.count - 2] + from1)
    }
  }

  // MARK: - Insert String

  /**
   Insert `string` at `location` in `tree`.
   - Returns: the new insertion point if the insertion is successful; otherwise,
      SatzError(.InvalidTextLocation) or SatzError(.InsertStringFailure).
   */
  static func insertString(
    _ string: BigString, at location: TextLocation, _ tree: RootNode
  ) -> SatzResult<InsertionPoint> {
    precondition(string.isEmpty == false)

    do {
      let correction = try insertString(string, at: location.asPartialLocation, tree)
      // if there is no location correction, the insertion point is unchanged
      guard let correction else {
        return .success(InsertionPoint(location, isSame: true))
      }
      // apply location correction
      assert(!correction.isEmpty)
      let indices = location.indices + correction.dropLast().map({ .index($0) })
      let offset = correction.last!
      let newLocation = TextLocation(indices, offset)
      // return the new insertion point
      return .success(InsertionPoint(newLocation, isSame: false))
    }
    catch let error as SatzError {
      return .failure(error)
    }
    catch {
      return .failure(SatzError(.InsertStringFailure))
    }
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
  internal static func insertString(
    _ string: BigString, at location: PartialLocation, _ subtree: ElementNode
  ) throws -> [Int]? {
    precondition(!string.isEmpty)

    let traceResult = tryBuildTrace(for: location, subtree, until: isArgumentNode(_:))
    guard let (trace, truthMaker) = traceResult else { return nil }

    // if truthMaker is not nil, the location is into ArgumentNode.
    if truthMaker != nil {
      let argumentNode = truthMaker as! ArgumentNode
      let newLocation = location.dropFirst(trace.count)
      return try argumentNode.insertString(string, at: newLocation)
    }
    assert(truthMaker == nil)
    // otherwise, the final location is found and the insertion is performed.
    guard let lastNode = trace.last?.node else {
      throw SatzError(.InvalidTextLocation)
    }
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

    case let paragraphContainer as ElementNode
    where isParagraphContainerLike(paragraphContainer):
      let index = location.offset
      guard index <= paragraphContainer.childCount else {
        throw SatzError(.InvalidTextLocation)
      }
      let (i0, i1, i2) = try insertString(
        string, paragraphContainer: paragraphContainer, index: index)
      return [i0, i1, i2]

    case let elementNode as ElementNode:
      let index = location.offset
      guard index <= elementNode.childCount
      else { throw SatzError(.InvalidTextLocation) }
      let (i0, i1) = insertString(string, elementNode: elementNode, index: index)
      return [i0, i1]

    default:
      throw SatzError(.InvalidTextLocation, message: "element or text node expected")
    }
  }

  /**
   Insert `string` into text node at `offset` where text node is the child
   of `parent` at `index
   - Postcondition: Insertion point `(parent, index, offset)` remains valid.
   - Warning: The function is used only when `inStorage=true`.
   */
  private static func insertString(
    _ string: BigString, textNode: TextNode, offset: Int,
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
      the initial insertion point is (paragraphContainer, index).
      When applicable, the new insertion point becomes (paragraphContainer, i0, i1, i2).
   - Throws: SatzError(.InsaneRootChild)
   - Warning: The function is used only when `inStorage=true`.
   */
  private static func insertString(
    _ string: BigString, paragraphContainer: ElementNode, index: Int
  ) throws -> (Int, Int, Int) {
    precondition(isParagraphContainerLike(paragraphContainer))
    precondition(index <= paragraphContainer.childCount)

    let childCount = paragraphContainer.childCount
    // if there is no existing node to insert into, create a paragraph
    if childCount == 0 {
      let paragraph = ParagraphNode([TextNode(string)])
      paragraphContainer.insertChild(paragraph, at: index, inStorage: true)
      return (index, 0, 0)
    }
    // if the index is the last index, add to the end of the last child
    else if index == childCount {
      assert(childCount > 0)
      guard let lastChild = paragraphContainer.getChild(childCount - 1) as? ElementNode
      else { throw SatzError(.InvalidRootChild) }
      let (i0, i1) = insertString(
        string, elementNode: lastChild, index: lastChild.childCount)
      return (childCount - 1, i0, i1)
    }
    // otherwise, add to the start of index-th child
    else {
      guard let element = paragraphContainer.getChild(index) as? ElementNode
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
    _ string: BigString, elementNode: ElementNode, index: Int
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

  // MARK: - Helper

  /** Compose location from `prefix` and `location`. */
  private static func composeLocation(
    _ prefix: [RohanIndex], _ location: [Int]
  ) -> TextLocation {
    precondition(!location.isEmpty)
    let indices = prefix + location.dropLast().map(RohanIndex.index)
    let offset = location.last!
    return TextLocation(indices, offset)
  }
}
