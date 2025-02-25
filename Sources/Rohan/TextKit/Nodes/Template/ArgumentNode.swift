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

  /** argument index */
  let index: Int
  let variables: [VariableNode]

  init(_ variables: [VariableNode], _ index: Int) {
    precondition(!variables.isEmpty)

    self.variables = variables
    self.index = index
    super.init()

    variables.forEach { $0.setArgumentNode(self) }
  }

  // MARK: - Content

  override func getChild(_ index: RohanIndex) -> Node? {
    variables[0].getChild(index)
  }

  // MARK: - Layout

  override func enumerateTextSegments(
    _ context: any LayoutContext,
    _ path: ArraySlice<RohanIndex>, _ endPath: ArraySlice<RohanIndex>,
    layoutOffset: Int, originCorrection: CGPoint,
    type: DocumentManager.SegmentType, options: DocumentManager.SegmentOptions,
    using block: (RhTextRange?, CGRect, CGFloat) -> Bool
  ) -> Bool {
    Rohan.logger.error("\(#function) should not be called for \(Swift.type(of: self))")
    return false
  }

  override func resolveTextLocation(
    interactingAt point: CGPoint, _ context: any LayoutContext, _ trace: inout [TraceElement]
  ) -> Bool {
    Rohan.logger.error("\(#function) should not be called for \(type(of: self))")
    return false
  }

  // MARK: - Children

  func insertChildren(contentsOf nodes: [Node], at index: Int) {
    precondition(variables.count >= 1)
    // this works for count == 1 and count > 1
    variables[1...].forEach {
      $0.insertChildren(contentsOf: nodes.map { $0.deepCopy() }, at: index)
    }
    variables[0].insertChildren(contentsOf: nodes, at: index)
  }

  /**
   Insert string at the location pointed to by path.

   - Returns: location correction if any
   */
  func insertString(_ string: String, at location: PartialLocation) throws -> [Int]? {
    precondition(variables.count >= 1)
    // this works for count == 1 and count > 1
    for variable in variables[1...] {
      _ = try NodeUtils.insertString(string, at: location, variable)
    }
    return try NodeUtils.insertString(string, at: location, variables[0])
  }

  /** Remove range from the argument node. */
  func removeSubrange(
    _ location: PartialLocation, _ endLocation: PartialLocation,
    _ insertionPoint: inout InsertionPoint
  ) throws {
    precondition(variables.count >= 1)
    // this works for count == 1 and count > 1
    for variable in variables[1...] {
      var insertionPointCopy = insertionPoint
      _ = try NodeUtils.removeTextSubrange(
        location, endLocation, variable, nil, &insertionPointCopy)
    }
    _ = try NodeUtils.removeTextSubrange(
      location, endLocation, variables[0], nil, &insertionPoint)
  }

  // MARK: - Clone and Visitor

  override func deepCopy() -> Node {
    preconditionFailure("\(#function) should not be called for \(type(of: self))")
  }

  override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
    visitor.visit(argument: self, context)
  }
}
