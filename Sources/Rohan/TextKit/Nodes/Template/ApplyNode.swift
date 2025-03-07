// Copyright 2025 Lie Yan

import Foundation

public final class ApplyNode: Node {
  override class var nodeType: NodeType { .apply }

  let template: CompiledTemplate
  private let _arguments: [ArgumentNode]
  private let _content: ContentNode

  public init?(_ template: CompiledTemplate, _ arguments: [[Node]]) {
    guard template.parameterCount == arguments.count,
      let (content, arguments) = NodeUtils.applyTemplate(template, arguments)
    else { return nil }

    self.template = template
    self._arguments = arguments
    self._content = content

    super.init()
    self._setUp()
  }

  init(deepCopyOf applyNode: ApplyNode) {
    // deep copy of argument's value
    func deepCopy(from argument: ArgumentNode) -> [Node] {
      let variableNode = argument.variableNodes[0]
      return (0..<variableNode.childCount).map({ index in
        variableNode.getChild(index).deepCopy()
      })
    }

    self.template = applyNode.template
    let argumentCopies = applyNode._arguments.map({ deepCopy(from: $0) })
    let (content, arguments) = NodeUtils.applyTemplate(template, argumentCopies)!

    self._content = content
    self._arguments = arguments

    super.init()
    self._setUp()
  }

  private final func _setUp() {
    // set parent for content
    self._content.setParent(self)
    // set apply node for arguments
    // NOTE: parent should not be set for arguments
    self._arguments.forEach({ $0.setApplyNode(self) })
  }

  override func contentDidChange(delta: LengthSummary, inStorage: Bool) {
    // propagate to parent
    parent?.contentDidChange(delta: delta, inStorage: inStorage)
  }

  // MARK: - Content

  final var argumentCount: Int { _arguments.count }

  final func getArgument(_ index: Int) -> ArgumentNode {
    precondition(index < _arguments.count)
    return _arguments[index]
  }

  final func getContent() -> ContentNode { _content }

  override func getChild(_ index: RohanIndex) -> ArgumentNode? {
    guard let index = index.argumentIndex(),
      index < _arguments.count
    else { return nil }
    return _arguments[index]
  }

  // MARK: - Location

  override func firstIndex() -> RohanIndex? {
    guard !_arguments.isEmpty else { return nil }
    return .argumentIndex(0)
  }

  override func lastIndex() -> RohanIndex? {
    guard !_arguments.isEmpty else { return nil }
    return .argumentIndex(_arguments.count - 1)
  }

  // MARK: - Styles

  override func resetCachedProperties(recursive: Bool) {
    super.resetCachedProperties(recursive: recursive)
    if recursive { _content.resetCachedProperties(recursive: true) }
  }

  // MARK: - Layout

  override var layoutLength: Int { _content.layoutLength }

  override var isBlock: Bool { false }

  override var isDirty: Bool { _content.isDirty }

  override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    _content.performLayout(context, fromScratch: fromScratch)
  }

  override func getLayoutOffset(_ index: RohanIndex) -> Int? {
    // layout offset is not well-defined for ApplyNode
    nil
  }

  override func getRohanIndex(_ layoutOffset: Int) -> (RohanIndex, consumed: Int)? {
    // layout offset is not well-defined for ApplyNode
    nil
  }

  override func enumerateTextSegments(
    _ path: ArraySlice<RohanIndex>, _ endPath: ArraySlice<RohanIndex>,
    _ context: any LayoutContext, layoutOffset: Int, originCorrection: CGPoint,
    type: DocumentManager.SegmentType, options: DocumentManager.SegmentOptions,
    using block: (RhTextRange?, CGRect, CGFloat) -> Bool
  ) -> Bool {
    guard let index = path.first?.argumentIndex(),
      let endIndex = endPath.first?.argumentIndex(),
      // must be in the same argument
      index == endIndex,
      index < _arguments.count
    else { return false }

    let argument = _arguments[index]

    // compose path for the j-th variable of the argument
    func composePath(for j: Int, _ source: ArraySlice<RohanIndex>) -> [RohanIndex] {
      template.variableLocations[index][j] + source.dropFirst()
    }

    for j in 0..<argument.variableNodes.count {
      let newPath = composePath(for: j, path)
      let newEndPath = composePath(for: j, endPath)
      let continueEnumeration = _content.enumerateTextSegments(
        newPath[...], newEndPath[...], context,
        layoutOffset: layoutOffset, originCorrection: originCorrection,
        type: type, options: options, using: block)
      if !continueEnumeration { return false }
    }
    return true
  }

  override func resolveTextLocation(
    interactingAt point: CGPoint, _ context: any LayoutContext, _ trace: inout [TraceElement]
  ) -> Bool {
    assertionFailure("\(#function) should not be called for \(type(of: self))")
    return false
  }

  /** Resolve text location with given point, and (layoutRange, fraction) pair. */
  final func resolveTextLocation(
    interactingAt point: CGPoint, _ context: any LayoutContext, _ trace: inout [TraceElement],
    _ layoutRange: LayoutRange
  ) -> Bool {
    // resolve text location in content
    var newTrace = [TraceElement]()
    let modified = _content.resolveTextLocation(
      interactingAt: point, context, &newTrace, layoutRange)
    guard modified else { return false }

    // match the variable node associated to this apply node
    func match(_ node: Node) -> Bool {
      if let variableNode = node as? VariableNode,
        variableNode.isAssociated(with: self)
      {
        return true
      }
      return false
    }

    // fix trace according to new trace

    guard let matched = newTrace.firstIndex(where: { match($0.node) }),
      let index = (newTrace[matched].node as! VariableNode).getArgumentIndex()
    else { return false }
    // append argument
    trace.append(TraceElement(self, .argumentIndex(index)))
    // append new trace
    trace.append(contentsOf: newTrace[matched...])

    return true
  }

  override func rayshoot(
    from path: ArraySlice<RohanIndex>, _ direction: TextSelectionNavigation.Direction,
    _ context: any LayoutContext, layoutOffset: Int
  ) -> RayshootResult? {
    guard let index = path.first?.argumentIndex(),
      index < _arguments.count
    else { return nil }

    // compose path for the 0-th variable of the argument
    let newPath = template.variableLocations[index][0] + path.dropFirst()
    return _content.rayshoot(
      from: newPath[...], direction, context, layoutOffset: layoutOffset)
  }

  // MARK: - Clone and Visitor

  public override func deepCopy() -> ApplyNode {
    ApplyNode(deepCopyOf: self)
  }

  override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
    visitor.visit(apply: self, context)
  }
}
