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
      let variable = argument.variables[0]
      return (0..<variable.childCount).map({ index in
        variable.getChild(index).deepCopy()
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
    // set parent
    self._content.parent = self
    // set apply node; parent should be nil for argument node
    self._arguments.forEach({ $0.setApplyNode(self) })
  }

  override func contentDidChange(delta: LengthSummary, inContentStorage: Bool) {
    // propagate to parent
    parent?.contentDidChange(delta: delta, inContentStorage: inContentStorage)
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
    _ context: any LayoutContext,
    _ path: ArraySlice<RohanIndex>, _ endPath: ArraySlice<RohanIndex>,
    layoutOffset: Int, originCorrection: CGPoint,
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

    for j in 0..<argument.variables.count {
      let newPath = composePath(for: j, path)
      let newEndPath = composePath(for: j, endPath)
      let continueEnumeration = _content.enumerateTextSegments(
        context, newPath[...], newEndPath[...],
        layoutOffset: layoutOffset, originCorrection: originCorrection,
        type: type, options: options, using: block)
      if !continueEnumeration { return false }
    }
    return true
  }

  override func resolveTextLocation(
    interactingAt point: CGPoint, _ context: any LayoutContext, _ trace: inout [TraceElement]
  ) -> Bool {
    Rohan.logger.error("\(#function) should not be called for \(type(of: self))")
    return false
  }

  /** Resolve text location with given point, and (layoutRange, fraction) pair. */
  final func resolveTextLocation(
    interactingAt point: CGPoint, _ context: any LayoutContext, _ trace: inout [TraceElement],
    _ layoutSegment: LayoutSegment
  ) -> Bool {
    // resolve text location in content
    var newTrace = [TraceElement]()
    let modified = _content.resolveTextLocation(
      interactingAt: point, context, &newTrace, layoutSegment)
    guard modified else { return false }

    // match the variable node associated to this apply node via its argument node
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

  // MARK: - Clone and Visitor

  public override func deepCopy() -> ApplyNode {
    ApplyNode(deepCopyOf: self)
  }

  override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
    visitor.visit(apply: self, context)
  }
}

public enum TemplateSample {
  public static let newtonsLaw = {
    let content = Content {
      "a="
      Fraction(
        numerator: { "F" },
        denominator: { "m" })
    }
    let template = CompiledTemplate(
      name: TemplateName("newton"), parameterCount: 0, body: content,
      variableLocations: [:])

    return template
  }()

  public static let philipFox = {
    let content = Content {
      NamelessVariable(0)
      " is a good "
      Emphasis {
        NamelessVariable(1)
      }
      ", is "
      NamelessVariable(0)
      "?"
    }

    let argument0: Nano.VariableLocations = [
      [.index(0)],
      [.index(4)],
    ]
    let argument1: Nano.VariableLocations = [
      [.index(2), .index(0)]
    ]

    let variableLocations: Nano.VariableLocationsDict = [
      0: argument0,
      1: argument1,
    ]

    let template = CompiledTemplate(
      name: TemplateName("philipFox"), parameterCount: 2, body: content,
      variableLocations: variableLocations)

    return template
  }()

  public static let doubleText = {
    let content = Content {
      "{"
      NamelessVariable(0)
      " and "
      Emphasis {
        NamelessVariable(0)
      }
      "}"
    }
    let argument0: Nano.VariableLocations = [
      [.index(1)],
      [.index(3), .index(0)],
    ]
    let variableLocations: Nano.VariableLocationsDict = [
      0: argument0
    ]

    let template = CompiledTemplate(
      name: TemplateName("doubleText"), parameterCount: 1, body: content,
      variableLocations: variableLocations)

    return template
  }()

  public static let complexFraction = {
    let content = Content {
      Fraction(
        numerator: {
          Fraction(
            numerator: {
              NamelessVariable(1)
              "+1"
            },
            denominator: {
              NamelessVariable(0)
              "+1"
            })
        },
        denominator: {
          NamelessVariable(0)
          "+"
          NamelessVariable(1)
          "+1"
        })
    }
    let argument0: Nano.VariableLocations = [
      [.index(0), .mathIndex(.numerator), .index(0), .mathIndex(.denominator), .index(0)],
      [.index(0), .mathIndex(.denominator), .index(0)],
    ]
    let argument1: Nano.VariableLocations = [
      [.index(0), .mathIndex(.numerator), .index(0), .mathIndex(.numerator), .index(0)],
      [.index(0), .mathIndex(.denominator), .index(2)],
    ]
    let variableLocations: Nano.VariableLocationsDict = [
      0: argument0,
      1: argument1,
    ]

    let template = CompiledTemplate(
      name: TemplateName("complexFraction"), parameterCount: 2, body: content,
      variableLocations: variableLocations)
    return template
  }()

  public static let bifun = {
    let content = Content {
      "f("
      NamelessVariable(0)
      ","
      NamelessVariable(0)
      ")"
    }
    let argument0: Nano.VariableLocations = [[.index(1)], [.index(3)]]
    let variableLocations: Nano.VariableLocationsDict = [0: argument0]

    let template = CompiledTemplate(
      name: TemplateName("bifun"), parameterCount: 1, body: content,
      variableLocations: variableLocations)
    return template
  }()
}
