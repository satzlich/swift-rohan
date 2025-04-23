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

  override func contentDidChange(delta: Node.LengthSummary, inStorage: Bool) {
    if inStorage { _isDirty = true }
    super.contentDidChange(delta: delta, inStorage: inStorage)
  }

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

  private var _attachFragment: MathAttachLayoutFragment? = nil
  override var layoutFragment: (any MathLayoutFragment)? { _attachFragment }

  private var _snapshot: ComponentSet? = nil

  private func makeSnapshotOnce() {
    if _snapshot == nil {
      _snapshot = ComponentSet()
      if _lsub != nil { _snapshot!.insert(.lsub) }
      if _lsup != nil { _snapshot!.insert(.lsup) }
      if _sub != nil { _snapshot!.insert(.sub) }
      if _sup != nil { _snapshot!.insert(.sup) }
    }
  }

  override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    precondition(context is MathListLayoutContext)

    let context = context as! MathListLayoutContext

    if fromScratch {
      _performLayoutFromScratch(context)
    }
    else if _snapshot == nil {
      _performLayoutSimple(context)
    }
    else {
      _performLayoutFull(context)
    }

    // clear
    _isDirty = false
    _snapshot = nil
  }

  private func _performLayoutFromScratch(_ context: MathListLayoutContext) {
    func layoutComponent(
      _ component: ContentNode, _ fragment: inout MathListLayoutFragment?
    ) {
      let subContext =
        Self.createLayoutContextEcon(for: component, &fragment, parent: context)
      subContext.beginEditing()
      component.performLayout(subContext, fromScratch: true)
      subContext.endEditing()
    }

    var nucFrag: MathListLayoutFragment?
    var lsubFrag: MathListLayoutFragment?
    var lsupFrag: MathListLayoutFragment?
    var subFrag: MathListLayoutFragment?
    var supFrag: MathListLayoutFragment?

    layoutComponent(nucleus, &nucFrag)
    lsub.map { lsub in layoutComponent(lsub, &lsubFrag) }
    lsup.map { lsup in layoutComponent(lsup, &lsupFrag) }
    sub.map { sub in layoutComponent(sub, &subFrag) }
    sup.map { sup in layoutComponent(sup, &supFrag) }

    _attachFragment = MathAttachLayoutFragment(
      nuc: nucFrag!, lsub: lsubFrag, lsup: lsupFrag, sub: subFrag, sup: supFrag)
    _attachFragment!.fixLayout(context.mathContext)
    context.insertFragment(_attachFragment!, self)
  }

  private func _performLayoutSimple(_ context: MathListLayoutContext) {
    func layoutComponent(_ component: ContentNode, _ fragment: MathListLayoutFragment) {
      let subContext =
        Self.createLayoutContextEcon(for: component, fragment, parent: context)
      subContext.beginEditing()
      component.performLayout(subContext, fromScratch: false)
      subContext.endEditing()
    }

    var needsFixLayout = false

    // components

    if nucleus.isDirty {
      let bounds = _attachFragment!.nucleus.bounds
      layoutComponent(nucleus, _attachFragment!.nucleus)
      if _attachFragment!.nucleus.bounds.isNearlyEqual(to: bounds) == false {
        needsFixLayout = true
      }
    }
    if let lsub = lsub, lsub.isDirty {
      let bounds = _attachFragment!.lsub!.bounds
      layoutComponent(lsub, _attachFragment!.lsub!)
      if _attachFragment!.lsub!.bounds.isNearlyEqual(to: bounds) == false {
        needsFixLayout = true
      }
    }
    if let lsup = lsup, lsup.isDirty {
      let bounds = _attachFragment!.lsup!.bounds
      layoutComponent(lsup, _attachFragment!.lsup!)
      if _attachFragment!.lsup!.bounds.isNearlyEqual(to: bounds) == false {
        needsFixLayout = true
      }
    }
    if let sub = sub, sub.isDirty {
      let bounds = _attachFragment!.sub!.bounds
      layoutComponent(sub, _attachFragment!.sub!)
      if _attachFragment!.sub!.bounds.isNearlyEqual(to: bounds) == false {
        needsFixLayout = true
      }
    }
    if let sup = sup, sup.isDirty {
      let bounds = _attachFragment!.sup!.bounds
      layoutComponent(sup, _attachFragment!.sup!)
      if _attachFragment!.sup!.bounds.isNearlyEqual(to: bounds) == false {
        needsFixLayout = true
      }
    }

    // fix layout
    if needsFixLayout {
      let bounds = _attachFragment!.bounds
      _attachFragment!.fixLayout(context.mathContext)
      if _attachFragment!.bounds.isNearlyEqual(to: bounds) == false {
        context.invalidateBackwards(layoutLength())
      }
      else {
        context.skipBackwards(layoutLength())
      }
    }
    else {
      context.skipBackwards(layoutLength())
    }
  }

  private func _performLayoutFull(_ context: MathListLayoutContext) {
    precondition(_snapshot != nil)

    guard let snapshot = _snapshot
    else {
      assertionFailure("Invalid snapshot")
      return
    }

    func layoutComponentFS(
      _ component: ContentNode, _ fragment: inout MathListLayoutFragment?
    ) {
      let subContext =
        Self.createLayoutContextEcon(for: component, &fragment, parent: context)
      subContext.beginEditing()
      component.performLayout(subContext, fromScratch: true)
      subContext.endEditing()
    }
    func layoutComponent(_ component: ContentNode, _ fragment: MathListLayoutFragment) {
      let subContext =
        Self.createLayoutContextEcon(for: component, fragment, parent: context)
      subContext.beginEditing()
      component.performLayout(subContext, fromScratch: false)
      subContext.endEditing()
    }

    // components

    if nucleus.isDirty { layoutComponent(nucleus, _attachFragment!.nucleus) }

    // lsub
    if snapshot.contains(.lsub) {
      if let lsub = lsub {
        if lsub.isDirty { layoutComponent(lsub, _attachFragment!.lsub!) }
      }
      else {
        _attachFragment!.lsub = nil
      }
    }
    else {
      if let lsub = _lsub {
        var fragment: MathListLayoutFragment?
        layoutComponentFS(lsub, &fragment)
        _attachFragment!.lsub = fragment
      }
    }
    // lsup
    if snapshot.contains(.lsup) {
      if let lsup = _lsup {
        if lsup.isDirty { layoutComponent(lsup, _attachFragment!.lsup!) }
      }
      else {
        _attachFragment!.lsup = nil
      }
    }
    else {
      if let lsup = _lsup {
        var fragment: MathListLayoutFragment?
        layoutComponentFS(lsup, &fragment)
        _attachFragment!.lsup = fragment
      }
    }
    // sub
    if snapshot.contains(.sub) {
      if let sub = _sub {
        if sub.isDirty { layoutComponent(sub, _attachFragment!.sub!) }
      }
      else {
        _attachFragment!.sub = nil
      }
    }
    else {
      if let sub = _sub {
        var fragment: MathListLayoutFragment?
        layoutComponentFS(sub, &fragment)
        _attachFragment!.sub = fragment
      }
    }
    // sup
    if snapshot.contains(.sup) {
      if let sup = _sup {
        if sup.isDirty { layoutComponent(sup, _attachFragment!.sup!) }
      }
      else {
        _attachFragment!.sup = nil
      }
    }
    else {
      if let sup = _sup {
        var fragment: MathListLayoutFragment?
        layoutComponentFS(sup, &fragment)
        _attachFragment!.sup = fragment
      }
    }

    // fix layout
    let bounds = _attachFragment!.bounds
    _attachFragment!.fixLayout(context.mathContext)
    if _attachFragment!.bounds.isNearlyEqual(to: bounds) == false {
      context.invalidateBackwards(layoutLength())
    }
    else {
      context.skipBackwards(layoutLength())
    }
  }

  override func getFragment(_ index: MathIndex) -> MathListLayoutFragment? {
    switch index {
    case .lsub:
      return _attachFragment?.lsub
    case .lsup:
      return _attachFragment?.lsup
    case .nuc:
      return _attachFragment?.nucleus
    case .sub:
      return _attachFragment?.sub
    case .sup:
      return _attachFragment?.sup
    default:
      return nil
    }
  }

  override func getMathIndex(interactingAt point: CGPoint) -> MathIndex? {
    guard let fragment = _attachFragment else { return nil }

    let nucFrame = fragment.nucleus.glyphFrame
    if point.x < nucFrame.minX {
      if fragment.lsup?.glyphFrame.contains(point) == true {
        return .lsup
      }
      if fragment.lsub?.glyphFrame.contains(point) == true {
        return .lsub
      }
    }
    else if point.x <= nucFrame.maxX {
      return .nuc
    }
    else {
      if fragment.sup?.glyphFrame.contains(point) == true {
        return .sup
      }
      if fragment.sub?.glyphFrame.contains(point) == true {
        return .sub
      }
    }
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

  func addComponent(_ index: MathIndex, _ content: [Node], inStorage: Bool) {
    precondition([MathIndex.lsub, .lsup, .sub, .sup].contains(index))

    if inStorage { makeSnapshotOnce() }

    switch index {
    case .lsub:
      assert(_lsub == nil)
      _lsub = SubscriptNode(content)
      _lsub?.setParent(self)
    case .lsup:
      assert(_lsup == nil)
      _lsup = SuperscriptNode(content)
      _lsup?.setParent(self)
    case .sub:
      assert(_sub == nil)
      _sub = SubscriptNode(content)
      _sub?.setParent(self)
    case .sup:
      assert(_sup == nil)
      _sup = SuperscriptNode(content)
      _sup?.setParent(self)
    default:
      assertionFailure("Invalid index for AttachNode")
    }

    contentDidChange(delta: .zero, inStorage: inStorage)
  }

  func removeComponent(_ index: MathIndex, inStorage: Bool) {
    precondition([MathIndex.lsub, .lsup, .sub, .sup].contains(index))

    makeSnapshotOnce()

    switch index {
    case .lsub:
      assert(_lsub != nil)
      _lsub = nil
    case .lsup:
      assert(_lsup != nil)
      _lsup = nil
    case .sub:
      assert(_sub != nil)
      _sub = nil
    case .sup:
      assert(_sup != nil)
      _sup = nil
    default:
      assertionFailure("Invalid index for AttachNode")
    }

    contentDidChange(delta: .zero, inStorage: inStorage)
  }

  // MARK: - Clone and Visitor

  override func deepCopy() -> Node { AttachNode(deepCopyOf: self) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(attach: self, context)
  }

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

private struct ComponentSet: OptionSet {
  var rawValue: UInt8

  static let lsub = ComponentSet(rawValue: 1 << 0)
  static let lsup = ComponentSet(rawValue: 1 << 1)
  static let sub = ComponentSet(rawValue: 1 << 3)
  static let sup = ComponentSet(rawValue: 1 << 4)
}
