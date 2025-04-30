// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

final class AccentNode: MathNode {
  override class var type: NodeType { .accent }

  let accent: Character

  init(accent: Character, nucleus: CrampedNode) {
    self.accent = accent
    self._nucleus = nucleus
    super.init()
    self._setUp()
  }

  init(accent: Character, nucleus: [Node]) {
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
    let accent = try container.decode(String.self, forKey: .accent)

    guard accent.count == 1,
      let first = accent.first
    else {
      throw DecodingError.dataCorruptedError(
        forKey: .accent, in: container,
        debugDescription: "Accent must be a single character")
    }
    self.accent = first
    _nucleus = try container.decode(CrampedNode.self, forKey: .nuc)

    super.init()
    self._setUp()
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(String(accent), forKey: .accent)
    try container.encode(_nucleus, forKey: .nuc)
    try super.encode(to: encoder)
  }

  // MARK: - Content

  override func stringify() -> BigString {
    String(accent) + _nucleus.stringify()
  }

  // MARK: - Layout

  override var isDirty: Bool { _nucleus.isDirty }

  private var _accentFragment: MathAccentLayoutFragment? = nil
  override var layoutFragment: (any MathLayoutFragment)? { _accentFragment }

  override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    precondition(context is MathListLayoutContext)
    let context = context as! MathListLayoutContext

    if fromScratch {
      let nucFrag = LayoutUtils.createFragmentEcon(nucleus, parent: context)
      let accentFragment = MathAccentLayoutFragment(accent: accent, nucleus: nucFrag)
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
        let nucBounds = accentFragment.nucleus.bounds
        LayoutUtils.reconcileFragmentEcon(
          nucleus, accentFragment.nucleus, parent: context)
        if accentFragment.nucleus.bounds.isNearlyEqual(to: nucBounds) == false {
          needsFixLayout = true
        }
      }

      if needsFixLayout {
        let bounds = accentFragment.bounds
        accentFragment.fixLayout(context.mathContext)
        if bounds.isNearlyEqual(to: accentFragment.bounds) == false {
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
      return _accentFragment?.nucleus
    default:
      return nil
    }
  }

  override func getMathIndex(interactingAt point: CGPoint) -> MathIndex? {
    guard _accentFragment != nil else { return nil }
    return .nuc
  }

  override func rayshoot(
    from point: CGPoint, _ component: MathIndex,
    in direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    guard let fragment = _accentFragment,
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
}
