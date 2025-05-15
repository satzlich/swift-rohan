// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

final class AccentNode: MathNode {
  override class var type: NodeType { .accent }

  let accent: MathAccent

  init(_ accent: MathAccent, nucleus: CrampedNode) {
    self.accent = accent
    self._nucleus = nucleus
    super.init()
    self._setUp()
  }

  init(_ accent: MathAccent, nucleus: [Node]) {
    self.accent = accent
    self._nucleus = CrampedNode(nucleus)
    super.init()
    self._setUp()
  }

  init(deepCopyOf accentNode: AccentNode) {
    self.accent = accentNode.accent
    self._nucleus = accentNode._nucleus.deepCopy()
    super.init()
    self._setUp()
  }

  private final func _setUp() {
    _nucleus.setParent(self)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case accent, nuc }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    accent = try container.decode(MathAccent.self, forKey: .accent)
    _nucleus = try container.decode(CrampedNode.self, forKey: .nuc)
    super.init()
    self._setUp()
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(accent, forKey: .accent)
    try container.encode(_nucleus, forKey: .nuc)
    try super.encode(to: encoder)
  }

  // MARK: - Layout

  override var isDirty: Bool { _nucleus.isDirty }

  private var _accentFragment: MathAccentLayoutFragment? = nil
  override var layoutFragment: (any MathLayoutFragment)? { _accentFragment }

  override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    precondition(context is MathListLayoutContext)
    let context = context as! MathListLayoutContext

    if fromScratch {
      let nucFrag = LayoutUtils.createMathListLayoutFragmentEcon(nucleus, parent: context)
      let accentFragment = MathAccentLayoutFragment(accent, nucleus: nucFrag)
      _accentFragment = accentFragment
      accentFragment.fixLayout(context.mathContext)
      context.insertFragment(accentFragment, self)
    }
    else {
      guard let accentFragment = _accentFragment
      else {
        assertionFailure("Accent fragment is nil")
        return
      }

      var needsFixLayout = false

      if nucleus.isDirty {
        let nucMetrics = accentFragment.nucleus.boxMetrics

        LayoutUtils.reconcileMathListLayoutFragmentEcon(
          nucleus, accentFragment.nucleus, parent: context)
        if accentFragment.nucleus.isNearlyEqual(to: nucMetrics) == false {
          needsFixLayout = true
        }
      }

      if needsFixLayout {
        let metrics = accentFragment.boxMetrics
        accentFragment.fixLayout(context.mathContext)

        if accentFragment.isNearlyEqual(to: metrics) == false {
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
  }

  override func getFragment(_ index: MathIndex) -> LayoutFragment? {
    switch index {
    case .nuc:
      return _accentFragment?.nucleus
    default:
      return nil
    }
  }

  override func getMathIndex(interactingAt point: CGPoint) -> MathIndex? {
    _accentFragment?.getMathIndex(interactingAt: point)
  }

  override func rayshoot(
    from point: CGPoint, _ component: MathIndex,
    in direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    _accentFragment?.rayshoot(from: point, component, in: direction)
  }

  // MARK: - Component

  private let _nucleus: CrampedNode

  var nucleus: ContentNode { _nucleus }

  override func enumerateComponents() -> [MathNode.Component] {
    [(MathIndex.nuc, _nucleus)]
  }

  // MARK: - Clone and Visitor

  override func deepCopy() -> Self { Self(deepCopyOf: self) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(accent: self, context)
  }

  override class var storageTags: [String] {
    MathAccent.predefinedCases.map { $0.command }
  }

  override func store() -> JSONValue {
    let nucleus = nucleus.store()
    let json = JSONValue.array([.string(accent.command), nucleus])
    return json
  }

  class func loadSelf(from json: JSONValue) -> _LoadResult<AccentNode> {
    guard case let .array(array) = json,
      array.count == 2,
      case let .string(command) = array[0],
      let accent = MathAccent.lookup(command)
    else { return .failure(UnknownNode(json)) }

    let nucleus = CrampedNode.loadSelf(from: array[1]) as _LoadResult<CrampedNode>
    switch nucleus {
    case .success(let nucleus):
      return .success(AccentNode(accent, nucleus: nucleus))
    case .corrupted(let nucleus):
      return .corrupted(AccentNode(accent, nucleus: nucleus))
    case .failure:
      return .failure(UnknownNode(json))
    }
  }

  override class func load(from json: JSONValue) -> _LoadResult<Node> {
    loadSelf(from: json).cast()
  }
}
