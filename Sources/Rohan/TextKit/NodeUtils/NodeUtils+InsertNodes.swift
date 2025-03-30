// Copyright 2024-2025 Lie Yan

import Algorithms
import _RopeModule

extension NodeUtils {
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
    // Consider three cases:
    //  1) text node,
    //  2) paragraph container, or
    //  3) element node other than paragraph container.
    switch trace.last!.node {
    case let textNode as TextNode:
      let offset = location.offset
      guard
        // get parent and index
        let secondLast = trace.dropLast().last,
        let parent = secondLast.node as? ElementNode,
        let index = secondLast.index.index(),
        // check offset
        offset <= textNode.llength
      else { throw SatzError(.InvalidTextLocation) }
      // perform insertion
      let (from, to) =
        insertString(string, textNode: textNode, offset: offset, parent, index)
      // compose range
      let prefix = trace.dropLast(2).map(\.index)
      return try composeRange(prefix, from, to, SatzError(.InsertStringFailure))

    case let container as ElementNode where container.isParagraphContainer:
      let index = location.offset
      guard index <= container.childCount else { throw SatzError(.InvalidTextLocation) }
      let (from, to) = insertString(string, paragraphContainer: container, index: index)
      // compose range
      let prefix = trace.dropLast().map(\.index)
      return try composeRange(prefix, from, to, SatzError(.InsertStringFailure))

    case let elementNode as ElementNode:
      let index = location.offset
      guard index <= elementNode.childCount else { throw SatzError(.InvalidTextLocation) }
      let (from, to) = insertString(string, elementNode: elementNode, index: index)
      // compose range
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
    precondition(offset <= textNode.llength)
    precondition(parent.getChild(index) === textNode)
    let newTextNode = textNode.inserted(string, at: offset)
    parent.replaceChild(newTextNode, at: index, inStorage: true)
    return ([index, offset], [index, offset + string.llength])
  }

  /// Insert string into container at given index.
  /// - Returns: the range of inserted content (starting from the depth of given
  ///     index, not offset).
  private static func insertString(
    _ string: BigString, paragraphContainer container: ElementNode, index: Int
  ) -> ([Int], [Int]) {
    precondition(container.isParagraphContainer)
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
    precondition(elementNode.isParagraphContainer == false)
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
        string, textNode: textNode, offset: textNode.llength,
        elementNode, index - 1)
    }
    // otherwise, create a new text node
    else {
      elementNode.insertChild(TextNode(string), at: index, inStorage: true)
      return ([index, 0], [index, string.llength])
    }
  }

  // MARK: - Insert inline content

  /// Insert inline content into a tree at given location.
  /// - Returns: The range of inserted content if insertion is successful;
  ///     otherwise, an error.
  static func insertInlineContent(
    _ nodes: [Node], at location: TextLocation, _ tree: RootNode
  ) -> SatzResult<RhTextRange> {
    precondition(!nodes.isEmpty)
    precondition(nodes.allSatisfy { NodePolicy.canBeTopLevel($0) == false })

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
    precondition(nodes.allSatisfy { NodePolicy.canBeTopLevel($0) == false })

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
    // Consider three cases:
    //  1) text node,
    //  2) paragraph container, or
    //  3) element node other than paragraph container.
    switch trace.last!.node {
    case let textNode as TextNode:
      let offset = location.offset
      guard trace.count >= 2,
        // get parent and index
        let secondLast = trace.dropLast().last,
        let parent = secondLast.node as? ElementNode,
        let index = secondLast.index.index(),
        // check offset
        offset <= textNode.llength
      else { throw SatzError(.InvalidTextLocation) }
      // perform insertion
      let (from, to) =
        insertInlineContent(nodes, textNode: textNode, offset: offset, parent, index)
      // compose range
      let prefix = trace.dropLast(2).map(\.index)
      return try composeRange(prefix, from, to, SatzError(.InsertNodesFailure))

    case let container as ElementNode where container.isParagraphContainer:
      let index = location.offset
      guard index <= container.childCount else { throw SatzError(.InvalidTextLocation) }
      // perform insertion
      let (from, to) =
        insertInlineContent(nodes, paragraphContainer: container, index: index)
      // compose range
      let prefix = trace.dropLast().map(\.index)
      return try composeRange(prefix, from, to, SatzError(.InsertNodesFailure))

    case let elementNode as ElementNode:
      let index = location.offset
      guard index <= elementNode.childCount else { throw SatzError(.InvalidTextLocation) }
      // perform insertion
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
    precondition(!nodes.isEmpty)
    precondition(nodes.allSatisfy { NodePolicy.canBeTopLevel($0) == false })
    precondition(parent.getChild(index) === textNode)

    // for single text node
    if let node = nodes.getOnlyTextNode() {
      return insertString(node.string, textNode: textNode, offset: offset, parent, index)
    }

    // if offset is at the end of the text
    if offset == textNode.llength {
      return insertInlineContent(nodes, elementNode: parent, index: index + 1)
    }
    // if offset is at the beginning of the text
    else if offset == 0 {
      return insertInlineContent(nodes, elementNode: parent, index: index)
    }
    // otherwise (offset is in the middle of the text)
    assert(offset > 0 && offset < textNode.llength)

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
      return ([index, part0.llength], [index + 1 + nodes.count])

    case (.none, .some(let lastNode)):
      // replace with part0
      parent.replaceChild(TextNode(part0), at: index, inStorage: true)
      // append part1 to nodes
      var nodesPlus = nodes
      nodesPlus[nodes.endIndex - 1] = TextNode(lastNode.string + part1)
      // insert nodesPlus
      _ = insertInlineContent(nodesPlus, elementNode: parent, index: index + 1)
      let toOffset = lastNode.llength
      return ([index, part0.llength], [index + 1 + nodes.count - 1, toOffset])

    case (.some(let firstNode), .none):
      // concate part0 with the first node
      let concated = TextNode(part0 + firstNode.string)
      parent.replaceChild(concated, at: index, inStorage: true)
      // append part1 to nodes
      let nodesPlus = chain(nodes[1...], CollectionOfOne(TextNode(part1)))
      // insert nodesPlus
      _ = insertInlineContent(nodesPlus, elementNode: parent, index: index + 1)
      let fromOffset = part0.llength
      return ([index, fromOffset], [index + 1 + nodes.count - 1])

    case (.some(let firstNode), .some(let lastNode)):
      assert(firstNode !== lastNode)
      // concate part0 with the first node
      let prevConcated = TextNode(part0 + firstNode.string)
      parent.replaceChild(prevConcated, at: index, inStorage: true)
      // concate the last node with part1
      let nextConcated = TextNode(lastNode.string + part1)
      var nodesPlus = Array(nodes[1...])
      nodesPlus[nodesPlus.endIndex - 1] = nextConcated
      // insert nodesPlus
      _ = insertInlineContent(nodesPlus, elementNode: parent, index: index + 1)
      // compose range
      let fromOffset = part0.llength
      let toOffset = lastNode.llength
      return ([index, fromOffset], [index + 1 + nodesPlus.count - 1, toOffset])
    }
  }

  /// Insert inline content into paragraph container at given index.
  /// - Returns: The range of inserted content (starting at the depth of given index)
  private static func insertInlineContent(
    _ nodes: [Node], paragraphContainer container: ElementNode, index: Int
  ) -> ([Int], [Int]) {
    precondition(!nodes.isEmpty)
    precondition(nodes.allSatisfy { NodePolicy.canBeTopLevel($0) == false })
    precondition(index <= container.childCount)

    // if merge with index-th child is possible
    if index < container.childCount,
      let child = container.getChild(index) as? ElementNode,
      child.isTransparent
    {
      let (from, to) = insertInlineContent(nodes, elementNode: child, index: 0)
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
    precondition(nodes.allSatisfy { NodePolicy.canBeTopLevel($0) == false })
    precondition(index <= elementNode.childCount)

    // nodes is allowed to be empty here
    guard !nodes.isEmpty else { return ([index], [index]) }

    // if merge with index-th child is possible
    if index < elementNode.childCount,
      let child = elementNode.getChild(index) as? TextNode,
      let last = nodes.last as? TextNode
    {
      // merge the last node with the index-th child
      let lastPlus = TextNode(last.string + child.string)
      elementNode.replaceChild(lastPlus, at: index, inStorage: true)
      // insert the rest of nodes
      let nodesMinus = nodes.dropLast()
      elementNode.insertChildren(contentsOf: nodesMinus, at: index, inStorage: true)
      // compose range
      let toOffset = last.llength
      return ([index], [index + nodes.count - 1, toOffset])
    }
    // if merge with (index-1)-th child is possible
    if index > 0,
      let child = elementNode.getChild(index - 1) as? TextNode,
      let first = nodes.first as? TextNode
    {
      // merge the first node with the (index-1)-th child
      let firstPlus = TextNode(child.string + first.string)
      elementNode.replaceChild(firstPlus, at: index - 1, inStorage: true)
      // insert the rest of nodes
      let nodesMinus = nodes.dropFirst()
      elementNode.insertChildren(contentsOf: nodesMinus, at: index, inStorage: true)
      // compose range
      let fromOffset = child.llength
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
    precondition(nodes.allSatisfy(NodePolicy.canBeTopLevel(_:)))

    // if the content is empty, return the original location
    guard !nodes.isEmpty else { return .success(RhTextRange(location)) }

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
    precondition(nodes.allSatisfy(NodePolicy.canBeTopLevel(_:)))

    let traceResult = tryBuildTrace(for: location, subtree, until: isArgumentNode(_:))
    guard let (trace, truthMaker) = traceResult
    else { throw SatzError(.InvalidTextLocation) }

    // if truthMaker is not nil, ArgumentNode is found
    if truthMaker != nil {
      let argumentNode = truthMaker as! ArgumentNode
      let newLocation = location.dropFirst(trace.count)
      let newRange = try argumentNode.insertParagraphNodes(nodes, at: newLocation)
      return composeRange(trace.map(\.index), newRange)
    }
    assert(truthMaker == nil)
    // otherwise, the final location is found
    // Consider three cases:
    //  1) text node,
    //  2) paragraph container, or
    //  3) element node other than paragraph container.
    switch trace.last!.node {
    case let textNode as TextNode:
      let offset = location.offset
      guard trace.count >= 3,
        // get grand parent and index
        let thirdLast = trace.dropLast(2).last,
        let grandParent = thirdLast.node as? ElementNode,
        grandParent.isParagraphContainer,
        let grandIndex = thirdLast.index.index(),
        // get parent and index
        let secondLast = trace.dropLast().last,
        let parent = secondLast.node as? ParagraphNode,
        let index = secondLast.index.index(),
        // check index and offset
        offset <= textNode.llength
      else { throw SatzError(.InvalidTextLocation) }
      // perform insertion
      let (from, to) = try insertParagraphNodes(
        nodes, textNode: textNode, offset: offset,
        parent, index, grandParent, grandIndex)
      // compose range
      let prefix = trace.dropLast(3).map(\.index)
      return try composeRange(prefix, from, to, SatzError(.InsertNodesFailure))

    case let container as ElementNode where container.isParagraphContainer:
      let index = location.offset
      guard index <= container.childCount else { throw SatzError(.InvalidTextLocation) }
      // perform insertion
      let (from, to) =
        insertParagraphNodes(nodes, paragraphContainer: container, index: index)
      // compose range
      let prefix = trace.dropLast().map(\.index)
      return try composeRange(prefix, from, to, SatzError(.InsertNodesFailure))

    case let paragraph as ParagraphNode:
      let offset = location.offset
      guard trace.count >= 2,
        // get parent and index
        let secondLast = trace.dropLast().last,
        let parent = secondLast.node as? ElementNode,
        let index = secondLast.index.index(),
        parent.isParagraphContainer,
        // check offset
        offset <= paragraph.childCount
      else { throw SatzError(.InvalidTextLocation) }
      // perform insertion
      let (from, to) = try insertParagraphNodes(
        nodes, paragraphNode: paragraph, offset: offset, parent, index)
      // compose range
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
    _ paragraph: ParagraphNode, _ index: Int,
    _ grandParent: ElementNode, _ grandIndex: Int
  ) throws -> ([Int], [Int]) {
    precondition(nodes.allSatisfy(NodePolicy.canBeTopLevel(_:)))
    precondition(grandParent.isParagraphContainer)
    precondition(grandParent.getChild(grandIndex) === paragraph)
    precondition(paragraph.getChild(index) === textNode)

    // if offset is at the end of the text, forward to another
    // `insertParagraphNodes(...)`
    if offset == textNode.llength {
      return try insertParagraphNodes(
        nodes, paragraphNode: paragraph, offset: index + 1, grandParent, grandIndex)
    }
    // if offset is at the beginning of the text, forward to another
    // `insertParagraphNodes(...)`
    else if offset == 0 {
      return try insertParagraphNodes(
        nodes, paragraphNode: paragraph, offset: index, grandParent, grandIndex)
    }

    assert(offset > 0 && offset < textNode.llength)

    // get the part of paragraph node after (index, offset) and
    // location before (index, offset) starting from the depth of index
    func takeTailPart() -> (ElementNode.Store, [Int]) {
      // split the text node at offset
      let (text0, text1) = StringUtils.strictSplit(textNode.string, at: offset)
      // replace the text node at index with text0
      paragraph.replaceChild(TextNode(text0), at: index, inStorage: true)
      // get the children of paragraph node after index
      let childCount = paragraph.childCount
      var children = paragraph.takeSubrange(index + 1..<childCount, inStorage: true)
      // prepend text1 to the children
      children.insert(TextNode(text1), at: 0)
      return (children, [index, offset])
    }

    if nodes.count == 1 {
      let node = nodes[0]
      // if paragraphNode and node are mergeable, splice the node with paragraphNode
      if let node = node as? ElementNode,
        paragraph.isMergeable(with: node)
      {
        let children = node.takeChildren(inStorage: false)
        let (from, to) = insertInlineContent(
          children, textNode: textNode, offset: offset, paragraph, index)
        return ([grandIndex] + from, [grandIndex] + to)
      }
      // otherwise, insert the node
      else {
        let (tail, from) = takeTailPart()
        let nodesPlus = [node, ParagraphNode(tail)]
        grandParent.insertChildren(
          contentsOf: nodesPlus, at: grandIndex + 1, inStorage: true)
        return ([grandIndex] + from, [grandIndex + 2, 0])
      }
    }
    else {
      // pass `offset:= index+1` as we must insert after the node at `index`
      return try insertParagraphNodes_helper(
        nodes, paragraphNode: paragraph, offset: index + 1, grandParent, grandIndex,
        takeTailPart: takeTailPart)
    }
  }

  /// Insert paragraph nodes into paragraph container at given index.
  /// - Returns: The range of inserted content (starting at the depth of given index)
  private static func insertParagraphNodes(
    _ nodes: [Node], paragraphContainer container: ElementNode, index: Int
  ) -> ([Int], [Int]) {
    precondition(index <= container.childCount)
    precondition(!nodes.isEmpty)
    precondition(nodes.allSatisfy(NodePolicy.canBeTopLevel(_:)))

    // if last-to-insert and neighbouring node are mergeable
    if index < container.childCount,
      let last = nodes.last as? ElementNode,
      let child = container.getChild(index) as? ElementNode,
      last.isMergeable(with: child)
    {
      let children = last.takeChildren(inStorage: false)
      let (_, to) = insertInlineContent(children, elementNode: child, index: 0)
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
    _ nodes: [Node], paragraphNode paragraph: ParagraphNode, offset: Int,
    _ parent: ElementNode, _ index: Int
  ) throws -> ([Int], [Int]) {
    precondition(!nodes.isEmpty)
    precondition(nodes.allSatisfy(NodePolicy.canBeTopLevel(_:)))
    precondition(offset <= paragraph.childCount)
    precondition(parent.getChild(index) === paragraph)

    // if offset is at the beginning of the paragraph node, forward to another
    // `insertParagraphNodes(...)`
    if offset == 0 {
      return insertParagraphNodes(nodes, paragraphContainer: parent, index: index)
    }

    // get the part of paragrpah node after offset and the location before
    // offset starting from the depth of offset
    func takeTailPart() -> (ElementNode.Store, [Int]) {
      let childCount = paragraph.childCount
      let tail = paragraph.takeSubrange(offset..<childCount, inStorage: true)
      return (tail, [offset])
    }

    if nodes.count == 1 {
      let node = nodes[0]
      // if paragraphNode and node are mergeable, splice the node with paragraphNode
      if let node = node as? ElementNode,
        paragraph.isMergeable(with: node)
      {
        let children = node.takeChildren(inStorage: false)
        let (from, to) =
          insertInlineContent(children, elementNode: paragraph, index: offset)
        return ([index] + from, [index] + to)
      }
      // otherwise, insert the node
      else {
        let (tail, from) = takeTailPart()
        let nodesPlus = [node, ParagraphNode(tail)]
        parent.insertChildren(contentsOf: nodesPlus, at: index + 1, inStorage: true)
        return ([index] + from, [index + 2, 0])
      }
    }
    else {
      return try insertParagraphNodes_helper(
        nodes, paragraphNode: paragraph, offset: offset, parent, index,
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
          of split point starting from the depth of offset.
   - Returns: The range of the inserted content.
   - Precondition: nodes contains more than one node.
   - Precondition: offset is not zero.
   */
  private static func insertParagraphNodes_helper(
    _ nodes: [Node], paragraphNode paragraph: ParagraphNode, offset: Int,
    _ parent: ElementNode, _ index: Int,
    takeTailPart: () -> (ElementNode.Store, [Int])
  ) throws -> ([Int], [Int]) {
    precondition(nodes.count > 1, "single node should be handled elsewhere")
    precondition(nodes.allSatisfy(NodePolicy.canBeTopLevel(_:)))
    precondition(offset != 0)

    let first = nodes.first!
    let last = nodes.last!
    assert(first !== last)

    func isMergeableElements(_ lhs: Node, _ rhs: Node) -> Bool {
      NodePolicy.isMergeableElements(lhs.type, rhs.type)
    }
    // mergeable
    let mergeable0 = isMergeableElements(paragraph, first)
    let mergeable1 = isMergeableElements(last, paragraph)

    switch (mergeable0, mergeable1) {
    case (false, false):
      let (tail, from) = takeTailPart()
      let nodesPlus = chain(nodes, [ParagraphNode(tail)])
      parent.insertChildren(contentsOf: nodesPlus, at: index + 1, inStorage: true)
      return ([index] + from, [index + 1 + nodes.count, 0])

    case (false, true):
      guard let last = last as? ElementNode else { throw SatzError(.ElementNodeExpected) }
      // 1) take the part of paragraph node after split point
      let (tail, from0) = takeTailPart()
      // 2) insert nodes int parent
      parent.insertChildren(contentsOf: nodes, at: index + 1, inStorage: true)
      // 3) insert tail into last
      let (from1, _) =
        insertInlineContent(tail, elementNode: last, index: last.childCount)
      return ([index] + from0, [index + 1 + nodes.count - 1] + from1)

    case (true, false):
      guard let first = first as? ElementNode
      else { throw SatzError(.ElementNodeExpected) }
      // 1) take the part of paragraph node after split point
      let (tail, _) = takeTailPart()
      // 2) insert the children of first into paragraph node
      let children = first.takeChildren(inStorage: false)
      let (from1, _) =
        insertInlineContent(children, elementNode: paragraph, index: offset)
      // 3) insert the tail part and the rest of nodes into parent
      let nodesPlus = chain(nodes.dropFirst(), [ParagraphNode(tail)])
      parent.insertChildren(contentsOf: nodesPlus, at: index + 1, inStorage: true)
      return ([index] + from1, [index + 1 + nodes.count - 1, 0])

    case (true, true):
      guard let first = first as? ElementNode,
        let last = last as? ElementNode
      else { throw SatzError(.ElementNodeExpected) }
      // 1) take the part of paragraph node after split point
      let (tail, _) = takeTailPart()
      // 2) insert the children of first into paragraphNode
      let children = first.takeChildren(inStorage: false)
      let (from1, _) =
        insertInlineContent(children, elementNode: paragraph, index: offset)
      // 3) insert the rest of nodes into parent
      let nodesMinus = nodes.dropFirst()
      parent.insertChildren(contentsOf: nodesMinus, at: index + 1, inStorage: true)
      // 4) insert tail into last
      let (from2, _) =
        insertInlineContent(tail, elementNode: last, index: last.childCount)
      return ([index] + from1, [index + 1 + nodes.count - 2] + from2)
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
