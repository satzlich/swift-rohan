// Copyright 2024-2025 Lie Yan
import AppKit
import _RopeModule

final class ArgumentNode: Node {
  // MARK: - Node

  final override func deepCopy() -> Self {
    preconditionFailure("Work is done in ApplyNode.")
  }

  final override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(argument: self, context)
  }

  final override class var type: NodeType { .argument }

  // MARK: - Node(Positioning)

  final override func getChild(_ index: RohanIndex) -> Node? {
    variableNodes.first?.getChild(index)
  }

  final override func firstIndex() -> RohanIndex? {
    variableNodes.first?.firstIndex()
  }

  final override func lastIndex() -> RohanIndex? {
    variableNodes.first?.lastIndex()
  }

  final override func getLayoutOffset(_ index: RohanIndex) -> Int? {
    assertionFailure("should not be called")
    return nil
  }

  final override func getPosition(_ layoutOffset: Int) -> PositionResult<RohanIndex> {
    assertionFailure("should not be called")
    return .null
  }

  // MARK: - Node(Layout)

  final override func contentDidChange() {
    assertionFailure("should not be called")
  }

  final override func layoutLength() -> Int { 1 }  // always "1".

  // MARK: - Node(Codable)

  required init(from decoder: any Decoder) throws {
    preconditionFailure("Work is done in ApplyNode.")
  }

  final override func encode(to encoder: any Encoder) throws {
    preconditionFailure("Work is done in ApplyNode.")
  }

  // MARK: - Node(Storage)

  final override class var storageTags: Array<String> { /* empty */ [] }

  final override class func load(from json: JSONValue) -> NodeLoaded<Node> {
    preconditionFailure("Work is done in ApplyNode.")
  }

  final override func store() -> JSONValue {
    precondition(variableNodes.isEmpty == false)
    let first = variableNodes[0]
    let children: Array<JSONValue> = first.childrenReadonly().map { $0.store() }
    return JSONValue.array(children)
  }

  // MARK: - Node(Tree API)

  final override func enumerateTextSegments(
    _ path: ArraySlice<RohanIndex>, _ endPath: ArraySlice<RohanIndex>,
    context: any LayoutContext, layoutOffset: Int, originCorrection: CGPoint,
    type: DocumentManager.SegmentType, options: DocumentManager.SegmentOptions,
    using block: DocumentManager.EnumerateTextSegmentsBlock
  ) -> Bool {
    assertionFailure("Work is done by ApplyNode.")
    return false
  }

  final override func resolveTextLocation(
    with point: CGPoint, context: any LayoutContext, layoutOffset: Int,
    trace: inout Trace, affinity: inout SelectionAffinity
  ) -> Bool {
    assertionFailure("Work is done in ApplyNode.")
    return false
  }

  final override func rayshoot(
    from path: ArraySlice<RohanIndex>,
    affinity: SelectionAffinity,
    direction: TextSelectionNavigation.Direction,
    context: any LayoutContext, layoutOffset: Int
  ) -> RayshootResult? {
    assertionFailure("Work is done by ApplyNode.")
    return nil
  }

  // MARK: - ElementNode

  final func accept<R, C, V: NodeVisitor<R, C>, T: GenNode, S: Collection<T>>(
    _ visitor: V, _ context: C, withChildren children: S
  ) -> R {
    visitor.visit(argument: self, context, withChildren: children)
  }

  // MARK: - ArgumentNode

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
  let variableNodes: Array<VariableNode>

  init(_ variableNodes: Array<VariableNode>, _ argumentIndex: Int) {
    precondition(!variableNodes.isEmpty)

    self.variableNodes = variableNodes
    self.argumentIndex = argumentIndex
    super.init()

    variableNodes.forEach { $0.setArgumentNode(self) }
  }

  func getArgumentValue_readonly() -> ElementStore {
    variableNodes.first!.childrenReadonly()
  }

  // MARK: - Content

  var childCount: Int { variableNodes.first!.childCount }

  final func getChild(_ index: Int) -> Node {
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
    let categories: Array<ContainerCategory> =
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
      return candidate
    }
  }

  // MARK: - Children

  func insertChildren<S: Collection<Node>>(
    contentsOf nodes: S, at index: Int, inStorage: Bool
  ) {
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
    _ string: BigString, at location: TextLocationSlice
  ) throws -> EditResult<RhTextRange> {
    precondition(variableNodes.count >= 1)
    for variable in variableNodes.dropFirst() {
      _ = try TreeUtils.insertString(string, at: location, variable)
    }
    return try TreeUtils.insertString(string, at: location, variableNodes.first!)
  }

  /// Insert inline content at given location.
  /// - Returns: range of the inserted content.
  func insertInlineContent(
    _ nodes: Array<Node>, at location: TextLocationSlice
  ) throws -> EditResult<RhTextRange> {
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
    _ nodes: Array<Node>, at location: TextLocationSlice
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

}
