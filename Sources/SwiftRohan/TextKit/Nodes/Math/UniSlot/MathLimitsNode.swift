// Copyright 2024-2025 Lie Yan

import Foundation
import UnicodeMathClass

final class MathLimitsNode: MathNode {
  override class var type: NodeType { .mathLimits }

  let mathLimits: MathLimits
  private let _nucleus: ContentNode
  var nucleus: ContentNode { _nucleus }

  init(_ mathLimits: MathLimits, _ nucleus: [Node]) {
    self.mathLimits = mathLimits
    self._nucleus = ContentNode(nucleus)
    super.init()
    self._setUp()
  }

  init(_ mathLimits: MathLimits, _ nucleus: ContentNode) {
    self.mathLimits = mathLimits
    self._nucleus = nucleus
    super.init()
    self._setUp()
  }

  init(deepCopyOf node: MathLimitsNode) {
    self.mathLimits = node.mathLimits
    self._nucleus = node._nucleus.deepCopy()
    super.init()
    self._setUp()
  }

  private func _setUp() {
    self._nucleus.setParent(self)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case mathLimits, nuc }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.mathLimits = try container.decode(MathLimits.self, forKey: .mathLimits)
    self._nucleus = try container.decode(ContentNode.self, forKey: .nuc)
    super.init()
    self._setUp()
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(mathLimits, forKey: .mathLimits)
    try container.encode(_nucleus, forKey: .nuc)
    try super.encode(to: encoder)
  }

  // MARK: - Layout

  override var isDirty: Bool { _nucleus.isDirty }

  private typealias _MathLimitsLayoutFragment =
    MathAttributesLayoutFragment<MathListLayoutFragment>
  private var _limitsFragment: _MathLimitsLayoutFragment?
  override var layoutFragment: (any MathLayoutFragment)? { _limitsFragment }

  override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    precondition(context is MathListLayoutContext)
    let context = context as! MathListLayoutContext

    if fromScratch {
      let nucleus: MathListLayoutFragment =
        LayoutUtils.createMathListLayoutFragmentEcon(_nucleus, parent: context)

      let classFragment = MathAttributesLayoutFragment(nucleus, limits: mathLimits.limits)
      _limitsFragment = classFragment

      classFragment.fixLayout(context.mathContext)
      context.insertFragment(classFragment, self)
    }
    else {
      guard let classFragment = _limitsFragment
      else {
        assertionFailure("classFragment should not be nil")
        return
      }

      // save metrics before any layout changes
      let oldMetrics = classFragment.boxMetrics
      var needsFixLayout = false

      if _nucleus.isDirty {
        let oldMetrics = classFragment.nucleus.boxMetrics
        LayoutUtils.reconcileMathListLayoutFragmentEcon(
          _nucleus, classFragment.nucleus, parent: context)
        if classFragment.nucleus.isNearlyEqual(to: oldMetrics) == false {
          needsFixLayout = true
        }
      }

      if needsFixLayout {
        classFragment.fixLayout(context.mathContext)
        if classFragment.isNearlyEqual(to: oldMetrics) == false {
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

  override func getFragment(_ index: MathIndex) -> (any LayoutFragment)? {
    switch index {
    case .nuc: return _limitsFragment?.nucleus
    default: return nil
    }
  }

  override func getMathIndex(interactingAt point: CGPoint) -> MathIndex? {
    guard _limitsFragment != nil else { return nil }
    return .nuc
  }

  override func rayshoot(
    from point: CGPoint, _ component: MathIndex,
    in direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    guard let fragment = _limitsFragment,
      component == .nuc
    else { return nil }

    switch direction {
    case .up: return RayshootResult(point.with(y: fragment.minY), false)
    case .down: return RayshootResult(point.with(y: fragment.maxY), false)
    default:
      assertionFailure("Invalid direction")
      return nil
    }
  }

  override func enumerateComponents() -> [MathNode.Component] {
    [(MathIndex.nuc, _nucleus)]
  }

  // MARK: - Clone and Visitor

  override func deepCopy() -> Self { Self(deepCopyOf: self) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(mathLimits: self, context)
  }

  override class var storageTags: [String] {
    MathLimits.allCommands.map { $0.command }
  }

  override func store() -> JSONValue {
    let nucleus = _nucleus.store()
    let json = JSONValue.array([.string(mathLimits.command), nucleus])
    return json
  }

  class func loadSelf(from json: JSONValue) -> _LoadResult<MathLimitsNode> {
    guard case let .array(array) = json,
      array.count == 2,
      case let .string(tag) = array[0],
      let limits = MathLimits.lookup(tag)
    else { return .failure(UnknownNode(json)) }

    let nucleus = ContentNode.loadSelfGeneric(from: array[1]) as _LoadResult<ContentNode>
    switch nucleus {
    case let .success(nucleus):
      let node = MathLimitsNode(limits, nucleus)
      return .success(node)
    case let .corrupted(nucleus):
      let node = MathLimitsNode(limits, nucleus)
      return .corrupted(node)
    case .failure:
      return .failure(UnknownNode(json))
    }
  }

  override class func load(from json: JSONValue) -> Node._LoadResult<Node> {
    loadSelf(from: json).cast()
  }
}
