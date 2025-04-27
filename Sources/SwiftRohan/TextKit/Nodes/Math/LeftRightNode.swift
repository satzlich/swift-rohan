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

  // private var _leftRightFragment: MathLeftRightLayoutFragment

  override var layoutFragment: (any MathLayoutFragment)? { preconditionFailure() }

  override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    preconditionFailure()
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
