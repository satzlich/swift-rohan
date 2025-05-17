// Copyright 2024-2025 Lie Yan

import Foundation
import UnicodeMathClass

final class MathKindNode: MathNode {
  override class var type: NodeType { .mathKind }

  let mathKind: MathKind
  private let _nucleus: ContentNode
  var nucleus: ContentNode { _nucleus }

  init(_ mathKind: MathKind, _ nucleus: [Node]) {
    self.mathKind = mathKind
    self._nucleus = ContentNode(nucleus)
    super.init()
    self._setUp()
  }

  init(_ mathKind: MathKind, _ nucleus: ContentNode) {
    self.mathKind = mathKind
    self._nucleus = nucleus
    super.init()
    self._setUp()
  }

  init(deepCopyOf node: MathKindNode) {
    self.mathKind = node.mathKind
    self._nucleus = node._nucleus.deepCopy()
    super.init()
    self._setUp()
  }

  private func _setUp() {
    self._nucleus.setParent(self)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case mathKind, nuc }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.mathKind = try container.decode(MathKind.self, forKey: .mathKind)
    self._nucleus = try container.decode(ContentNode.self, forKey: .nuc)
    super.init()
    self._setUp()
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(mathKind, forKey: .mathKind)
    try container.encode(_nucleus, forKey: .nuc)
    try super.encode(to: encoder)
  }

  // MARK: - Layout

  override var isDirty: Bool { _nucleus.isDirty }

  private typealias _LayoutFragment = MathClassLayoutFragment<MathListLayoutFragment>
  private var _classFragment: _LayoutFragment?
  override var layoutFragment: (any MathLayoutFragment)? { _classFragment }

  override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    precondition(context is MathListLayoutContext)
    let context = context as! MathListLayoutContext

    if fromScratch {
      let nucleus: MathListLayoutFragment =
        LayoutUtils.createMathListLayoutFragmentEcon(_nucleus, parent: context)

      let classFragment = MathClassLayoutFragment(mathKind, nucleus)
      _classFragment = classFragment

      classFragment.fixLayout(context.mathContext)
      context.insertFragment(classFragment, self)
    }
    else {
      guard let classFragment = _classFragment
      else {
        assertionFailure("classFragment should not be nil")
        return
      }

      // save metrics before any layout changes
      let oldMetrics = classFragment.boxMetrics
      var needsFixLayout = false

      if _nucleus.isDirty {
        let oldMetrics = classFragment.wrapped.boxMetrics
        LayoutUtils.reconcileMathListLayoutFragmentEcon(
          _nucleus, classFragment.wrapped, parent: context)
        if classFragment.wrapped.isNearlyEqual(to: oldMetrics) == false {
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
    case .nuc: return _classFragment?.wrapped
    default: return nil
    }
  }

  override func getMathIndex(interactingAt point: CGPoint) -> MathIndex? {
    guard _classFragment != nil else { return nil }
    return .nuc
  }

  override func rayshoot(
    from point: CGPoint, _ component: MathIndex,
    in direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    guard let fragment = _classFragment,
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
}
