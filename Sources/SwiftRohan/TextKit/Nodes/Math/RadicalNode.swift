// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

final class RadicalNode: MathNode {
  override class var type: NodeType { .radical }

  private let _radicand: CrampedNode
  var radicand: ContentNode { _radicand }

  private var _index: DegreeNode?
  var index: ContentNode? { _index }

  init(_ radicand: CrampedNode, _ index: DegreeNode? = nil) {
    self._radicand = radicand
    self._index = index
    super.init()
    self._setUp()
  }

  init(_ radicand: [Node], _ index: [Node]? = nil) {
    self._radicand = CrampedNode(radicand)
    self._index = index.map { DegreeNode($0) }
    super.init()
    self._setUp()
  }

  private func _setUp() {
    self._radicand.setParent(self)
    self._index?.setParent(self)
  }

  init(deepCopyOf node: RadicalNode) {
    self._radicand = node._radicand.deepCopy()
    self._index = node._index?.deepCopy()
    super.init()
    self._setUp()
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case radicand, index }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self._radicand = try container.decode(CrampedNode.self, forKey: .radicand)
    self._index = try container.decodeIfPresent(DegreeNode.self, forKey: .index)
    super.init()
    self._setUp()
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(_radicand, forKey: .radicand)
    try container.encodeIfPresent(_index, forKey: .index)
    try super.encode(to: encoder)
  }

  // MARK: - Content

  override func contentDidChange(delta: Node.LengthSummary, inStorage: Bool) {
    if inStorage { _isDirty = true }
    super.contentDidChange(delta: delta, inStorage: inStorage)
  }

  // MARK: - Layout

  private var _isDirty: Bool = false
  override var isDirty: Bool { _isDirty }

  private var _radicalFragment: MathRadicalLayoutFragment? = nil
  override var layoutFragment: (any MathLayoutFragment)? { _radicalFragment }

  private var _snapshot: ComponentSet? = nil

  private func makeSnapshotOnce() {
    if _snapshot == nil {
      _snapshot = ComponentSet()
      if _index != nil { _snapshot!.insert(.index) }
    }
  }

  override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
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

  private func _performLayoutFramScratch(_ context: MathListLayoutContext) {
    func layoutComponent(_ component: ContentNode) -> MathListLayoutFragment {
      LayoutUtils.createMathListLayoutFragmentEcon(component, parent: context)
    }

    let radicand: MathListLayoutFragment = layoutComponent(radicand)
    let index: MathListLayoutFragment? = _index.map { layoutComponent($0) }
    let radical = MathRadicalLayoutFragment(radicand, index)

    _radicalFragment = radical
    radical.fixLayout(context.mathContext)
    context.insertFragment(radical, self)
  }

  private func _performLayoutSimple(_ context: MathListLayoutContext) {
    guard let radicalFragment = _radicalFragment
    else {
      assertionFailure("radicalFragment not set")
      return
    }

    var needsFixLayout = false

    if radicand.isDirty {
      let oldMetrics = radicalFragment.radicand.boxMetrics
      LayoutUtils.reconcileMathListLayoutFragmentEcon(
        _radicand, radicalFragment.radicand, parent: context)
      if radicalFragment.radicand.isNearlyEqual(to: oldMetrics) == false {
        needsFixLayout = true
      }
    }
    if let index = _index, index.isDirty {
      guard let indexFrag = radicalFragment.index
      else {
        assertionFailure("index fragment not set")
        return
      }
      let oldMetrics = indexFrag.boxMetrics
      LayoutUtils.reconcileMathListLayoutFragmentEcon(index, indexFrag, parent: context)
      if indexFrag.isNearlyEqual(to: oldMetrics) == false {
        needsFixLayout = true
      }
    }

    if needsFixLayout {
      let oldMetrics = radicalFragment.boxMetrics
      radicalFragment.fixLayout(context.mathContext)
      if radicalFragment.isNearlyEqual(to: oldMetrics) == false {
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

    guard let radicalFragment = _radicalFragment,
      let snapshot = _snapshot
    else {
      assertionFailure("radicalFragment or snapshot not set")
      return
    }

    if radicand.isDirty {
      LayoutUtils.reconcileMathListLayoutFragmentEcon(
        radicand, radicalFragment.radicand, parent: context)
    }

    if snapshot.contains(.index) {
      if let index = _index {
        if index.isDirty {
          LayoutUtils.reconcileMathListLayoutFragmentEcon(
            index, radicalFragment.index!, parent: context)
        }
      }
      else {
        radicalFragment.index = nil
      }
    }
    else {
      if let index = _index {
        radicalFragment.index = LayoutUtils.createMathListLayoutFragmentEcon(
          index, parent: context)
      }
    }

    // fix layout
    let oldMetrics = radicalFragment.boxMetrics
    radicalFragment.fixLayout(context.mathContext)
    if radicalFragment.isNearlyEqual(to: oldMetrics) == false {
      context.invalidateBackwards(layoutLength())
    }
    else {
      context.skipBackwards(layoutLength())
    }
  }

  override func getFragment(_ index: MathIndex) -> LayoutFragment? {
    switch index {
    case .radicand:
      return _radicalFragment?.radicand
    case .index:
      return _radicalFragment?.index
    default:
      return nil
    }
  }

  override func getMathIndex(interactingAt point: CGPoint) -> MathIndex? {
    _radicalFragment?.getMathIndex(interactingAt: point)
  }

  override func rayshoot(
    from point: CGPoint, _ component: MathIndex,
    in direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    _radicalFragment?.rayshoot(from: point, component, in: direction)
  }

  // MARK: - Component

  override func enumerateComponents() -> [MathNode.Component] {
    if let index = _index {
      return [(.index, index), (.radicand, _radicand)]
    }
    else {
      return [(.radicand, _radicand)]
    }
  }

  override func allowsComponent(_ index: MathIndex) -> Bool {
    [.index, .radicand].contains(index)
  }

  override func addComponent(_ mathIndex: MathIndex, _ content: [Node], inStorage: Bool) {
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

  override func removeComponent(_ mathIndex: MathIndex, inStorage: Bool) {
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

  // MARK: - Clone and Visitor

  override func deepCopy() -> Node { Self(deepCopyOf: self) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(radical: self, context)
  }

  private static let uniqueTag = "sqrt"

  override class var storageTags: [String] {
    [uniqueTag]
  }

  override func store() -> JSONValue {
    let radicand = radicand.store()
    let index = _index?.store() ?? .null
    // keep the order: index, radicand
    let json = JSONValue.array([.string(Self.uniqueTag), index, radicand])
    return json
  }

  override class func load(from json: JSONValue) -> Node._LoadResult {
    guard case let .array(array) = json,
      array.count == 3,
      case let .string(tag) = array[0],
      tag == Self.uniqueTag
    else {
      return .failure(UnknownNode(json))
    }

    let (index, c, f) =
      NodeStoreUtils.loadOptComponent(array[1]) as (DegreeNode?, Bool, Bool)
    if f { return .failure(UnknownNode(json)) }

    let radicand = ContentNode.load(from: array[2])
    switch radicand {
    case let .success(radicand):
      guard let radicand = radicand as? CrampedNode
      else { return .failure(UnknownNode(json)) }
      let radical = RadicalNode(radicand, index)
      return c ? .corrupted(radical) : .success(radical)
    case let .corrupted(radicand):
      guard let radicand = radicand as? CrampedNode
      else { return .failure(UnknownNode(json)) }
      let radical = RadicalNode(radicand, index)
      return .corrupted(radical)
    case .failure:
      return .failure(UnknownNode(json))
    }
  }
}
