// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

final class ScriptsNode: MathNode {
  override class var type: NodeType { .scripts }

  public init(
    nucleus: ContentNode, leftSubScript: SubscriptNode? = nil,
    leftSuperScript: SuperscriptNode? = nil, subScript: SubscriptNode? = nil,
    superScript: SuperscriptNode? = nil
  ) {
    self.nucleus = nucleus
    self._leftSubScript = leftSubScript
    self._leftSuperScript = leftSuperScript
    self._subScript = subScript
    self._superScript = superScript
    super.init()
    self._setUp()
  }

  init(deepCopyOf scriptsNode: ScriptsNode) {
    self.nucleus = scriptsNode.nucleus.deepCopy()
    self._leftSubScript = scriptsNode._leftSubScript?.deepCopy()
    self._leftSuperScript = scriptsNode._leftSuperScript?.deepCopy()
    self._subScript = scriptsNode._subScript?.deepCopy()
    self._superScript = scriptsNode._superScript?.deepCopy()
    super.init()
    self._setUp()
  }

  private func _setUp() {
    nucleus.setParent(self)
    _leftSubScript?.setParent(self)
    _leftSuperScript?.setParent(self)
    _subScript?.setParent(self)
    _superScript?.setParent(self)
  }

  // MARK: - Codable

  /// should sync with ScriptsExpr
  private enum CodingKeys: CodingKey {
    case lsub, lsup, sub, sup, nuc
  }

  public required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    nucleus = try container.decode(ContentNode.self, forKey: .nuc)
    _leftSubScript = try container.decodeIfPresent(SubscriptNode.self, forKey: .lsub)
    _leftSuperScript = try container.decodeIfPresent(SuperscriptNode.self, forKey: .lsup)
    _subScript = try container.decodeIfPresent(SubscriptNode.self, forKey: .sub)
    _superScript = try container.decodeIfPresent(SuperscriptNode.self, forKey: .sup)
    super.init()
    self._setUp()
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(nucleus, forKey: .nuc)
    try container.encodeIfPresent(_leftSubScript, forKey: .lsub)
    try container.encodeIfPresent(_leftSuperScript, forKey: .lsup)
    try container.encodeIfPresent(_subScript, forKey: .sub)
    try container.encodeIfPresent(_superScript, forKey: .sup)
    try super.encode(to: encoder)
  }

  // MARK: - Content

  override func stringify() -> BigString {
    var string: BigString = ""
    _leftSubScript.map { string += $0.stringify() }
    _leftSuperScript.map { string += $0.stringify() }
    string += nucleus.stringify()
    _subScript.map { string += $0.stringify() }
    _superScript.map { string += $0.stringify() }
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

  private var _leftSubScript: SubscriptNode?
  private var _leftSuperScript: SuperscriptNode?
  private var _subScript: SubscriptNode?
  private var _superScript: SuperscriptNode?

  public var leftSubScript: ContentNode? { _leftSubScript }
  public var leftSuperScript: ContentNode? { _leftSuperScript }
  public var subScript: ContentNode? { _subScript }
  public var superScript: ContentNode? { _superScript }

  override func enumerateComponents() -> [MathNode.Component] {
    var components: [MathNode.Component] = []

    _leftSubScript.map { components.append((.leftSubScript, $0)) }
    _leftSuperScript.map { components.append((.leftSuperScript, $0)) }
    components.append((.nucleus, nucleus))
    _subScript.map { components.append((.subScript, $0)) }
    _superScript.map { components.append((.superScript, $0)) }

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
