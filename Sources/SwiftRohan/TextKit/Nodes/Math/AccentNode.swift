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

  override var layoutFragment: (any MathLayoutFragment)? { preconditionFailure() }

  override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    precondition(context is MathListLayoutContext)
    let context = context as! MathListLayoutContext
  }

  override func getFragment(_ index: MathIndex) -> MathListLayoutFragment? {
    preconditionFailure()
  }

  override func getMathIndex(interactingAt point: CGPoint) -> MathIndex? {
    preconditionFailure()
  }

  override func rayshoot(
    from point: CGPoint, _ component: MathIndex,
    in direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    preconditionFailure()
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
