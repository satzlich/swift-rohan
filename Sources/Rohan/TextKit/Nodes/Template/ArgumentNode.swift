// Copyright 2024-2025 Lie Yan
import AppKit
import _RopeModule

final class ArgumentNode: Node {
  override class var type: NodeType { .argument }

  /// associated apply node
  private weak var applyNode: ApplyNode? = nil

  func setApplyNode(_ applyNode: ApplyNode) {
    precondition(self.applyNode == nil)
    self.applyNode = applyNode
  }

  func isAssociated(with applyNode: ApplyNode) -> Bool {
    self.applyNode === applyNode
  }

  let argumentIndex: Int
  /** associated variable nodes */
  let variableNodes: [VariableNode]

  init(_ variableNodes: [VariableNode], _ argumentIndex: Int) {
    precondition(!variableNodes.isEmpty)

    self.variableNodes = variableNodes
    self.argumentIndex = argumentIndex
    super.init()

    variableNodes.forEach { $0.setArgumentNode(self) }
  }

  // MARK: - Codable

  required init(from decoder: any Decoder) throws {
    preconditionFailure("should not be called. Work is done in ApplyNode.")
  }

  override func encode(to encoder: any Encoder) throws {
    preconditionFailure("should not be called. Work is done in ApplyNode.")
  }

  func getArgumentValue_readonly() -> ElementNode.Store {
    variableNodes[0].getChildren_readonly()
  }

  // MARK: - Content

  var childCount: Int { variableNodes[0].childCount }

  override func getChild(_ index: RohanIndex) -> Node? {
    variableNodes[0].getChild(index)
  }

  func getChild(_ index: Int) -> Node {
    precondition(index < childCount)
    return variableNodes[0].getChild(index)
  }

  final func enumerateContents(
    _ location: TextLocationSlice, _ endLocation: TextLocationSlice,
    using block: DocumentManager.EnumerateContentsBlock
  ) throws -> Bool {
    try NodeUtils.enumerateContents(location, endLocation, variableNodes[0], using: block)
  }

  override final func stringify() -> BigString { variableNodes[0].stringify() }

  /// Returns the content container category of the argument.
  func getContentContainerCategory() -> ContentContainerCategory? {
    let categories: [ContentContainerCategory] =
      variableNodes.compactMap { variable in
        guard let parent = variable.parent else { return nil }
        return NodeUtils.contentContainerCategory(of: parent)
      }
    if categories.count != variableNodes.count {
      return nil
    }
    else {
      let candidate = categories[1...].reduce(categories[0]) { a, b in
        a.intersection(b)
      }
      // enforce extra restriction
      let restriction: ContentContainerCategory = .inlineTextContainer.union(.mathList)
      return candidate.intersection(restriction)
    }
  }

  // MARK: - Location

  override func firstIndex() -> RohanIndex? {
    variableNodes[0].firstIndex()
  }

  override func lastIndex() -> RohanIndex? {
    variableNodes[0].lastIndex()
  }

  // MARK: - Layout

  override var layoutLength: Int {
    assertionFailure("should not be called")
    return 1
  }

  override func getLayoutOffset(_ index: RohanIndex) -> Int? {
    assertionFailure("should not be called")
    return nil
  }

  override func getRohanIndex(_ layoutOffset: Int) -> (RohanIndex, consumed: Int)? {
    assertionFailure("should not be called")
    return nil
  }

  override func enumerateTextSegments(
    _ path: ArraySlice<RohanIndex>, _ endPath: ArraySlice<RohanIndex>,
    _ context: any LayoutContext, layoutOffset: Int, originCorrection: CGPoint,
    type: DocumentManager.SegmentType, options: DocumentManager.SegmentOptions,
    using block: DocumentManager.EnumerateTextSegmentsBlock
  ) -> Bool {
    assertionFailure(
      """
      \(#function) should not be called for \(Swift.type(of: self)). \
      The work is done by ApplyNode.
      """)
    return false
  }

  override func resolveTextLocation(
    with point: CGPoint, _ context: any LayoutContext,
    _ trace: inout Trace
  ) -> Bool {
    assertionFailure(
      """
      \(#function) should not be called for \(Swift.type(of: self)). \
      The work is done by ApplyNode.
      """)
    return false
  }

  override func rayshoot(
    from path: ArraySlice<RohanIndex>, _ direction: TextSelectionNavigation.Direction,
    _ context: any LayoutContext, layoutOffset: Int
  ) -> RayshootResult? {
    assertionFailure(
      """
      \(#function) should not be called for \(Swift.type(of: self)). \
      The work is done by ApplyNode.
      """)
    return nil
  }

  // MARK: - Children

  func insertChildren(contentsOf nodes: [Node], at index: Int, inStorage: Bool) {
    precondition(variableNodes.count >= 1)
    // this works for count == 1 and count > 1
    for variable in variableNodes[1...] {
      variable.insertChildren(
        contentsOf: nodes.map { $0.deepCopy() }, at: index, inStorage: inStorage)
    }
    variableNodes[0].insertChildren(contentsOf: nodes, at: index, inStorage: inStorage)
  }

  /// Insert string at given location.
  /// - Returns: range of the inserted content.
  func insertString(
    _ string: BigString, at location: TextLocationSlice
  ) throws -> RhTextRange {
    precondition(variableNodes.count >= 1)
    for variable in variableNodes.dropFirst() {
      _ = try NodeUtils.insertString(string, at: location, variable)
    }
    return try NodeUtils.insertString(string, at: location, variableNodes[0])
  }

  /// Insert inline content at given location.
  /// - Returns: range of the inserted content.
  func insertInlineContent(
    _ nodes: [Node], at location: TextLocationSlice
  ) throws -> RhTextRange {
    precondition(!variableNodes.isEmpty)
    for variableNode in variableNodes[1...] {
      let nodesCopy = nodes.map { $0.deepCopy() }
      _ = try NodeUtils.insertInlineContent(nodesCopy, at: location, variableNode)
    }
    return try NodeUtils.insertInlineContent(nodes, at: location, variableNodes[0])
  }

  /// Insert paragraph nodes at given location.
  /// - Returns: range of the inserted content.
  func insertParagraphNodes(
    _ nodes: [Node], at location: TextLocationSlice
  ) throws -> RhTextRange {
    precondition(!variableNodes.isEmpty)
    for variableNode in variableNodes[1...] {
      let nodesCopy = nodes.map { $0.deepCopy() }
      _ = try NodeUtils.insertParagraphNodes(nodesCopy, at: location, variableNode)
    }
    return try NodeUtils.insertParagraphNodes(nodes, at: location, variableNodes[0])
  }

  /// Remove range from the argument node.
  func removeSubrange(
    _ location: TextLocationSlice, _ endLocation: TextLocationSlice,
    _ insertionPoint: inout MutableTextLocation
  ) throws {
    precondition(variableNodes.count >= 1)
    // this works for count == 1 and count > 1
    for variable in variableNodes[1...] {
      var insertionPointCopy = insertionPoint
      _ = try NodeUtils.removeTextSubrange(
        location, endLocation, variable, nil, &insertionPointCopy)
    }
    _ = try NodeUtils.removeTextSubrange(
      location, endLocation, variableNodes[0], nil, &insertionPoint)
  }

  // MARK: - Clone and Visitor

  override func deepCopy() -> Node {
    preconditionFailure("\(#function) should not be called for \(Swift.type(of: self))")
  }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(argument: self, context)
  }
}
