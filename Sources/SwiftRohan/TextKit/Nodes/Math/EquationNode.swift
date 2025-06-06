// Copyright 2024-2025 Lie Yan

import AppKit
import _RopeModule

public final class EquationNode: MathNode {
  override class var type: NodeType { .equation }

  typealias Subtype = EquationExpr.Subtype

  init(_ subtype: Subtype, _ nucleus: [Node] = []) {
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

  internal init(deepCopyOf equationNode: EquationNode) {
    self.subtype = equationNode.subtype
    self.nucleus = equationNode.nucleus.deepCopy()
    super.init()
    self._setUp()
  }

  func with(nucleus: ContentNode) -> EquationNode {
    EquationNode(subtype, nucleus)
  }

  private final func _setUp() {
    self.nucleus.setParent(self)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case subtype, nuc }

  public required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.subtype = try container.decode(Subtype.self, forKey: .subtype)
    self.nucleus = try container.decode(ContentNode.self, forKey: .nuc)
    super.init()
    self._setUp()
  }

  public override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(subtype, forKey: .subtype)
    try container.encode(nucleus, forKey: .nuc)
    try super.encode(to: encoder)
  }

  // MARK: - Layout

  let subtype: Subtype

  override public var isBlock: Bool { subtype == .block }

  override var isDirty: Bool { nucleus.isDirty }

  private var _nucleusFragment: MathListLayoutFragment? = nil

  override final var layoutFragment: MathLayoutFragment? { _nucleusFragment }

  final override func getFragment(_ index: MathIndex) -> LayoutFragment? {
    guard index == .nuc else { return nil }
    return _nucleusFragment
  }

  final override func getMathIndex(interactingAt point: CGPoint) -> MathIndex? {
    _nucleusFragment != nil ? .nuc : nil
  }

  override func rayshoot(
    from point: CGPoint, _ component: MathIndex,
    in direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    guard let fragment = _nucleusFragment,
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

  // MARK: - Styles

  override public func selector() -> TargetSelector {
    EquationNode.selector(isBlock: isBlock)
  }

  public static func selector(isBlock: Bool? = nil) -> TargetSelector {
    return isBlock != nil
      ? TargetSelector(.equation, PropertyMatcher(.isBlock, .bool(isBlock!)))
      : TargetSelector(.equation)
  }

  override public func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      // inherit properties
      var properties = super.getProperties(styleSheet)
      // if there is no math style, compute and set
      let key = MathProperty.style
      if properties[key] == nil {
        properties[key] = .mathStyle(isBlock ? .display : .text)
      }
      // cache properties
      _cachedProperties = properties
    }
    return _cachedProperties!
  }

  // MARK: - Components

  public let nucleus: ContentNode

  override final func enumerateComponents() -> [MathNode.Component] {
    [(MathIndex.nuc, nucleus)]
  }

  // MARK: - Clone and Visitor

  override public func deepCopy() -> Self { Self(deepCopyOf: self) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(equation: self, context)
  }

  private enum Tag: String, Codable, CaseIterable {
    case blockmath, inlinemath
  }

  override class var storageTags: [String] {
    Tag.allCases.map { $0.rawValue }
  }

  override func store() -> JSONValue {
    let nucleus = nucleus.store()
    switch subtype {
    case .block:
      return JSONValue.array([.string(Tag.blockmath.rawValue), nucleus])
    case .inline:
      return JSONValue.array([.string(Tag.inlinemath.rawValue), nucleus])
    }
  }

  class func loadSelf(from json: JSONValue) -> _LoadResult<EquationNode> {
    guard case let .array(array) = json,
      array.count == 2,
      case let .string(tag) = array[0],
      let tag = Tag(rawValue: tag)
    else {
      return .failure(UnknownNode(json))
    }

    let subtype = (tag == .blockmath) ? Subtype.block : Subtype.inline
    let nucleus = ContentNode.loadSelfGeneric(from: array[1]) as _LoadResult<ContentNode>

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

  override class func load(from json: JSONValue) -> _LoadResult<Node> {
    loadSelf(from: json).cast()
  }

  // MARK: - Reflow-related

  override func performLayout(_ context: LayoutContext, fromScratch: Bool) {
    if fromScratch {
      let nucleusFragment =
        LayoutUtils.createMathListLayoutFragment(nucleus, parent: context)
      _nucleusFragment = nucleusFragment

      context.insertFragment(nucleusFragment, self)
    }
    else {
      guard let nucFragment = _nucleusFragment
      else {
        assertionFailure("Nucleus fragment should not be nil")
        return
      }

      LayoutUtils.reconcileMathListLayoutFragment(nucleus, nucFragment, parent: context)
      context.invalidateBackwards(layoutLength())
    }
  }
}
