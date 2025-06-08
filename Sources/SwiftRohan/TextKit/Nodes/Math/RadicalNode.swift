// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

final class RadicalNode: MathNode {
  // MARK: - Node

  final override func deepCopy() -> Self { Self(deepCopyOf: self) }

  final override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(radical: self, context)
  }

  final override class var type: NodeType { .radical }

  // MARK: - Node(Layout)

  final override func contentDidChange(delta: Int, inStorage: Bool) {
    if inStorage { _isDirty = true }
    super.contentDidChange(delta: delta, inStorage: inStorage)
  }

  final override var isDirty: Bool { _isDirty }

  final override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    precondition(context is MathListLayoutContext)

    let context = context as! MathListLayoutContext

    if fromScratch {
      _performLayoutFramScratch(context)
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

  private enum CodingKeys: CodingKey { case radicand, index }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self._radicand = try container.decode(CrampedNode.self, forKey: .radicand)
    self._index = try container.decodeIfPresent(DegreeNode.self, forKey: .index)
    super.init()
    self._setUp()
  }

  final override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(_radicand, forKey: .radicand)
    try container.encodeIfPresent(_index, forKey: .index)
    try super.encode(to: encoder)
  }

  // MARK: - Node(Storage)

  private static let uniqueTag = "sqrt"

  final override class var storageTags: Array<String> { [uniqueTag] }

  final override class func load(from json: JSONValue) -> NodeLoaded<Node> {
    loadSelf(from: json).cast()
  }

  final override func store() -> JSONValue {
    let radicand = radicand.store()
    let index = _index?.store() ?? .null
    // keep the order: index, radicand
    let json = JSONValue.array([.string(Self.uniqueTag), index, radicand])
    return json
  }

  // MARK: - MathNode(Component)

  final override func enumerateComponents() -> Array<MathNode.Component> {
    if let index = _index {
      return [(.index, index), (.radicand, _radicand)]
    }
    else {
      return [(.radicand, _radicand)]
    }
  }

  final override func isComponentAllowed(_ index: MathIndex) -> Bool {
    [.index, .radicand].contains(index)
  }

  final override func addComponent(
    _ mathIndex: MathIndex, _ content: ElementStore, inStorage: Bool
  ) {
    precondition(mathIndex == .index)

    if inStorage { makeSnapshotOnce() }

    switch mathIndex {
    case .index:
      assert(_index == nil)
      _index = DegreeNode(content)
      _index!.setParent(self)

    default:
      assertionFailure("Unsupported index")
    }

    contentDidChange(delta: .zero, inStorage: inStorage)
  }

  final override func removeComponent(_ mathIndex: MathIndex, inStorage: Bool) {
    precondition(mathIndex == .index)

    if inStorage { makeSnapshotOnce() }

    switch mathIndex {
    case .index:
      assert(_index != nil)
      _index = nil

    default:
      assertionFailure("Unsupported index")
    }

    contentDidChange(delta: .zero, inStorage: inStorage)
  }

  // MARK: - MathNode(Layout)

  final override var layoutFragment: (any MathLayoutFragment)? { _nodeFragment }

  final override func getFragment(_ index: MathIndex) -> LayoutFragment? {
    switch index {
    case .radicand: return _nodeFragment?.radicand
    case .index: return _nodeFragment?.index
    default: return nil
    }
  }

  final override func initLayoutContext(
    for component: ContentNode, _ fragment: any LayoutFragment, parent: any LayoutContext
  ) -> any LayoutContext {
    defaultInitLayoutContext(for: component, fragment, parent: parent)
  }

  final override func getMathIndex(interactingAt point: CGPoint) -> MathIndex? {
    _nodeFragment?.getMathIndex(interactingAt: point)
  }

  final override func rayshoot(
    from point: CGPoint, _ component: MathIndex,
    in direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    _nodeFragment?.rayshoot(from: point, component, in: direction)
  }

  // MARK: - Storage

  final class func loadSelf(from json: JSONValue) -> NodeLoaded<RadicalNode> {
    guard case let .array(array) = json,
      array.count == 3,
      case let .string(tag) = array[0],
      tag == Self.uniqueTag
    else {
      return .failure(UnknownNode(json))
    }

    let index: DegreeNode?
    let corrupted: Bool

    switch NodeStoreUtils.loadOptComponent(array[1]) as LoadResult<DegreeNode?, Void> {
    case let .success(node):
      index = node
      corrupted = false
    case let .corrupted(node):
      index = node
      corrupted = true
    case .failure:
      return .failure(UnknownNode(json))
    }

    let radicand = ContentNode.loadSelfGeneric(from: array[2]) as NodeLoaded<CrampedNode>
    switch radicand {
    case let .success(radicand):
      let radical = RadicalNode(radicand, index: index)
      return corrupted ? .corrupted(radical) : .success(radical)
    case let .corrupted(radicand):
      let radical = RadicalNode(radicand, index: index)
      return .corrupted(radical)
    case .failure:
      return .failure(UnknownNode(json))
    }
  }

  // MARK: - RadicalNode

  private let _radicand: CrampedNode
  private var _index: DegreeNode?
  var radicand: ContentNode { _radicand }
  var index: ContentNode? { _index }

  private var _nodeFragment: MathRadicalLayoutFragment? = nil

  private var _isDirty: Bool = false
  private var _snapshot: MathComponentSet? = nil

  var command: String { Self.uniqueTag }

  init(_ radicand: CrampedNode, index: DegreeNode? = nil) {
    self._radicand = radicand
    self._index = index
    super.init()
    self._setUp()
  }

  init(_ radicand: ElementStore, index: ElementStore? = nil) {
    self._radicand = CrampedNode(radicand)
    self._index = index.map { DegreeNode($0) }
    super.init()
    self._setUp()
  }

  private func _setUp() {
    self._radicand.setParent(self)
    self._index?.setParent(self)
  }

  private init(deepCopyOf node: RadicalNode) {
    self._radicand = node._radicand.deepCopy()
    self._index = node._index?.deepCopy()
    super.init()
    self._setUp()
  }

  private func makeSnapshotOnce() {
    if _snapshot == nil {
      _snapshot = MathComponentSet()
      if let index = _index { _snapshot!.insert(index.id) }
    }
  }

  private func _performLayoutFramScratch(_ context: MathListLayoutContext) {
    func layoutComponent(_ component: ContentNode) -> MathListLayoutFragment {
      LayoutUtils.buildMathListLayoutFragment(component, parent: context)
    }

    let radicand: MathListLayoutFragment = layoutComponent(radicand)
    let index: MathListLayoutFragment? = _index.map { layoutComponent($0) }
    let radical = MathRadicalLayoutFragment(radicand, index)

    _nodeFragment = radical
    radical.fixLayout(context.mathContext)
    context.insertFragment(radical, self)
  }

  private func _performLayoutSimple(_ context: MathListLayoutContext) {
    guard let nodeFragment = _nodeFragment
    else {
      assertionFailure("radicalFragment not set")
      return
    }

    // save metrics before any layout changes
    let oldMetrics = nodeFragment.boxMetrics
    var needsFixLayout = false

    if radicand.isDirty {
      let oldMetrics = nodeFragment.radicand.boxMetrics
      LayoutUtils.reconcileMathListLayoutFragment(
        _radicand, nodeFragment.radicand, parent: context)
      if nodeFragment.radicand.isNearlyEqual(to: oldMetrics) == false {
        needsFixLayout = true
      }
    }
    if let index = _index, index.isDirty {
      guard let indexFrag = nodeFragment.index
      else {
        assertionFailure("index fragment not set")
        return
      }
      let oldMetrics = indexFrag.boxMetrics
      LayoutUtils.reconcileMathListLayoutFragment(index, indexFrag, parent: context)
      if indexFrag.isNearlyEqual(to: oldMetrics) == false {
        needsFixLayout = true
      }
    }

    if needsFixLayout {
      nodeFragment.fixLayout(context.mathContext)
      if nodeFragment.isNearlyEqual(to: oldMetrics) == false {
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

    guard let nodeFragment = _nodeFragment,
      let snapshot = _snapshot
    else {
      assertionFailure("radicalFragment or snapshot not set")
      return
    }

    if radicand.isDirty {
      LayoutUtils.reconcileMathListLayoutFragment(
        radicand, nodeFragment.radicand, parent: context)
    }

    if let index = _index {
      if !snapshot.contains(index.id) {
        nodeFragment.index =
          LayoutUtils.buildMathListLayoutFragment(index, parent: context)
      }
      else {
        assertionFailure("this should not happen")
      }
    }
    else {
      nodeFragment.index = nil
    }

    // fix layout
    let oldMetrics = nodeFragment.boxMetrics
    nodeFragment.fixLayout(context.mathContext)
    if nodeFragment.isNearlyEqual(to: oldMetrics) == false {
      context.invalidateBackwards(layoutLength())
    }
    else {
      context.skipBackwards(layoutLength())
    }
  }

}
