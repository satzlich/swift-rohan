// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

final class LeftRightNode: MathNode {
  override class var type: NodeType { .leftRight }

  let delimiters: DelimiterPair
  private let _nucleus: ContentNode

  init(_ delimiters: DelimiterPair, _ nucleus: ContentNode) {
    self.delimiters = delimiters
    self._nucleus = nucleus
    super.init()
    self._setUp()
  }

  init(_ delimiters: DelimiterPair, _ nucleus: [Node]) {
    self.delimiters = delimiters
    self._nucleus = ContentNode(nucleus)
    super.init()
    self._setUp()
  }

  init(deepCopyOf leftRightNode: LeftRightNode) {
    self.delimiters = leftRightNode.delimiters
    self._nucleus = leftRightNode._nucleus.deepCopy()
    super.init()
    self._setUp()
  }

  private func _setUp() {
    _nucleus.setParent(self)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case delim, nuc }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    delimiters = try container.decode(DelimiterPair.self, forKey: .delim)
    _nucleus = try container.decode(ContentNode.self, forKey: .nuc)
    super.init()
    self._setUp()
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(delimiters, forKey: .delim)
    try container.encode(_nucleus, forKey: .nuc)
    try super.encode(to: encoder)
  }

  // MARK: - Layout

  override var isDirty: Bool { _nucleus.isDirty }

  private var _leftRightFragment: MathLeftRightLayoutFragment?

  override var layoutFragment: (any MathLayoutFragment)? { _leftRightFragment }

  override func initLayoutContext(
    for component: ContentNode, _ fragment: any LayoutFragment, parent: any LayoutContext
  ) -> any LayoutContext {
    defaultInitLayoutContext(for: component, fragment, parent: parent)
  }

  override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    precondition(context is MathListLayoutContext)
    let context = context as! MathListLayoutContext

    if fromScratch {
      let nucFrag = LayoutUtils.buildMathListLayoutFragment(nucleus, parent: context)
      let leftRightFragment = MathLeftRightLayoutFragment(delimiters, nucFrag)
      _leftRightFragment = leftRightFragment
      leftRightFragment.fixLayout(context.mathContext)
      context.insertFragment(leftRightFragment, self)
    }
    else {
      guard let leftRightFragment = _leftRightFragment
      else {
        assertionFailure("LeftRightNode should have a layout fragment")
        return
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
          context.invalidateBackwards(layoutLength())
          return
        }
        // FALL THROUGH
      }
      context.skipBackwards(layoutLength())
    }
  }

  override func getFragment(_ index: MathIndex) -> LayoutFragment? {
    switch index {
    case .nuc: return _leftRightFragment?.nucleus
    default: return nil
    }
  }

  override func getMathIndex(interactingAt point: CGPoint) -> MathIndex? {
    _leftRightFragment?.getMathIndex(interactingAt: point)
  }

  override func rayshoot(
    from point: CGPoint, _ component: MathIndex,
    in direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    _leftRightFragment?.rayshoot(from: point, component, in: direction)
  }

  // MARK: - Component

  var nucleus: ContentNode { _nucleus }

  override func enumerateComponents() -> [MathNode.Component] {
    [(MathIndex.nuc, _nucleus)]
  }

  // MARK: - Clone and Visitor

  override func deepCopy() -> Self { Self(deepCopyOf: self) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(leftRight: self, context)
  }

  private static let uniqueTag = "lrdelim"
  override class var storageTags: [String] {
    [uniqueTag]
  }

  override func store() -> JSONValue {
    let nucleus: JSONValue = _nucleus.store()
    let delimiters: JSONValue = delimiters.store()
    let json = JSONValue.array([.string(Self.uniqueTag), delimiters, nucleus])
    return json
  }

  class func loadSelf(from json: JSONValue) -> _LoadResult<LeftRightNode> {
    guard case let .array(array) = json,
      array.count == 3,
      case let .string(tag) = array[0],
      tag == uniqueTag,
      let delimiters = DelimiterPair.load(from: array[1])
    else { return .failure(UnknownNode(json)) }

    let nucleus = ContentNode.loadSelfGeneric(from: array[2]) as _LoadResult<ContentNode>
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

  override class func load(from json: JSONValue) -> _LoadResult<Node> {
    loadSelf(from: json).cast()
  }
}
