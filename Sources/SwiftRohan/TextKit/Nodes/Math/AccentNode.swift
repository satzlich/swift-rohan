// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

final class AccentNode: MathNode {
  // MARK: - Node

  final override func deepCopy() -> Self { Self(deepCopyOf: self) }

  final override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(accent: self, context)
  }

  final override class var type: NodeType { .accent }

  // MARK: - Node(Layout)

  final override var isDirty: Bool { _nucleus.isDirty }

  final override func performLayout(
    _ context: any LayoutContext, fromScratch: Bool
  ) -> Int {
    precondition(context is MathListLayoutContext)
    let context = context as! MathListLayoutContext

    if fromScratch {
      let nucFrag = LayoutUtils.buildMathListLayoutFragment(nucleus, parent: context)
      let accentFragment = MathAccentLayoutFragment(accent, nucleus: nucFrag)
      _nodeFragment = accentFragment
      accentFragment.fixLayout(context.mathContext)
      context.insertFragment(accentFragment, self)
    }
    else {
      guard let accentFragment = _nodeFragment
      else {
        assertionFailure("Accent fragment is nil")
        return layoutLength()
      }

      // save metrics before any layout changes
      let oldMetrics = accentFragment.boxMetrics
      var needsFixLayout = false

      if nucleus.isDirty {
        let nucMetrics = accentFragment.nucleus.boxMetrics

        LayoutUtils.reconcileMathListLayoutFragment(
          nucleus, accentFragment.nucleus, parent: context)
        if accentFragment.nucleus.isNearlyEqual(to: nucMetrics) == false {
          needsFixLayout = true
        }
      }

      if needsFixLayout {
        accentFragment.fixLayout(context.mathContext)
        if accentFragment.isNearlyEqual(to: oldMetrics) == false {
          context.invalidateBackwards(layoutLength())
          return layoutLength()
        }
        // FALL THROUGH
      }
      context.skipBackwards(layoutLength())
    }
    return layoutLength()
  }

  // MARK: - Node(Codable)

  private enum CodingKeys: CodingKey { case command, nuc }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let command = try container.decode(String.self, forKey: .command)
    guard let accent = MathAccent.lookup(command) else {
      throw DecodingError.dataCorruptedError(
        forKey: .command, in: container,
        debugDescription: "Unknown accent command: \(command)")
    }
    self.accent = accent
    self._nucleus = try container.decode(CrampedNode.self, forKey: .nuc)
    super.init()
    self._setUp()
  }

  final override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(accent.command, forKey: .command)
    try container.encode(_nucleus, forKey: .nuc)
    try super.encode(to: encoder)
  }

  // MARK: - Node(Storage)

  final override class var storageTags: Array<String> {
    MathAccent.allCommands.map(\.command)
  }

  final override class func load(from json: JSONValue) -> NodeLoaded<Node> {
    loadSelf(from: json).cast()
  }

  final override func store() -> JSONValue {
    let nucleus = nucleus.store()
    let json = JSONValue.array([.string(accent.command), nucleus])
    return json
  }

  // MARK: - MathNode(Component)

  final override func enumerateComponents() -> Array<MathNode.Component> {
    [(MathIndex.nuc, _nucleus)]
  }

  // MARK: - MathNode(Layout)

  final override var layoutFragment: (any MathLayoutFragment)? { _nodeFragment }

  final override func getFragment(_ index: MathIndex) -> LayoutFragment? {
    switch index {
    case .nuc: return _nodeFragment?.nucleus
    default: return nil
    }
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

  final class func loadSelf(from json: JSONValue) -> NodeLoaded<AccentNode> {
    guard case let .array(array) = json,
      array.count == 2,
      case let .string(command) = array[0],
      let accent = MathAccent.lookup(command)
    else { return .failure(UnknownNode(json)) }

    let nucleus = CrampedNode.loadSelf(from: array[1]) as NodeLoaded<CrampedNode>
    switch nucleus {
    case .success(let nucleus):
      return .success(AccentNode(accent, nucleus: nucleus))
    case .corrupted(let nucleus):
      return .corrupted(AccentNode(accent, nucleus: nucleus))
    case .failure:
      return .failure(UnknownNode(json))
    }
  }

  // MARK: - AccentNode

  internal let accent: MathAccent
  private let _nucleus: CrampedNode
  internal var nucleus: ContentNode { _nucleus }
  private var _nodeFragment: MathAccentLayoutFragment? = nil

  init(_ accent: MathAccent, nucleus: CrampedNode) {
    self.accent = accent
    self._nucleus = nucleus
    super.init()
    self._setUp()
  }

  init(_ accent: MathAccent, nucleus: ElementStore) {
    self.accent = accent
    self._nucleus = CrampedNode(nucleus)
    super.init()
    self._setUp()
  }

  private init(deepCopyOf accentNode: AccentNode) {
    self.accent = accentNode.accent
    self._nucleus = accentNode._nucleus.deepCopy()
    super.init()
    self._setUp()
  }

  private final func _setUp() {
    _nucleus.setParent(self)
  }

}
