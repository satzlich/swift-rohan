// Copyright 2024-2025 Lie Yan

import AppKit

public final class EquationNode: MathNode {
  override class var nodeType: NodeType { .equation }

  public init(isBlock: Bool, _ nucleus: [Node] = []) {
    self._isBlock = isBlock
    self.nucleus = ContentNode(nucleus)
    super.init()
    self._setUp()
  }

  internal init(deepCopyOf equationNode: EquationNode) {
    self._isBlock = equationNode._isBlock
    self.nucleus = equationNode.nucleus.deepCopy()
    super.init()
    self._setUp()
  }

  private final func _setUp() {
    self.nucleus.setParent(self)
  }

  // MARK: - Codable

  enum CodingKeys: CodingKey {
    case isBlock
    case nucleus
  }

  public required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self._isBlock = try container.decode(Bool.self, forKey: .isBlock)
    self.nucleus = try container.decode(ContentNode.self, forKey: .nucleus)
    super.init()
    self._setUp()
  }

  public override func encode(to encoder: any Encoder) throws {
    try super.encode(to: encoder)
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(_isBlock, forKey: .isBlock)
    try container.encode(nucleus, forKey: .nucleus)
  }

  // MARK: - Layout

  private let _isBlock: Bool
  override public var isBlock: Bool { _isBlock }

  override var isDirty: Bool { nucleus.isDirty }

  private var _nucleusFragment: MathListLayoutFragment? = nil

  override final var layoutFragment: MathLayoutFragment? { _nucleusFragment }

  override func performLayout(_ context: LayoutContext, fromScratch: Bool) {
    if fromScratch {
      _nucleusFragment = nil
      let subContext = Self.createLayoutContext(for: nucleus, &_nucleusFragment, parent: context)
      // layout for nucleus
      subContext.beginEditing()
      nucleus.performLayout(subContext, fromScratch: true)
      subContext.endEditing()
      // insert fragment
      context.insertFragment(_nucleusFragment!, self)
    }
    else {
      assert(_nucleusFragment != nil)
      let subContext = Self.createLayoutContext(for: nucleus, &_nucleusFragment, parent: context)
      // layout for nucleus
      subContext.beginEditing()
      nucleus.performLayout(subContext, fromScratch: false)
      subContext.endEditing()
      // invalidate
      context.invalidateBackwards(layoutLength)
    }
  }

  final override func getFragment(_ index: MathIndex) -> MathListLayoutFragment? {
    guard index == .nucleus else { return nil }
    return _nucleusFragment
  }

  final override func getMathIndex(interactingAt point: CGPoint) -> MathIndex? {
    _nucleusFragment != nil ? .nucleus : nil
  }

  override func rayshoot(
    from point: CGPoint, _ direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    guard let fragment = _nucleusFragment else { return nil }
    switch direction {
    case .up:
      let y = -fragment.ascent
      return RayshootResult(CGPoint(x: point.x, y: y), false)

    case .down:
      let y = fragment.descent
      return RayshootResult(CGPoint(x: point.x, y: y), false)

    default:
      assertionFailure("Unsupported direction")
      return nil
    }
  }

  // MARK: - Styles

  override public func selector() -> TargetSelector {
    EquationNode.selector(isBlock: _isBlock)
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
    [(MathIndex.nucleus, nucleus)]
  }

  // MARK: - Clone and Visitor

  override public func deepCopy() -> Self { Self(deepCopyOf: self) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(equation: self, context)
  }
}
