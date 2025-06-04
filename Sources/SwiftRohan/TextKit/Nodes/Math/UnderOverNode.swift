// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

final class UnderOverNode: MathNode {
  override class var type: NodeType { .underOver }

  let spreader: MathSpreader

  private let _nucleus: ContentNode
  var nucleus: ContentNode { _nucleus }

  init(_ spreader: MathSpreader, _ nucleus: ContentNode) {
    self.spreader = spreader
    self._nucleus = nucleus
    super.init()
    _setUp()
  }

  init(_ subtype: MathSpreader, _ nucleus: [Node]) {
    self.spreader = subtype
    self._nucleus = Self.nucleusClazz(for: subtype.subtype).init(nucleus)
    super.init()
    _setUp()
  }

  private static func nucleusClazz(for subtype: MathSpreader.Subtype) -> ContentNode.Type
  {
    switch subtype {
    case .overline, .overspreader: CrampedNode.self
    case .underline, .underspreader: ContentNode.self
    case .xarrow: SuperscriptNode.self
    }
  }

  init(deepCopyOf node: UnderOverNode) {
    self.spreader = node.spreader
    self._nucleus = node._nucleus.deepCopy()
    super.init()
    _setUp()
  }

  private final func _setUp() {
    _nucleus.setParent(self)
  }

  // MARK: - Layout

  final override var isBlock: Bool { false }

  final override var isDirty: Bool { _nucleus.isDirty }

  private var _underOverFragment: MathUnderOverLayoutFragment? = nil

  final override var layoutFragment: (any MathLayoutFragment)? { _underOverFragment }

  final override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    precondition(context is MathListLayoutContext)
    let context = context as! MathListLayoutContext

    if fromScratch {
      let nucleus: MathListLayoutFragment =
        LayoutUtils.createMathListLayoutFragmentEcon(nucleus, parent: context)
      let underOverFragment = MathUnderOverLayoutFragment(spreader, nucleus)
      _underOverFragment = underOverFragment

      underOverFragment.fixLayout(context.mathContext)
      context.insertFragment(underOverFragment, self)
    }
    else {
      guard let underOverFragment = _underOverFragment
      else {
        assertionFailure("underOverFragment should not be nil")
        return
      }

      // save metrics before any layout changes
      let oldMetrics = underOverFragment.boxMetrics
      var needsFixLayout = false

      if nucleus.isDirty {
        let oldMetrics = underOverFragment.nucleus.boxMetrics
        LayoutUtils.reconcileMathListLayoutFragmentEcon(
          nucleus, underOverFragment.nucleus, parent: context)
        if underOverFragment.nucleus.isNearlyEqual(to: oldMetrics) == false {
          needsFixLayout = true
        }
      }

      if needsFixLayout {
        underOverFragment.fixLayout(context.mathContext)
        if underOverFragment.isNearlyEqual(to: oldMetrics) == false {
          context.invalidateBackwards(layoutLength())
          return
        }
        // FALL THROUGH
      }
      context.skipBackwards(layoutLength())
    }
  }

  final override func getFragment(_ index: MathIndex) -> LayoutFragment? {
    switch index {
    case .nuc:
      return _underOverFragment?.nucleus
    default:
      return nil
    }

  }

  final override func getMathIndex(interactingAt point: CGPoint) -> MathIndex? {
    guard _underOverFragment != nil else { return nil }
    return .nuc
  }

  final override func rayshoot(
    from point: CGPoint, _ component: MathIndex,
    in direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    guard let fragment = _underOverFragment,
      component == .nuc
    else { return nil }

    switch direction {
    case .up:
      return RayshootResult(point.with(y: fragment.minY), false)
    case .down:
      return RayshootResult(point.with(y: fragment.maxY), false)
    default:
      assertionFailure("Unexpected Direction")
      return nil
    }
  }

  // MARK: - Component

  final override func enumerateComponents() -> [MathNode.Component] {
    [(MathIndex.nuc, _nucleus)]
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case command, nuc }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    let command = try container.decode(String.self, forKey: .command)
    guard let spreader = MathSpreader.lookup(command) else {
      throw DecodingError.dataCorruptedError(
        forKey: .command, in: container,
        debugDescription: "Unknown MathSpreader command: \(command)")
    }
    self.spreader = spreader
    let clazz = Self.nucleusClazz(for: spreader.subtype)
    self._nucleus = try container.decode(clazz, forKey: .nuc)
    super.init()
    _setUp()
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(spreader.command, forKey: .command)
    try container.encode(nucleus, forKey: .nuc)
    try super.encode(to: encoder)
  }

  // MARK: - Clone and Visitor

  override func deepCopy() -> Node { Self(deepCopyOf: self) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(underOver: self, context)
  }

  override class var storageTags: [String] {
    MathSpreader.allCommands.map { $0.command }
  }

  override func store() -> JSONValue {
    let nucleus = nucleus.store()
    let json = JSONValue.array([.string(spreader.command), nucleus])
    return json
  }

  class func loadSelf(from json: JSONValue) -> _LoadResult<UnderOverNode> {
    guard case let .array(array) = json,
      array.count == 2,
      case let .string(command) = array[0],
      let spreader = MathSpreader.lookup(command)
    else { return .failure(UnknownNode(json)) }

    let nucleus: _LoadResult<ContentNode> =
      switch spreader.subtype {
      case .overline, .overspreader:
        CrampedNode.loadSelf(from: array[1]).cast()
      case .underline, .underspreader:
        ContentNode.loadSelfGeneric(from: array[1])
      case .xarrow:
        SuperscriptNode.loadSelf(from: array[1]).cast()
      }

    switch nucleus {
    case .success(let nucleus):
      return .success(UnderOverNode(spreader, nucleus))
    case .corrupted(let nucleus):
      return .corrupted(UnderOverNode(spreader, nucleus))
    case .failure:
      return .failure(UnknownNode(json))
    }
  }

  override class func load(from json: JSONValue) -> _LoadResult<Node> {
    loadSelf(from: json).cast()
  }
}
