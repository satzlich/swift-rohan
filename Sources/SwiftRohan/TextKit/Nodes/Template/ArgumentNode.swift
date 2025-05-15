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
  /// associated variable nodes
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
    variableNodes.first!.getChildren_readonly()
  }

  // MARK: - Content

  var childCount: Int { variableNodes.first!.childCount }

  override func getChild(_ index: RohanIndex) -> Node? {
    variableNodes.first!.getChild(index)
  }

  func getChild(_ index: Int) -> Node {
    precondition(index < childCount)
    return variableNodes.first!.getChild(index)
  }

  final func enumerateContents(
    _ location: TextLocationSlice, _ endLocation: TextLocationSlice,
    using block: DocumentManager.EnumerateContentsBlock
  ) throws -> Bool {
    try TreeUtils.enumerateContents(
      location, endLocation, variableNodes.first!, using: block)
  }

  /// Returns the content container category of the argument.
  func getContainerCategory() -> ContainerCategory? {
    let categories: [ContainerCategory] =
      variableNodes.compactMap { variable in
        guard let parent = variable.parent else { return nil }
        return TreeUtils.containerCategory(of: parent)
      }
    if categories.count != variableNodes.count {
      return nil
    }
    else {
      let candidate = categories.dropFirst().reduce(categories.first!) { a, b in
        a.intersection(b)
      }
      // enforce extra restriction
      let restriction: ContainerCategory = .inlineContentContainer.union(.mathContainer)
      return candidate.intersection(restriction)
    }
  }

  // MARK: - Location

  override func firstIndex() -> RohanIndex? {
    variableNodes.first!.firstIndex()
  }

  override func lastIndex() -> RohanIndex? {
    variableNodes.first!.lastIndex()
  }

  // MARK: - Layout

  override func layoutLength() -> Int { return 1 }

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
    _ trace: inout Trace, _ affinity: inout RhTextSelection.Affinity
  ) -> Bool {
    assertionFailure(
      """
      \(#function) should not be called for \(Swift.type(of: self)). \
      The work is done by ApplyNode.
      """)
    return false
  }

  override func rayshoot(
    from path: ArraySlice<RohanIndex>,
    affinity: RhTextSelection.Affinity,
    direction: TextSelectionNavigation.Direction,
    context: any LayoutContext, layoutOffset: Int
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
    for variable in variableNodes.dropFirst() {
      variable.insertChildren(
        contentsOf: nodes.map { $0.deepCopy() }, at: index, inStorage: inStorage)
    }
    variableNodes.first!.insertChildren(
      contentsOf: nodes, at: index, inStorage: inStorage)
  }

  /// Insert string at given location.
  /// - Returns: range of the inserted content.
  func insertString(
    _ string: RhString, at location: TextLocationSlice
  ) throws -> RhTextRange {
    precondition(variableNodes.count >= 1)
    for variable in variableNodes.dropFirst() {
      _ = try TreeUtils.insertString(string, at: location, variable)
    }
    return try TreeUtils.insertString(string, at: location, variableNodes.first!)
  }

  /// Insert inline content at given location.
  /// - Returns: range of the inserted content.
  func insertInlineContent(
    _ nodes: [Node], at location: TextLocationSlice
  ) throws -> RhTextRange {
    precondition(!variableNodes.isEmpty)
    for variableNode in variableNodes.dropFirst() {
      let nodesCopy = nodes.map { $0.deepCopy() }
      _ = try TreeUtils.insertInlineContent(nodesCopy, at: location, variableNode)
    }
    return try TreeUtils.insertInlineContent(nodes, at: location, variableNodes.first!)
  }

  /// Insert paragraph nodes at given location.
  /// - Returns: range of the inserted content.
  func insertParagraphNodes(
    _ nodes: [Node], at location: TextLocationSlice
  ) throws -> RhTextRange {
    precondition(!variableNodes.isEmpty)
    for variableNode in variableNodes.dropFirst() {
      let nodesCopy = nodes.map { $0.deepCopy() }
      _ = try TreeUtils.insertParagraphNodes(nodesCopy, at: location, variableNode)
    }
    return try TreeUtils.insertParagraphNodes(nodes, at: location, variableNodes.first!)
  }

  /// Remove range from the argument node.
  func removeSubrange(
    _ location: TextLocationSlice, _ endLocation: TextLocationSlice,
    _ insertionPoint: inout MutableTextLocation
  ) throws {
    precondition(variableNodes.count >= 1)
    for variable in variableNodes.dropFirst() {
      var insertionPointCopy = insertionPoint
      _ = try TreeUtils.removeTextSubrange(
        location, endLocation, variable, nil, &insertionPointCopy)
    }
    _ = try TreeUtils.removeTextSubrange(
      location, endLocation, variableNodes.first!, nil, &insertionPoint)
  }

  // MARK: - Clone and Visitor

  override func deepCopy() -> Node {
    preconditionFailure("\(#function) should not be called for \(Swift.type(of: self))")
  }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(argument: self, context)
  }

  override class var storageTags: [String] {
    // intentionally empty
    []
  }

  override func store() -> JSONValue {
    preconditionFailure("not implemented")
  }

  override class func load(from json: JSONValue) -> _LoadResult {
    preconditionFailure("not implemented")
  }

}
