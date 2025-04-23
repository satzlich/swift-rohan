// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

final class AttachNode: MathNode {
  override class var type: NodeType { .attach }

  public init(
    nuc: ContentNode,
    lsub: SubscriptNode? = nil, lsup: SuperscriptNode? = nil,
    sub: SubscriptNode? = nil, sup: SuperscriptNode? = nil
  ) {
    self.nucleus = nuc
    self._lsub = lsub
    self._lsup = lsup
    self._sub = sub
    self._sup = sup
    super.init()
    self._setUp()
  }

  public init(
    nuc: [Node], lsub: [Node]? = nil, lsup: [Node]? = nil,
    sub: [Node]? = nil, sup: [Node]? = nil
  ) {
    self.nucleus = ContentNode(nuc)
    self._lsub = lsub.map { SubscriptNode($0) }
    self._lsup = lsup.map { SuperscriptNode($0) }
    self._sub = sub.map { SubscriptNode($0) }
    self._sup = sup.map { SuperscriptNode($0) }
    super.init()
    self._setUp()
  }

  init(deepCopyOf scriptsNode: AttachNode) {
    self.nucleus = scriptsNode.nucleus.deepCopy()
    self._lsub = scriptsNode._lsub?.deepCopy()
    self._lsup = scriptsNode._lsup?.deepCopy()
    self._sub = scriptsNode._sub?.deepCopy()
    self._sup = scriptsNode._sup?.deepCopy()
    super.init()
    self._setUp()
  }

  private func _setUp() {
    nucleus.setParent(self)
    _lsub?.setParent(self)
    _lsup?.setParent(self)
    _sub?.setParent(self)
    _sup?.setParent(self)
  }

  // MARK: - Codable

  /// should sync with AttachExpr
  private enum CodingKeys: CodingKey {
    case lsub, lsup, sub, sup, nuc
  }

  public required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    nucleus = try container.decode(ContentNode.self, forKey: .nuc)
    _lsub = try container.decodeIfPresent(SubscriptNode.self, forKey: .lsub)
    _lsup = try container.decodeIfPresent(SuperscriptNode.self, forKey: .lsup)
    _sub = try container.decodeIfPresent(SubscriptNode.self, forKey: .sub)
    _sup = try container.decodeIfPresent(SuperscriptNode.self, forKey: .sup)
    super.init()
    self._setUp()
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(nucleus, forKey: .nuc)
    try container.encodeIfPresent(_lsub, forKey: .lsub)
    try container.encodeIfPresent(_lsup, forKey: .lsup)
    try container.encodeIfPresent(_sub, forKey: .sub)
    try container.encodeIfPresent(_sup, forKey: .sup)
    try super.encode(to: encoder)
  }

  // MARK: - Content

  override func stringify() -> BigString {
    var string: BigString = ""
    _lsub.map { string += $0.stringify() }
    _lsup.map { string += $0.stringify() }
    string += nucleus.stringify()
    _sub.map { string += $0.stringify() }
    _sup.map { string += $0.stringify() }
    return string
  }

  // MARK: - Layout

  override var isBlock: Bool { false }
  private var _isDirty: Bool = false
  override var isDirty: Bool { _isDirty }

  override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    precondition(context is MathListLayoutContext)
    let context = context as! MathListLayoutContext

  }

  override func getFragment(_ index: MathIndex) -> MathListLayoutFragment? {
    return nil
  }

  override func getMathIndex(interactingAt point: CGPoint) -> MathIndex? {
    return nil
  }

  override func rayshoot(
    from point: CGPoint, _ direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    return nil
  }

  // MARK: - Components

  public let nucleus: ContentNode

  private var _lsub: SubscriptNode?
  private var _lsup: SuperscriptNode?
  private var _sub: SubscriptNode?
  private var _sup: SuperscriptNode?

  public var lsub: ContentNode? { _lsub }
  public var lsup: ContentNode? { _lsup }
  public var sub: ContentNode? { _sub }
  public var sup: ContentNode? { _sup }

  override func enumerateComponents() -> [MathNode.Component] {
    var components: [MathNode.Component] = []

    _lsub.map { components.append((.lsub, $0)) }
    _lsup.map { components.append((.lsup, $0)) }
    components.append((.nuc, nucleus))
    _sub.map { components.append((.sub, $0)) }
    _sup.map { components.append((.sup, $0)) }

    return components
  }

  // MARK: - Clone and Visitor

}

final class SubscriptNode: ContentNode {
  override func deepCopy() -> SubscriptNode { SubscriptNode(deepCopyOf: self) }
  override func cloneEmpty() -> Self { Self() }

  override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      var properties = super.getProperties(styleSheet)
      let key = MathProperty.style
      let value = resolveProperty(key, styleSheet).mathStyle()!
      // style, cramped
      properties[key] = .mathStyle(MathUtils.scriptStyle(for: value))
      properties[MathProperty.cramped] = .bool(true)
      _cachedProperties = properties
    }
    return _cachedProperties!
  }
}

final class SuperscriptNode: ContentNode {
  override func deepCopy() -> SuperscriptNode { SuperscriptNode(deepCopyOf: self) }
  override func cloneEmpty() -> Self { Self() }

  override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      var properties = super.getProperties(styleSheet)
      let key = MathProperty.style
      let value = resolveProperty(key, styleSheet).mathStyle()!
      // style
      properties[key] = .mathStyle(MathUtils.scriptStyle(for: value))
      _cachedProperties = properties
    }
    return _cachedProperties!
  }
}
