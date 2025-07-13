// Copyright 2025 Lie Yan

import Foundation
import _RopeModule

final class ApplyNode: Node {
  // MARK: - Node

  final override func deepCopy() -> Self { Self(deepCopyOf: self) }

  final override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(apply: self, context)
  }

  final override class var type: NodeType { .apply }

  final override func resetCachedProperties() {
    super.resetCachedProperties()
    _content.resetCachedProperties()
  }

  // MARK: - Node(Positioning)

  final override func getChild(_ index: RohanIndex) -> ArgumentNode? {
    guard let index = index.argumentIndex(),
      index < _arguments.count
    else { return nil }
    return _arguments[index]
  }

  final override func firstIndex() -> RohanIndex? {
    guard !_arguments.isEmpty else { return nil }
    return .argumentIndex(0)
  }

  final override func lastIndex() -> RohanIndex? {
    guard _arguments.isEmpty == false else { return nil }
    return .argumentIndex(_arguments.count - 1)
  }

  final override func getLayoutOffset(_ index: RohanIndex) -> Int? {
    // layout offset is not well-defined for ApplyNode
    nil
  }

  final override func getPosition(_ layoutOffset: Int) -> PositionResult<RohanIndex> {
    // layout offset is not well-defined for ApplyNode
    .null
  }

  // MARK: - Node(Layout)

  final override func contentDidChange() { parent?.contentDidChange() }

  final override func layoutLength() -> Int { _content.layoutLength() }

  final override var isDirty: Bool { _content.isDirty }

  final override func performLayout(
    _ context: any LayoutContext, fromScratch: Bool, atBlockEdge: Bool
  ) -> Int {
    _content.performLayout(
      context, fromScratch: fromScratch, atBlockEdge: atBlockEdge)
  }

  // MARK: - Node(Codable)

  private enum CodingKeys: CodingKey { case template, arguments }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    let template = try container.decode(MathTemplate.self, forKey: .template)

    // decode arguments
    var argumentsContainer = try container.nestedUnkeyedContainer(forKey: .arguments)
    let argumentValues: Array<ElementStore> =
      try NodeSerdeUtils.decodeListOfListsOfNodes(from: &argumentsContainer)

    // almost same as init?()
    guard template.parameterCount == argumentValues.count,
      let (content, arguments) =
        NodeUtils.applyTemplate(template.template, argumentValues)
    else {
      throw DecodingError.dataCorruptedError(
        forKey: .arguments, in: container,
        debugDescription: "Failed to apply template with given arguments")
    }

    self.template = template
    self._arguments = arguments
    self._content = content

    try super.init(from: decoder)

    self._setUp()
  }

  final override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(template, forKey: .template)

    let listOfListsOfNodes = self._arguments.map { $0.getArgumentValue_readonly() }
    try container.encode(listOfListsOfNodes, forKey: .arguments)

    try super.encode(to: encoder)
  }

  // MARK: - Node(Storage)

  final override class var storageTags: Array<String> {
    MathTemplate.allCommands.map(\.command)
  }

  final override class func load(from json: JSONValue) -> NodeLoaded<Node> {
    guard case let .array(array) = json,
      array.isEmpty == false,
      case let .string(tag) = array[0],
      let template = MathTemplate.lookup(tag),
      template.parameterCount == array.count - 1
    else { return .failure(UnknownNode(json)) }

    var argumentValues: Array<ElementStore> = []
    argumentValues.reserveCapacity(template.parameterCount)
    var corrupted = false

    typealias _ArgumentResult = LoadResult<ElementStore, UnknownNode>
    for argument in array.dropFirst() {
      let argumentValue = NodeStoreUtils.loadNodes(argument) as _ArgumentResult
      switch argumentValue {
      case .success(let nodes):
        argumentValues.append(nodes)
      case .corrupted(let nodes):
        argumentValues.append(nodes)
        corrupted = true
      case .failure:
        return .failure(UnknownNode(json))
      }
    }

    guard let applyNode = ApplyNode(template, argumentValues) else {
      return .failure(UnknownNode(json))
    }
    return corrupted ? .corrupted(applyNode) : .success(applyNode)
  }

  final override func store() -> JSONValue {
    switch template.subtype {
    case .commandCall:
      let arguments: Array<JSONValue> = _arguments.map { $0.store() }
      let values = [JSONValue.string(template.command)] + arguments
      return JSONValue.array(values)

    case .environmentUse:
      preconditionFailure("TODO: export in environment-use notation")

    case .codeSnippet:
      preconditionFailure("TODO: export the content")
    }
  }

  // MARK: - Node(Tree API)

  final override func enumerateTextSegments(
    _ path: ArraySlice<RohanIndex>, _ endPath: ArraySlice<RohanIndex>,
    context: any LayoutContext, layoutOffset: Int, originCorrection: CGPoint,
    type: DocumentManager.SegmentType, options: DocumentManager.SegmentOptions,
    using block: DocumentManager.EnumerateTextSegmentsBlock
  ) -> Bool {
    guard let index = path.first?.argumentIndex(),
      let endIndex = endPath.first?.argumentIndex(),
      // must be in the same argument
      index == endIndex,
      index < _arguments.count
    else { return false }

    let argument = _arguments[index]

    for j in 0..<argument.variableNodes.count {
      let newPath = localPath(for: index, variableIndex: j, path.dropFirst())
      let newEndPath = localPath(for: index, variableIndex: j, endPath.dropFirst())
      let continueEnumeration = _content.enumerateTextSegments(
        ArraySlice(newPath), ArraySlice(newEndPath),
        context: context, layoutOffset: layoutOffset, originCorrection: originCorrection,
        type: type, options: options, using: block)
      if !continueEnumeration { return false }
    }
    return true
  }

  final override func resolveTextLocation(
    with point: CGPoint, context: any LayoutContext, layoutOffset: Int,
    trace: inout Trace, affinity: inout SelectionAffinity
  ) -> Bool {
    assertionFailure("Work is done in another function")
    return false
  }

  /// Resolve text location with given point and layout range.
  final func resolveTextLocation(
    with point: CGPoint, context: any LayoutContext, layoutOffset: Int,
    trace: inout Trace, affinity: inout SelectionAffinity,
    pickedRange: PickedRange
  ) -> Bool {
    var localTrace = Trace()
    let modified = _content.resolveTextLocation(
      with: point, context: context, layoutOffset: layoutOffset, trace: &localTrace,
      affinity: &affinity, pickedRange: pickedRange)
    guard modified else { return false }

    /// Returns true if the given node is a variable node associated to this
    /// apply node.
    func matchVariable(_ node: Node) -> Bool {
      if let variableNode = node as? VariableNode,
        variableNode.isAssociated(with: self)
      {
        return true
      }
      return false
    }

    // fix trace according to new trace
    guard let indexMatched = localTrace.firstIndex(where: { matchVariable($0.node) }),
      let argumentIndex = (localTrace[indexMatched].node as? VariableNode)?.argumentIndex
    else { return false }
    // append argument index
    trace.emplaceBack(self, .argumentIndex(argumentIndex))
    // copy part of local trace
    trace.append(contentsOf: localTrace[indexMatched...])
    return true
  }

  final override func rayshoot(
    from path: ArraySlice<RohanIndex>,
    affinity: SelectionAffinity,
    direction: TextSelectionNavigation.Direction,
    context: any LayoutContext, layoutOffset: Int
  ) -> RayshootResult? {
    guard let index = path.first?.argumentIndex(),
      index < _arguments.count
    else { return nil }

    // compose path for the 0-th variable of the argument
    let newPath = localPath(for: index, variableIndex: 0, path.dropFirst())
    return _content.rayshoot(
      from: ArraySlice(newPath), affinity: affinity, direction: direction,
      context: context, layoutOffset: layoutOffset)
  }

  // MARK: - Node(Counter)

  final override func contentDidChange(_ counterChange: CounterChange, _ child: Node) {
    parent?.contentDidChange(counterChange, self)
  }

  // MARK: - ApplyNode

  let template: MathTemplate
  private let _arguments: Array<ArgumentNode>
  private let _content: ContentNode

  internal init?(_ template: MathTemplate, _ argumentValues: Array<ElementStore>) {
    guard template.parameterCount == argumentValues.count,
      let (content, arguments) =
        NodeUtils.applyTemplate(template.template, argumentValues)
    else { return nil }

    self.template = template
    self._arguments = arguments
    self._content = content

    super.init()
    self._setUp()
  }

  private init(deepCopyOf applyNode: ApplyNode) {
    // deep copy of argument's value
    func deepCopy(from argument: ArgumentNode) -> ElementStore {
      let variableNode = argument.variableNodes.first!

      var copy: ElementStore = []
      copy.reserveCapacity(variableNode.childCount)
      for index in 0..<variableNode.childCount {
        let child = variableNode.getChild(index)
        // deep copy of each child
        copy.append(child.deepCopy())
      }
      return copy
    }

    self.template = applyNode.template
    let argumentCopies = applyNode._arguments.map({ deepCopy(from: $0) })
    let (content, arguments) = NodeUtils.applyTemplate(template.template, argumentCopies)!

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

  final var argumentCount: Int { _arguments.count }

  final func getArgument(_ index: Int) -> ArgumentNode {
    precondition(index < _arguments.count)
    return _arguments[index]
  }

  final func getContent() -> ContentNode { _content }

  private func localPath(
    for argumentIndex: Int, variableIndex: Int, _ path: ArraySlice<RohanIndex>
  ) -> Array<RohanIndex> {
    template.template.lookup[argumentIndex][variableIndex] + path
  }
}
