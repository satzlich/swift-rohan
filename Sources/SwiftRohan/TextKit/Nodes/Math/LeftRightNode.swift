// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

final class LeftRightNode: MathNode {
  // MARK: - Node

  final override func deepCopy() -> Self { Self(deepCopyOf: self) }

  final override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(leftRight: self, context)
  }

  final override class var type: NodeType { .leftRight }

  // MARK: - Node(Layout)

  final override var isDirty: Bool { _nucleus.isDirty }

  final override func performLayoutForward(
    _ context: any LayoutContext, fromScratch: Bool
  ) -> Int {
    precondition(context is MathListLayoutContext)
    let context = context as! MathListLayoutContext

    if fromScratch {
      let nucFrag = LayoutUtils.buildMathListLayoutFragment(nucleus, parent: context)
      let leftRightFragment = MathLeftRightLayoutFragment(delimiters, nucFrag)
      _nodeFragment = leftRightFragment
      leftRightFragment.fixLayout(context.mathContext)
      context.insertFragmentForward(leftRightFragment, self)
    }
    else {
      guard let leftRightFragment = _nodeFragment
      else {
        assertionFailure("LeftRightNode should have a layout fragment")
        return layoutLength()
      }

      // save old metrics before any layout changes
      let oldMetrics = leftRightFragment.boxMetrics
      var needsFixLayout = false

      if nucleus.isDirty {
        let oldMetrics = leftRightFragment.nucleus.boxMetrics
        LayoutUtils.reconcileMathListLayoutFragment(
          nucleus, leftRightFragment.nucleus, parent: context)
        if leftRightFragment.nucleus.isNearlyEqual(to: oldMetrics) == false {
          needsFixLayout = true
        }
      }

      if needsFixLayout {
        leftRightFragment.fixLayout(context.mathContext)
        if leftRightFragment.isNearlyEqual(to: oldMetrics) == false {
          context.invalidateForward(layoutLength())
          return layoutLength()
        }
        // FALL THROUGH
      }
      context.skipForward(layoutLength())
    }

    return layoutLength()
  }

  // MARK: - Node(Codable)

  private enum CodingKeys: CodingKey { case delim, nuc }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    delimiters = try container.decode(DelimiterPair.self, forKey: .delim)
    _nucleus = try container.decode(ContentNode.self, forKey: .nuc)
    super.init()
    self._setUp()
  }

  final override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(delimiters, forKey: .delim)
    try container.encode(_nucleus, forKey: .nuc)
    try super.encode(to: encoder)
  }

  // MARK: - Node(Storage)

  private static let uniqueTag = "leftright"

  final override class var storageTags: Array<String> { [uniqueTag] }

  final override class func load(from json: JSONValue) -> NodeLoaded<Node> {
    loadSelf(from: json).cast()
  }

  final override func store() -> JSONValue {
    let nucleus: JSONValue = _nucleus.store()
    let delimiters: JSONValue = delimiters.store()
    let json = JSONValue.array([.string(Self.uniqueTag), delimiters, nucleus])
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

  internal class func loadSelf(from json: JSONValue) -> NodeLoaded<LeftRightNode> {
    guard case let .array(array) = json,
      array.count == 3,
      case let .string(tag) = array[0],
      tag == uniqueTag,
      let delimiters = DelimiterPair.load(from: array[1])
    else { return .failure(UnknownNode(json)) }

    let nucleus = ContentNode.loadSelfGeneric(from: array[2]) as NodeLoaded<ContentNode>
    switch nucleus {
    case .success(let nucleus):
      let leftRight = LeftRightNode(delimiters, nucleus)
      return .success(leftRight)
    case .corrupted(let nucleus):
      let leftRight = LeftRightNode(delimiters, nucleus)
      return .corrupted(leftRight)
    case .failure:
      return .failure(UnknownNode(json))
    }
  }

  // MARK: - LeftRightNode

  internal let delimiters: DelimiterPair

  private let _nucleus: ContentNode
  internal var nucleus: ContentNode { _nucleus }

  private var _nodeFragment: MathLeftRightLayoutFragment?

  init(_ delimiters: DelimiterPair, _ nucleus: ContentNode) {
    self.delimiters = delimiters
    self._nucleus = nucleus
    super.init()
    self._setUp()
  }

  init(_ delimiters: DelimiterPair, _ nucleus: ElementStore) {
    self.delimiters = delimiters
    self._nucleus = ContentNode(nucleus)
    super.init()
    self._setUp()
  }

  private init(deepCopyOf leftRightNode: LeftRightNode) {
    self.delimiters = leftRightNode.delimiters
    self._nucleus = leftRightNode._nucleus.deepCopy()
    super.init()
    self._setUp()
  }

  private func _setUp() {
    _nucleus.setParent(self)
  }

}
