// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

final class AccentNode: MathNode {
  override class var type: NodeType { .accent }

  let accent: Character

  init(accent: Character, nucleus: AccentedNode) {
    self.accent = accent
    self._nucleus = nucleus
    super.init()
    self._setUp()
  }

  init(accent: Character, nucleus: [Node]) {
    self.accent = accent
    self._nucleus = AccentedNode(nucleus)
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
    _nucleus = try container.decode(AccentedNode.self, forKey: .nuc)

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

  override var isBlock: Bool { false }

  override var isDirty: Bool { _nucleus.isDirty }

  private var _accentFragment: MathAccentLayoutFragment? = nil
  override var layoutFragment: (any MathLayoutFragment)? { _accentFragment }

  override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    precondition(context is MathListLayoutContext)
    let context = context as! MathListLayoutContext

    func layoutComponent(
      _ component: ContentNode, _ fragment: inout MathListLayoutFragment?,
      fromScratch: Bool
    ) {
      let subContext =
        Self.createLayoutContextEcon(for: component, &fragment, parent: context)
      subContext.beginEditing()
      component.performLayout(subContext, fromScratch: fromScratch)
      subContext.endEditing()
    }

    func layoutComponent(
      _ component: ContentNode, _ fragment: MathListLayoutFragment, fromScratch: Bool
    ) {
      let subContext =
        Self.createLayoutContextEcon(for: component, fragment, parent: context)
      subContext.beginEditing()
      component.performLayout(subContext, fromScratch: fromScratch)
      subContext.endEditing()
    }

    if fromScratch {
      var nucFrag: MathListLayoutFragment?
      layoutComponent(nucleus, &nucFrag, fromScratch: true)
      _accentFragment =
        MathAccentLayoutFragment(accent: accent, nucleus: nucFrag!)
      _accentFragment!.fixLayout(context.mathContext)
      context.insertFragment(_accentFragment!, self)
    }
    else {
      var needsFixLayout = false

      if nucleus.isDirty {
        let nucBounds = _accentFragment!.nucleus.bounds
        layoutComponent(nucleus, _accentFragment!.nucleus, fromScratch: false)
        if _accentFragment!.nucleus.bounds.isNearlyEqual(to: nucBounds) == false {
          needsFixLayout = true
        }
      }

      if needsFixLayout {
        let bounds = _accentFragment!.bounds
        _accentFragment!.fixLayout(context.mathContext)
        if bounds.isNearlyEqual(to: _accentFragment!.bounds) == false {
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

  private let _nucleus: AccentedNode

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

final class AccentedNode: ContentNode {
  override func deepCopy() -> AccentedNode { AccentedNode(deepCopyOf: self) }

  override func cloneEmpty() -> Self { Self() }

  override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      var properties = super.getProperties(styleSheet)
      properties[MathProperty.cramped] = .bool(true)
      _cachedProperties = properties
    }
    return _cachedProperties!
  }
}
