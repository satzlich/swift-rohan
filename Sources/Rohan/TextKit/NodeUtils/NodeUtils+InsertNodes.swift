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
  ) -> SatzResult<RhTextRange> {
    precondition(!nodes.isEmpty)
    precondition(isSingleTextNode(nodes) == false)

    do {
      let location = location.asPartialLocation
      let range = try insertInlineContent(nodes, at: location, tree)
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
  ) throws -> RhTextRange {
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
      return composeRange(trace.map(\.index), newRange)
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
      // compose range
      let prefix = trace.dropLast(2).map(\.index)
      return try composeRange(prefix, from, to, SatzError(.InsertNodesFailure))

    case let container as ElementNode where isParagraphContainerLike(container):
      let index = location.offset
      guard index <= container.childCount
      else { throw SatzError(.InvalidTextLocation) }
      let (from, to) =
        insertInlineContent(nodes, paragraphContainer: container, index: index)
      // compose range
      let prefix = trace.dropLast().map(\.index)
      return try composeRange(prefix, from, to, SatzError(.InsertNodesFailure))

    case let elementNode as ElementNode:
      let index = location.offset
      guard index <= elementNode.childCount
      else { throw SatzError(.InvalidTextLocation) }
      let (from, to) = insertInlineContent(nodes, elementNode: elementNode, index: index)
      // compose range
      let prefix = trace.dropLast().map(\.index)
      return try composeRange(prefix, from, to, SatzError(.InsertNodesFailure))

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
    precondition(index <= container.childCount)

    // if merge with index-th child is possible
    if index < container.childCount,
      let element = container.getChild(index) as? ElementNode,
      element.isTransparent
    {
      let (from, to) = insertInlineContent(nodes, elementNode: element, index: 0)
      return ([index] + from, [index] + to)
    }
    else {
      let paragraph = ParagraphNode(nodes)
      container.insertChild(paragraph, at: index, inStorage: true)
      return ([index, 0], [index + 1])
    }
  }

  /// Insert inline content into element node at given index.
  /// - Returns: The range of inserted content (starting at the depth of given index)
  /// - Postcondition: If merge between text nodes is possible, the text nodes
  ///     are merged. In this case, location at the merged end has count 2.
  ///     Otherwise, the location has count 1.
  static func insertInlineContent<C>(
    _ nodes: C, elementNode: ElementNode, index: Int
  ) -> ([Int], [Int])
  where C: BidirectionalCollection, C.Element == Node {
    precondition(index <= elementNode.childCount)

    guard !nodes.isEmpty else { return ([index], [index]) }

    // if merge with index-th child is possible
    if index < elementNode.childCount,
      let nextNode = elementNode.getChild(index) as? TextNode,
      let lastToInsert = nodes.last as? TextNode
    {
      let toOffset = lastToInsert.stringLength
      let concated = TextNode(lastToInsert.string + nextNode.string)
      elementNode.replaceChild(concated, at: index, inStorage: true)
      let nodesMinus = nodes.dropLast()
      elementNode.insertChildren(contentsOf: nodesMinus, at: index, inStorage: true)
      return ([index], [index + nodes.count - 1, toOffset])
    }
    // if merge with (index-1)-th child is possible
    if index > 0,
      let prevNode = elementNode.getChild(index - 1) as? TextNode,
      let firstToInsert = nodes.first as? TextNode
    {
      let fromOffset = prevNode.stringLength
      let concated = TextNode(prevNode.string + firstToInsert.string)
      elementNode.replaceChild(concated, at: index - 1, inStorage: true)
      let nodesMinus = nodes.dropFirst()
      elementNode.insertChildren(contentsOf: nodesMinus, at: index, inStorage: true)
      return ([index - 1, fromOffset], [index + nodes.count - 1])
    }
    else {
      elementNode.insertChildren(contentsOf: nodes, at: index, inStorage: true)
      return ([index], [index + nodes.count])
    }
  }

  // MARK: - Insert paragraph nodes

  /// Insert paragraph nodes into a tree at given location.
  /// (The method also applies to `topLevelNodes`.)
  /// - Returns: The range of inserted content.
  static func insertParagraphNodes(
    _ nodes: [Node], at location: TextLocation, _ tree: RootNode
  ) -> SatzResult<RhTextRange> {
    precondition(!nodes.isEmpty)
    precondition(nodes.allSatisfy(isTopLevelNode(_:)))

    // if the content is empty, return the original location
    guard !nodes.isEmpty else {
      return .success(RhTextRange(location))
    }

    do {
      let location = location.asPartialLocation
      let range = try insertParagraphNodes(nodes, at: location, tree)
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
  ) throws -> RhTextRange {
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
      return composeRange(trace.map(\.index), newRange)
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
        nodes, textNode: textNode, offset: offset,
        parent, index, grandParent, grandIndex)
      // compose
      let prefix = trace.dropLast(3).map(\.index)
      return try composeRange(prefix, from, to, SatzError(.InsertNodesFailure))

    case let container as ElementNode where isParagraphContainerLike(container):
      let index = location.offset
      guard index <= container.childCount else {
        throw SatzError(.InvalidTextLocation, message: "index out of range")
      }
      let (from, to) =
        insertParagraphNodes(nodes, paragraphContainer: container, index: index)
      // compose
      let prefix = trace.dropLast().map(\.index)
      return try composeRange(prefix, from, to, SatzError(.InsertNodesFailure))

    case let paragraph as ParagraphNode:
      let offset = location.offset
      guard trace.count >= 2,
        // get parent and index
        let secondLast = trace.dropLast().last,
        let parent = secondLast.node as? ElementNode,
        let index = secondLast.index.index(),
        isParagraphContainerLike(parent),
        // check offset
        offset <= paragraph.childCount
      else { throw SatzError(.InvalidTextLocation) }
      let (from, to) = try insertParagraphNodes(
        nodes, paragraphNode: paragraph, offset: offset, parent, index)
      // compose
      let prefix = trace.dropLast(2).map(\.index)
      return try composeRange(prefix, from, to, SatzError(.InsertNodesFailure))

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
      if isMergeableElements(paragraphNode, node) {
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
        return ([grandIndex] + from, [grandIndex + 2, 0])
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

    // if last-to-insert and neighbouring node are mergeable
    if index < container.childCount,
      let lastToInsert = nodes.last as? ElementNode,
      let neighbour = container.getChild(index) as? ElementNode,
      isMergeableElements(lastToInsert, neighbour)
    {
      let children = lastToInsert.takeChildren(inStorage: false)
      let (_, to) = insertInlineContent(children, elementNode: neighbour, index: 0)
      let nodesMinus = nodes.dropLast()
      container.insertChildren(contentsOf: nodesMinus, at: index, inStorage: true)
      return ([index], [index + nodes.count - 1] + to)
    }
    else {
      container.insertChildren(contentsOf: nodes, at: index, inStorage: true)
      return ([index], [index + nodes.count])
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
      let tailPart = paragraphNode.takeSubrange(offset..<childCount, inStorage: true)
      return (tailPart, [offset])
    }

    if nodes.count == 1 {
      let node = nodes[0]
      // if paragraphNode and node are mergeable, splice the node with paragraphNode
      if isMergeableElements(paragraphNode, node) {
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
        return ([index] + from, [index + 2, 0])
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
    let mergeable0 = isMergeableElements(paragraphNode, firstToInsert)
    let mergeable1 = isMergeableElements(lastToInsert, paragraphNode)

    switch (mergeable0, mergeable1) {
    case (false, false):
      let (tailPart, from) = takeTailPart()
      let nodesPlus = chain(nodes, [ParagraphNode(tailPart)])
      parent.insertChildren(contentsOf: nodesPlus, at: index + 1, inStorage: true)
      return ([index] + from, [index + 1 + nodes.count, 0])

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
      let children = firstToInsert.takeChildren(inStorage: false)
      let (from1, _) =
        insertInlineContent(children, elementNode: paragraphNode, index: offset)
      // 3) insert the tail part and the rest of nodes into parent
      let nodesPlus = chain(nodes.dropFirst(), [ParagraphNode(tailPart)])
      parent.insertChildren(contentsOf: nodesPlus, at: index + 1, inStorage: true)
      return ([index] + from1, [index + 1 + nodes.count - 1, 0])

    case (true, true):
      guard let firstToInsert = firstToInsert as? ElementNode,
        let lastToInsert = lastToInsert as? ElementNode
      else { throw SatzError(.ElementNodeExpected) }
      // 1) take the part of paragraph node after split point
      let (tailPart, _) = takeTailPart()
      // 2) insert the children of firstToInsert into paragraphNode
      let children = firstToInsert.takeChildren(inStorage: false)
      let (from1, _) =
        insertInlineContent(children, elementNode: paragraphNode, index: offset)
      // 3) insert the rest of nodes into parent
      let nodesMinus = nodes.dropFirst()
      parent.insertChildren(contentsOf: nodesMinus, at: index + 1, inStorage: true)
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
  ) -> SatzResult<RhTextRange> {
    precondition(string.isEmpty == false)
    do {
      let location = location.asPartialLocation
      let range = try insertString(string, at: location, tree)
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
  ) throws -> RhTextRange {
    precondition(!string.isEmpty)

    let traceResult = tryBuildTrace(for: location, subtree, until: isArgumentNode(_:))
    guard let (trace, truthMaker) = traceResult
    else { throw SatzError(.InvalidTextLocation) }

    // if truthMaker is not nil, ArgumentNode is found
    if truthMaker != nil {
      let argumentNode = truthMaker as! ArgumentNode
      let newLocation = location.dropFirst(trace.count)
      let newRange = try argumentNode.insertString(string, at: newLocation)
      return composeRange(trace.map(\.index), newRange)
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
      // compose
      let prefix = trace.dropLast(2).map(\.index)
      return try composeRange(prefix, from, to, SatzError(.InsertStringFailure))

    case let container as ElementNode where isParagraphContainerLike(container):
      let index = location.offset
      guard index <= container.childCount
      else { throw SatzError(.InvalidTextLocation) }
      let (from, to) = insertString(string, paragraphContainer: container, index: index)
      // compose
      let prefix = trace.dropLast().map(\.index)
      return try composeRange(prefix, from, to, SatzError(.InsertStringFailure))

    case let elementNode as ElementNode:
      let index = location.offset
      guard index <= elementNode.childCount
      else { throw SatzError(.InvalidTextLocation) }
      let (from, to) = insertString(string, elementNode: elementNode, index: index)
      // compose
      let prefix = trace.dropLast().map(\.index)
      return try composeRange(prefix, from, to, SatzError(.InsertStringFailure))

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

    // if insert into index-th child is possible
    if index < container.childCount,
      let child = container.getChild(index) as? ElementNode,
      child.isTransparent
    {
      let (from, to) = insertString(string, elementNode: child, index: 0)
      return ([index] + from, [index] + to)
    }
    // otherwise, create a new paragraph node
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

    // if merge with index-th child is possible
    if index < elementNode.childCount,
      let textNode = elementNode.getChild(index) as? TextNode
    {
      return insertString(string, textNode: textNode, offset: 0, elementNode, index)
    }
    // if merge with (index-1)-th child is possible
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

  // MARK: - Helper

  /// Compose range from `prefix`, `location`, and `end`.
  private static func composeRange(
    _ prefix: [RohanIndex], _ location: [Int], _ end: [Int],
    _ error: @autoclosure () -> SatzError
  ) throws -> RhTextRange {
    let location = composeLocation(location)
    let end = composeLocation(end)
    guard let range = RhTextRange(location, end) else { throw error() }
    return range

    // Helper
    func composeLocation(_ location: [Int]) -> TextLocation {
      precondition(!location.isEmpty)
      let indices = prefix + location.dropLast().map(RohanIndex.index)
      let offset = location.last!
      return TextLocation(indices, offset)
    }
  }

  /// Compose range from `prefix`, and `range`.
  static func composeRange(_ prefix: [RohanIndex], _ range: RhTextRange) -> RhTextRange {
    let location = composeLocation(range.location)
    let endLocation = composeLocation(range.endLocation)
    return RhTextRange(location, endLocation)!

    // Helper
    func composeLocation(_ location: TextLocation) -> TextLocation {
      let indices = prefix + location.indices
      return TextLocation(indices, location.offset)
    }
  }
}
