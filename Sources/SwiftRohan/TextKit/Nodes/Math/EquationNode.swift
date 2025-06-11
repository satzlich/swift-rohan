// Copyright 2024-2025 Lie Yan

import AppKit
import _RopeModule

final class EquationNode: MathNode {
  // MARK: - Node

  final override func deepCopy() -> Self { Self(deepCopyOf: self) }

  final override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(equation: self, context)
  }

  final override class var type: NodeType { .equation }

  final override func selector() -> TargetSelector {
    EquationNode.selector(isBlock: isBlock)
  }

  final override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      var current = super.getProperties(styleSheet)

      // if there is no math style, compute and set
      let key = MathProperty.style
      if current[key] == nil {
        current[key] = .mathStyle(isBlock ? .display : .text)
      }

      _cachedProperties = current
    }
    return _cachedProperties!
  }

  // MARK: - Node(Layout)

  final override var isBlock: Bool { subtype == .block }
  final override var isDirty: Bool { nucleus.isDirty }

  final override func layoutLength() -> Int { _layoutLength }

  final override func performLayout(_ context: LayoutContext, fromScratch: Bool) -> Int {
    precondition(context is TextLayoutContext)
    let context = context as! TextLayoutContext

    if fromScratch {
      let nodeFragment = LayoutUtils.buildMathListLayoutFragment(nucleus, parent: context)
      _nodeFragment = nodeFragment

      if !isReflowActive {
        context.insertFragment(nodeFragment, self)
        _layoutLength = 1
      }
      else {
        _layoutLength = emitReflowSegments(nodeFragment)
      }
    }
    else {
      guard let nodeFragment = _nodeFragment else {
        assertionFailure("expected _nodeFragment to be non-nil")
        return _layoutLength
      }

      LayoutUtils.reconcileMathListLayoutFragment(nucleus, nodeFragment, parent: context)

      if !isReflowActive {
        context.invalidateBackwards(1)
        _layoutLength = 1
      }
      else {
        // delete segments emitted in previous layout, and emit new segments
        context.deleteBackwards(_layoutLength)
        _layoutLength = emitReflowSegments(nodeFragment)
      }
    }

    return _layoutLength

    /// Returns the number of segments emitted.
    func emitReflowSegments(_ nodeFragment: MathListLayoutFragment) -> Int {
      precondition(self.isReflowActive)
      nodeFragment.performReflow()
      for fragment in nodeFragment.reflowSegments.reversed() {
        context.insertFragment(fragment, self)
      }
      return nodeFragment.reflowSegments.count
    }
  }

  // MARK: - Node(Codable)

  private enum CodingKeys: CodingKey { case subtype, nuc }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.subtype = try container.decode(Subtype.self, forKey: .subtype)
    self.nucleus = try container.decode(ContentNode.self, forKey: .nuc)
    super.init()
    self._setUp()
  }

  final override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(subtype, forKey: .subtype)
    try container.encode(nucleus, forKey: .nuc)
    try super.encode(to: encoder)
  }

  // MARK: - Node(Storage)

  private enum Tag: String, Codable, CaseIterable { case blockmath, inlinemath }

  final override class var storageTags: Array<String> { Tag.allCases.map(\.rawValue) }

  final override class func load(from json: JSONValue) -> NodeLoaded<Node> {
    loadSelf(from: json).cast()
  }

  final override func store() -> JSONValue {
    let nucleus = nucleus.store()
    switch subtype {
    case .block:
      return JSONValue.array([.string(Tag.blockmath.rawValue), nucleus])
    case .inline:
      return JSONValue.array([.string(Tag.inlinemath.rawValue), nucleus])
    }
  }

  // MARK: - MathNode(Component)

  final override func enumerateComponents() -> [MathNode.Component] {
    [(MathIndex.nuc, nucleus)]
  }

  // MARK: - MathNode(Layout)

  final override var layoutFragment: MathLayoutFragment? { _nodeFragment }

  final override func getFragment(_ index: MathIndex) -> LayoutFragment? {
    guard index == .nuc else { return nil }
    return _nodeFragment
  }

  final override func initLayoutContext(
    for component: ContentNode, _ fragment: any LayoutFragment,
    parent context: any LayoutContext
  ) -> any LayoutContext {
    // TODO: handle reflowed segments
    precondition(context is TextLayoutContext)
    precondition(fragment is MathListLayoutFragment)
    let context = context as! TextLayoutContext
    let fragment = fragment as! MathListLayoutFragment
    return
      LayoutUtils.initMathListLayoutContext(for: component, fragment, parent: context)
  }

  final override func getMathIndex(interactingAt point: CGPoint) -> MathIndex? {
    _nodeFragment != nil ? .nuc : nil
  }

  final override func rayshoot(
    from point: CGPoint, _ component: MathIndex,
    in direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    guard let fragment = _nodeFragment,
      component == .nuc
    else { return nil }

    switch direction {
    case .up:
      return RayshootResult(point.with(y: -fragment.ascent), false)
    case .down:
      return RayshootResult(point.with(y: fragment.descent), false)
    default:
      assertionFailure("Unsupported direction")
      return nil
    }
  }

  // MARK: - Storage

  final class func loadSelf(from json: JSONValue) -> NodeLoaded<EquationNode> {
    guard case let .array(array) = json,
      array.count == 2,
      case let .string(tag) = array[0],
      let tag = Tag(rawValue: tag)
    else {
      return .failure(UnknownNode(json))
    }

    let subtype = (tag == .blockmath) ? Subtype.block : Subtype.inline
    let nucleus = ContentNode.loadSelfGeneric(from: array[1]) as NodeLoaded<ContentNode>

    switch nucleus {
    case let .success(nucleus):
      let equation = EquationNode(subtype, nucleus)
      return .success(equation)
    case let .corrupted(nucleus):
      let equation = EquationNode(subtype, nucleus)
      return .corrupted(equation)
    case .failure:
      return .failure(UnknownNode(json))
    }
  }

  // MARK: - EquationNode

  internal typealias Subtype = EquationExpr.Subtype

  internal let subtype: Subtype
  internal let nucleus: ContentNode

  private var _layoutLength: Int = 1
  private var _nodeFragment: MathListLayoutFragment? = nil

  /// True if the layout of the equation should be reflowed.
  final var isReflowActive: Bool { NodePolicy.isReflowEnabled && subtype == .inline }

  init(_ subtype: Subtype, _ nucleus: ElementStore = []) {
    self.subtype = subtype
    self.nucleus = ContentNode(nucleus)
    super.init()
    self._setUp()
  }

  private init(_ subtype: Subtype, _ nucleus: ContentNode) {
    self.subtype = subtype
    self.nucleus = nucleus
    super.init()
    self._setUp()
  }

  private init(deepCopyOf equationNode: EquationNode) {
    self.subtype = equationNode.subtype
    self.nucleus = equationNode.nucleus.deepCopy()
    super.init()
    self._setUp()
  }

  final func with(nucleus: ContentNode) -> EquationNode {
    EquationNode(subtype, nucleus)
  }

  private final func _setUp() {
    self.nucleus.setParent(self)
  }

  internal static func selector(isBlock: Bool? = nil) -> TargetSelector {
    return isBlock != nil
      ? TargetSelector(.equation, PropertyMatcher(.isBlock, .bool(isBlock!)))
      : TargetSelector(.equation)
  }

}
