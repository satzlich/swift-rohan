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

  // MARK: - Content

  override func stringify() -> BigString {
    "leftright"
  }

  // MARK: - Layout

  override var isBlock: Bool { false }
  override var isDirty: Bool { _nucleus.isDirty }

  private var _leftRightFragment: MathLeftRightLayoutFragment?

  override var layoutFragment: (any MathLayoutFragment)? { _leftRightFragment }

  override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    precondition(context is MathListLayoutContext)
    let context = context as! MathListLayoutContext

    if fromScratch {
      let nucFrag = LayoutUtils.createFragmentEcon(nucleus, parent: context)
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

      var needsFixLayout = false

      if nucleus.isDirty {
        let nucBounds = leftRightFragment.nucleus.bounds
        LayoutUtils.reconcileFragmentEcon(
          nucleus, leftRightFragment.nucleus, parent: context)
        if leftRightFragment.nucleus.bounds.isNearlyEqual(to: nucBounds) == false {
          needsFixLayout = true
        }
      }

      if needsFixLayout {
        let bounds = leftRightFragment.bounds
        leftRightFragment.fixLayout(context.mathContext)
        if bounds.isNearlyEqual(to: leftRightFragment.bounds) == false {
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

  override func getFragment(_ index: MathIndex) -> MathListLayoutFragment? {
    switch index {
    case .nuc:
      return _leftRightFragment?.nucleus
    default:
      return nil
    }
  }

  override func getMathIndex(interactingAt point: CGPoint) -> MathIndex? {
    guard let fragment = _leftRightFragment else { return nil }

    let x1 = (0 + fragment.nucleus.minX) / 2
    if point.x < x1 {
      return nil
    }
    let x2 = (fragment.width + fragment.nucleus.maxX) / 2
    if point.x > x2 {
      return nil
    }

    return .nuc
  }

  override func rayshoot(
    from point: CGPoint, _ component: MathIndex,
    in direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    guard let fragment = _leftRightFragment,
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

}
