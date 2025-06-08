// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

final class AttachNode: MathNode {
  // MARK: - Node

  final override func deepCopy() -> Self { Self(deepCopyOf: self) }

  final override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(attach: self, context)
  }

  final override class var type: NodeType { .attach }

  final override func contentDidChange(delta: Int, inStorage: Bool) {
    if inStorage { _isDirty = true }
    super.contentDidChange(delta: delta, inStorage: inStorage)
  }

  // MARK: - Node(Layout)

  final override var isDirty: Bool { _isDirty }

  final override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
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

  // MARK: - Node(Codable)

  private enum CodingKeys: CodingKey { case lsub, lsup, sub, sup, nuc }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    nucleus = try container.decode(ContentNode.self, forKey: .nuc)
    _lsub = try container.decodeIfPresent(SubscriptNode.self, forKey: .lsub)
    _lsup = try container.decodeIfPresent(SuperscriptNode.self, forKey: .lsup)
    _sub = try container.decodeIfPresent(SubscriptNode.self, forKey: .sub)
    _sup = try container.decodeIfPresent(SuperscriptNode.self, forKey: .sup)
    super.init()
    self._setUp()
  }

  final override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(nucleus, forKey: .nuc)
    try container.encodeIfPresent(_lsub, forKey: .lsub)
    try container.encodeIfPresent(_lsup, forKey: .lsup)
    try container.encodeIfPresent(_sub, forKey: .sub)
    try container.encodeIfPresent(_sup, forKey: .sup)
    try super.encode(to: encoder)
  }

  // MARK: - Node(Storage)

  final override class var storageTags: Array<String> { [uniqueTag] }

  final override class func load(from json: JSONValue) -> _LoadResult<Node> {
    loadSelf(from: json).cast()
  }

  final override func store() -> JSONValue {
    var array: [JSONValue] = []
    array.append(.string(Self.uniqueTag))
    // keep the order: lsub, lsup, nuc, sub, sup
    array.append(_lsub?.store() ?? .null)
    array.append(_lsup?.store() ?? .null)
    array.append(nucleus.store())
    array.append(_sub?.store() ?? .null)
    array.append(_sup?.store() ?? .null)
    let json = JSONValue.array(array)
    return json
  }

  // MARK: - MathNode(Component)

  final override func enumerateComponents() -> Array<MathNode.Component> {
    var components: Array<MathNode.Component> = []

    _lsub.map { components.append((.lsub, $0)) }
    _lsup.map { components.append((.lsup, $0)) }
    components.append((.nuc, nucleus))
    _sub.map { components.append((.sub, $0)) }
    _sup.map { components.append((.sup, $0)) }

    return components
  }

  final override func isComponentAllowed(_ index: MathIndex) -> Bool {
    [MathIndex.lsub, .lsup, .nuc, .sub, .sup].contains(index)
  }

  final override func addComponent(_ index: MathIndex, _ content: [Node], inStorage: Bool)
  {
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

  final override func removeComponent(_ index: MathIndex, inStorage: Bool) {
    precondition([MathIndex.lsub, .lsup, .sub, .sup].contains(index))

    if inStorage { makeSnapshotOnce() }

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

  // MARK: - MathNode(Layout)

  final override var layoutFragment: (any MathLayoutFragment)? { _attachFragment }

  final override func initLayoutContext(
    for component: ContentNode, _ fragment: any LayoutFragment, parent: any LayoutContext
  ) -> any LayoutContext {
    defaultInitLayoutContext(for: component, fragment, parent: parent)
  }

  final override func getFragment(_ index: MathIndex) -> LayoutFragment? {
    guard let attachFragment = _attachFragment else { return nil }
    switch index {
    case .lsub: return attachFragment.lsub
    case .lsup: return attachFragment.lsup
    case .nuc: return attachFragment.nucleus
    case .sub: return attachFragment.sub
    case .sup: return attachFragment.sup
    default: return nil
    }
  }

  final override func getMathIndex(interactingAt point: CGPoint) -> MathIndex? {
    _attachFragment?.getMathIndex(interactingAt: point)
  }

  final override func rayshoot(
    from point: CGPoint, _ component: MathIndex,
    in direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    _attachFragment?.rayshoot(from: point, component, in: direction)
  }

  // MARK: - AttachNode

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

  private init(deepCopyOf scriptsNode: AttachNode) {
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

  private var _attachFragment: MathAttachLayoutFragment? = nil
  private var _isDirty: Bool = false

  private var _snapshot: MathComponentSet? = nil

  private func makeSnapshotOnce() {
    if _snapshot == nil {
      _snapshot = MathComponentSet()
      if let lsub = _lsub { _snapshot!.insert(lsub.id) }
      if let lsup = _lsup { _snapshot!.insert(lsup.id) }
      if let sub = _sub { _snapshot!.insert(sub.id) }
      if let sup = _sup { _snapshot!.insert(sup.id) }
    }
  }

  private func _performLayoutFromScratch(_ context: MathListLayoutContext) {
    func layoutComponent(_ component: ContentNode) -> MathListLayoutFragment {
      LayoutUtils.buildMathListLayoutFragment(component, parent: context)
    }

    let nucFrag = layoutComponent(nucleus)
    let lsubFrag = lsub.map { lsub in layoutComponent(lsub) }
    let lsupFrag = lsup.map { lsup in layoutComponent(lsup) }
    let subFrag = sub.map { sub in layoutComponent(sub) }
    let supFrag = sup.map { sup in layoutComponent(sup) }

    let attachFragment = MathAttachLayoutFragment(
      nuc: nucFrag, lsub: lsubFrag, lsup: lsupFrag, sub: subFrag, sup: supFrag)

    _attachFragment = attachFragment
    attachFragment.fixLayout(context.mathContext)
    context.insertFragment(attachFragment, self)
  }

  private func _performLayoutSimple(_ context: MathListLayoutContext) {

    guard let attachFragment = _attachFragment
    else {
      assertionFailure("Attach fragment is nil")
      return
    }

    // save old metrics before any layout changes
    let oldBoxMetrics = attachFragment.boxMetrics
    var needsFixLayout = false

    // components

    if nucleus.isDirty {
      let boxMetrics = attachFragment.nucleus.boxMetrics
      LayoutUtils.reconcileMathListLayoutFragment(
        nucleus, attachFragment.nucleus, parent: context)
      if attachFragment.nucleus.isNearlyEqual(to: boxMetrics) == false {
        needsFixLayout = true
      }
    }
    if let lsub = lsub, lsub.isDirty {
      let boxMetrics = attachFragment.lsub!.boxMetrics
      LayoutUtils.reconcileMathListLayoutFragment(
        lsub, attachFragment.lsub!, parent: context)
      if attachFragment.lsub!.isNearlyEqual(to: boxMetrics) == false {
        needsFixLayout = true
      }
    }
    if let lsup = lsup, lsup.isDirty {
      let boxMetrics = attachFragment.lsup!.boxMetrics
      LayoutUtils.reconcileMathListLayoutFragment(
        lsup, attachFragment.lsup!, parent: context)
      if attachFragment.lsup!.isNearlyEqual(to: boxMetrics) == false {
        needsFixLayout = true
      }
    }
    if let sub = sub, sub.isDirty {
      let boxMetrics = attachFragment.sub!.boxMetrics
      LayoutUtils.reconcileMathListLayoutFragment(
        sub, attachFragment.sub!, parent: context)
      if attachFragment.sub!.isNearlyEqual(to: boxMetrics) == false {
        needsFixLayout = true
      }
    }
    if let sup = sup, sup.isDirty {
      let boxMetrics = attachFragment.sup!.boxMetrics
      LayoutUtils.reconcileMathListLayoutFragment(
        sup, attachFragment.sup!, parent: context)
      if attachFragment.sup!.isNearlyEqual(to: boxMetrics) == false {
        needsFixLayout = true
      }
    }

    // fix layout
    if needsFixLayout {
      attachFragment.fixLayout(context.mathContext)
      if attachFragment.isNearlyEqual(to: oldBoxMetrics) == false {
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

    guard let attachFragment = _attachFragment,
      let snapshot = _snapshot
    else {
      assertionFailure("Invalid snapshot")
      return
    }

    // components

    if nucleus.isDirty {
      LayoutUtils.reconcileMathListLayoutFragment(
        nucleus, attachFragment.nucleus, parent: context)
    }

    // lsub
    if let lsub = lsub {
      if !snapshot.contains(lsub.id) {
        attachFragment.lsub = LayoutUtils.buildMathListLayoutFragment(
          lsub, parent: context)
      }
      else if lsub.isDirty {
        LayoutUtils.reconcileMathListLayoutFragment(
          lsub, attachFragment.lsub!, parent: context)
      }
    }
    else {
      attachFragment.lsub = nil
    }

    // lsup
    if let lsup = _lsup {
      if !snapshot.contains(lsup.id) {
        attachFragment.lsup =
          LayoutUtils.buildMathListLayoutFragment(lsup, parent: context)
      }
      else if lsup.isDirty {
        LayoutUtils.reconcileMathListLayoutFragment(
          lsup, attachFragment.lsup!, parent: context)
      }
    }
    else {
      attachFragment.lsup = nil
    }

    // sub
    if let sub = _sub {
      if !snapshot.contains(sub.id) {
        attachFragment.sub =
          LayoutUtils.buildMathListLayoutFragment(sub, parent: context)
      }
      else if sub.isDirty {
        LayoutUtils.reconcileMathListLayoutFragment(
          sub, attachFragment.sub!, parent: context)
      }
    }
    else {
      attachFragment.sub = nil
    }

    // sup
    if let sup = _sup {
      if !snapshot.contains(sup.id) {
        attachFragment.sup =
          LayoutUtils.buildMathListLayoutFragment(sup, parent: context)
      }
      else if sup.isDirty {
        LayoutUtils.reconcileMathListLayoutFragment(
          sup, attachFragment.sup!, parent: context)
      }
    }
    else {
      attachFragment.sup = nil
    }

    // fix layout
    let boxMetrics = attachFragment.boxMetrics
    attachFragment.fixLayout(context.mathContext)
    if attachFragment.isNearlyEqual(to: boxMetrics) == false {
      context.invalidateBackwards(layoutLength())
    }
    else {
      context.skipBackwards(layoutLength())
    }
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

  // MARK: - Clone and Visitor

  private static let uniqueTag = "attach"

  class func loadSelf(from json: JSONValue) -> _LoadResult<AttachNode> {
    guard case let .array(array) = json,
      array.count == 6,
      case let .string(tag) = array[0], tag == uniqueTag
    else { return .failure(UnknownNode(json)) }

    let lsub: SubscriptNode?
    let lsup: SuperscriptNode?
    let nucleus: ContentNode
    let sub: SubscriptNode?
    let sup: SuperscriptNode?
    var corrupted: Bool = false
    do {
      let result =
        NodeStoreUtils.loadOptComponent(array[1]) as LoadResult<SubscriptNode?, Void>
      switch result {
      case .success(let node):
        lsub = node
      case .corrupted(let node):
        lsub = node
        corrupted = true
      case .failure:
        return .failure(UnknownNode(json))
      }
    }
    do {
      let result =
        NodeStoreUtils.loadOptComponent(array[2]) as LoadResult<SuperscriptNode?, Void>
      switch result {
      case .success(let node):
        lsup = node
      case .corrupted(let node):
        lsup = node
        corrupted = true
      case .failure:
        return .failure(UnknownNode(json))
      }
    }
    do {
      let node = ContentNode.loadSelfGeneric(from: array[3]) as _LoadResult<ContentNode>
      switch node {
      case .success(let node):
        nucleus = node
      case .corrupted(let node):
        nucleus = node
        corrupted = true
      case .failure:
        return .failure(UnknownNode(json))
      }
    }
    do {
      let result =
        NodeStoreUtils.loadOptComponent(array[4]) as LoadResult<SubscriptNode?, Void>
      switch result {
      case .success(let node):
        sub = node
      case .corrupted(let node):
        sub = node
        corrupted = true
      case .failure:
        return .failure(UnknownNode(json))
      }
    }
    do {
      let result =
        NodeStoreUtils.loadOptComponent(array[5]) as LoadResult<SuperscriptNode?, Void>
      switch result {
      case .success(let node):
        sup = node
      case .corrupted(let node):
        sup = node
        corrupted = true
      case .failure:
        return .failure(UnknownNode(json))
      }
    }

    let result = AttachNode(nuc: nucleus, lsub: lsub, lsup: lsup, sub: sub, sup: sup)
    return corrupted ? .corrupted(result) : .success(result)
  }

}

