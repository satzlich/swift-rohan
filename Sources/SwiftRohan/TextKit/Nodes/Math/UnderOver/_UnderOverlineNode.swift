// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

class _UnderOverlineNode: MathNode {
  enum Subtype {
    // overline, etc
    case over
    // underline, etc
    case under
  }

  let subtype: Subtype
  let _nucleus: ContentNode

  var nucleus: ContentNode { _nucleus }

  init(_ subtype: Subtype, _ nucleus: ContentNode) {
    self.subtype = subtype
    self._nucleus = nucleus
    super.init()
    _setUp()
  }

  init(_ subtype: Subtype, _ nucleus: [Node]) {
    let nucleus =
      (subtype == .over) ? CrampedNode(nucleus) : ContentNode(nucleus)
    self.subtype = subtype
    self._nucleus = nucleus
    super.init()
    _setUp()
  }

  init(deepCopyOf node: _UnderOverlineNode) {
    self.subtype = node.subtype
    self._nucleus = node._nucleus.deepCopy()
    super.init()
    _setUp()
  }

  private final func _setUp() {
    _nucleus.setParent(self)
  }

  required init(from decoder: any Decoder) throws {
    preconditionFailure("should not be called")
  }

  // MARK: - Content

  override func stringify() -> BigString {
    "underoverline"
  }

  // MARK: - Layout

  final override var isBlock: Bool { false }

  final override var isDirty: Bool { _nucleus.isDirty }

  private var _underOverFragment: MathUnderOverlineLayoutFragment? = nil

  final override var layoutFragment: (any MathLayoutFragment)? { _underOverFragment }

  final override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    precondition(context is MathListLayoutContext)
    let context = context as! MathListLayoutContext

    if fromScratch {
      let nucleus: MathListLayoutFragment =
        LayoutUtils.createMathListLayoutFragmentEcon(nucleus, parent: context)

      let underOverFragment = MathUnderOverlineLayoutFragment(subtype, nucleus)
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
        let oldMetrics = underOverFragment.boxMetrics
        underOverFragment.fixLayout(context.mathContext)
        if underOverFragment.isNearlyEqual(to: oldMetrics) == false {
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

  final override func getFragment(_ index: MathIndex) -> MathLayoutFragment? {
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
}
