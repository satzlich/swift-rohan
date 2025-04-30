// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

class _UnderOverspreaderNode: MathNode {
  typealias Subtype = _UnderOverlineNode.Subtype

  let subtype: Subtype

  let spreader: Character

  internal let _nucleus: ContentNode
  var nucleus: ContentNode { _nucleus }

  init(_ subtype: Subtype, _ spreader: Character, _ nucleus: ContentNode) {
    self.subtype = subtype
    self.spreader = spreader
    self._nucleus = nucleus
    super.init()
    _setUp()
  }

  init(_ subtype: Subtype, _ spreader: Character, _ nucleus: [Node]) {
    let nucleus =
      (subtype == .over) ? CrampedNode(nucleus) : ContentNode(nucleus)
    self.subtype = subtype
    self.spreader = spreader
    self._nucleus = nucleus
    super.init()
    _setUp()
  }

  init(deepCopyOf node: _UnderOverspreaderNode) {
    self.subtype = node.subtype
    self.spreader = node.spreader
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
    "underoverspreader"
  }

  // MARK: - Layout

  final override var isBlock: Bool { false }

  final override var isDirty: Bool { _nucleus.isDirty }

  private var _underOverFragment: MathUnderOverspreaderLayoutFragment? = nil

  final override var layoutFragment: (any MathLayoutFragment)? { _underOverFragment }

  final override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    precondition(context is MathListLayoutContext)
    let context = context as! MathListLayoutContext

    if fromScratch {
      let nucFrag = LayoutUtils.createMathListLayoutFragmentEcon(nucleus, parent: context)
      _underOverFragment = MathUnderOverspreaderLayoutFragment(subtype, spreader, nucFrag)
      _underOverFragment!.fixLayout(context.mathContext)
      context.insertFragment(_underOverFragment!, self)
    }
    else {
      var needsFixLayout = false

      if nucleus.isDirty {
        let nucBounds = _underOverFragment!.nucleus.bounds
        LayoutUtils.reconcileMathListLayoutFragmentEcon(
          nucleus, _underOverFragment!.nucleus, parent: context)
        if _underOverFragment!.nucleus.bounds.isNearlyEqual(to: nucBounds) == false {
          needsFixLayout = true
        }
      }

      if needsFixLayout {
        let bounds = _underOverFragment!.bounds
        _underOverFragment!.fixLayout(context.mathContext)
        if bounds.isNearlyEqual(to: _underOverFragment!.bounds) == false {
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
