// Copyright 2024-2025 Lie Yan
import AppKit

final class ArgumentNode: Node {
  override class var nodeType: NodeType { .argument }

  /** associated apply node */
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
    preconditionFailure("TODO")
  }

  override func encode(to encoder: any Encoder) throws {
    preconditionFailure("TODO")
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

  // MARK: - Location

  override func firstIndex() -> RohanIndex? {
    variableNodes[0].firstIndex()
  }

  override func lastIndex() -> RohanIndex? {
    variableNodes[0].lastIndex()
  }

  // MARK: - Layout

  override func enumerateTextSegments(
    _ path: ArraySlice<RohanIndex>, _ endPath: ArraySlice<RohanIndex>,
    _ context: any LayoutContext, layoutOffset: Int, originCorrection: CGPoint,
    type: DocumentManager.SegmentType, options: DocumentManager.SegmentOptions,
    using block: (RhTextRange?, CGRect, CGFloat) -> Bool
  ) -> Bool {
    assertionFailure(
      """
      \(#function) should not be called for \(Swift.type(of: self)). \
      The work is done by ApplyNode.
      """)
    return false
  }

  override func resolveTextLocation(
    interactingAt point: CGPoint, _ context: any LayoutContext, _ trace: inout [TraceElement]
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

  func insertChildren(contentsOf nodes: [Node], at index: Int) {
    precondition(variableNodes.count >= 1)
    // this works for count == 1 and count > 1
    for variable in variableNodes[1...] {
      variable.insertChildren(
        contentsOf: nodes.map { $0.deepCopy() }, at: index, inStorage: true)
    }
    variableNodes[0].insertChildren(contentsOf: nodes, at: index, inStorage: true)
  }

  /**
   Insert string at the location pointed to by path.

   - Returns: location correction if any
   */
  func insertString(_ string: String, at location: PartialLocation) throws -> [Int]? {
    precondition(variableNodes.count >= 1)
    // this works for count == 1 and count > 1
    for variable in variableNodes[1...] {
      _ = try NodeUtils.insertString(string, at: location, variable)
    }
    return try NodeUtils.insertString(string, at: location, variableNodes[0])
  }

  /**
   Insert a paragraph break at the given location.

   The insertion point is updated to the new location if successful.
   - Returns: true if successful, false otherwise.
   */
  func insertParagraphBreak(
    at location: PartialLocation,
    _ paragraphIndex: Int, _ insertionPoint: inout InsertionPoint
  ) -> Bool {
    precondition(variableNodes.count >= 1)
    // this works for count == 1 and count > 1
    for variable in variableNodes[1...] {
      let successful = NodeUtils.insertParagraphBreak(
        at: location, variable, paragraphIndex, &insertionPoint)
      if !successful { return false }
    }
    return NodeUtils.insertParagraphBreak(
      at: location, variableNodes[0], paragraphIndex, &insertionPoint)
  }

  /** Remove range from the argument node. */
  func removeSubrange(
    _ location: PartialLocation, _ endLocation: PartialLocation,
    _ insertionPoint: inout InsertionPoint
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
    preconditionFailure("\(#function) should not be called for \(type(of: self))")
  }

  override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
    visitor.visit(argument: self, context)
  }
}
