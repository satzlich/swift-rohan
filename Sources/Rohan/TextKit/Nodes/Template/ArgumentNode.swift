// Copyright 2024-2025 Lie Yan
import AppKit

final class ArgumentNode: Node {
  override class var nodeType: NodeType { .argument }

  /** argument index. Added for debug purpose. */
  let index: Int
  /** variables */
  let variables: [VariableNode]

  init(_ variables: [VariableNode], _ index: Int) {
    precondition(!variables.isEmpty)

    self.variables = variables
    self.index = index
    super.init()

    for variable in variables {
      variable.setArgument(self)
    }
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
    Rohan.logger.error(
      "\(#function) should not be called for \(Swift.type(of: self))")
    return false
  }

  override func getTextLocation(
    interactingAt point: CGPoint, _ context: any LayoutContext, _ trace: inout [TraceElement]
  ) -> Bool {
    fatalError("TODO: implement")
  }

  // MARK: - Children

  func insertChildren(contentsOf nodes: [Node], at index: Int) {
    // this works for count == 1 and count > 1
    variables[1...].forEach {
      $0.insertChildren(contentsOf: nodes.map { $0.deepCopy() }, at: index)
    }
    variables[0].insertChildren(contentsOf: nodes, at: index)
  }

  // MARK: - Clone and Visitor

  override func deepCopy() -> Node {
    fatalError("\(#function) should not be called for \(type(of: self))")
  }

  override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
    visitor.visit(argument: self, context)
  }
}
