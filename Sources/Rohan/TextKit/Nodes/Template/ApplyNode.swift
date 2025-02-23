// Copyright 2025 Lie Yan

import Foundation

final class ApplyNode: Node {
  override class var nodeType: NodeType { .apply }

  let template: CompiledTemplate
  private let _arguments: [ArgumentNode]
  private let _content: ContentNode

  init?(_ template: CompiledTemplate, _ arguments: [[Node]]) {
    guard template.parameterCount == arguments.count,
      let (content, arguments) = NodeUtils.applyTemplate(template, arguments)
    else { return nil }

    self.template = template
    self._arguments = arguments
    self._content = content
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

  override func getRohanIndex(_ layoutOffset: Int) -> (RohanIndex, layoutOffset: Int)? {
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
        layoutOffset: layoutOffset, originCorrection: originCorrection, type: type,
        options: options, using: block)
      if !continueEnumeration { return false }
    }
    return true
  }

  override func getTextLocation(
    interactingAt point: CGPoint, _ context: any LayoutContext, _ trace: inout [TraceElement]
  ) -> Bool {
    preconditionFailure("TODO: implement")
  }

  // MARK: - Clone and Visitor

  override func deepCopy() -> ApplyNode {
    ApplyNode(deepCopyOf: self)
  }

  override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
    visitor.visit(apply: self, context)
  }
}

enum TemplateSample {
  static let newtonsLaw = {
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

  static let philipFox = {
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
}
