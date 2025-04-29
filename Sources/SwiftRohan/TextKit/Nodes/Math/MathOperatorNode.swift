// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

final class MathOperatorNode: _SimpleNode {
  override class var type: NodeType { .mathOperator }

  let content: MathOpContentNode
  let limits: Bool

  init(_ content: [Node], _ limits: Bool) {
    self.content = MathOpContentNode(content)
    self.limits = limits
    super.init()
    _setUp()
  }

  init(deepCopyOf node: MathOperatorNode) {
    self.content = node.content.deepCopy()
    self.limits = node.limits
    super.init()
    _setUp()
  }

  private func _setUp() {
    self.content.setParent(self)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case content, limits }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    content = try container.decode(MathOpContentNode.self, forKey: .content)
    limits = try container.decode(Bool.self, forKey: .limits)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(content, forKey: .content)
    try container.encode(limits, forKey: .limits)
    try super.encode(to: encoder)
  }

  override func stringify() -> BigString {
    "mathoperator"
  }

  // MARK: - Layout

  override func layoutLength() -> Int { 1 }

  private var _mathOperatorFragment: MathOperatorLayoutFragment? = nil

  override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    precondition(context is MathListLayoutContext)
    let context = context as! MathListLayoutContext

    if fromScratch {
      let content = LayoutUtils.createFragmentEcon(content, parent: context)
      let fragment = MathOperatorLayoutFragment(content, limits)
      _mathOperatorFragment = fragment
      fragment.fixLayout(context.mathContext)
      context.insertFragment(fragment, self)
    }
    else {
      guard _mathOperatorFragment != nil
      else {
        assertionFailure("Fragment should exist")
        return
      }

      context.skipBackwards(layoutLength())
    }
  }

  // MARK: - Clone and Visitor

  override func deepCopy() -> MathOperatorNode { MathOperatorNode(deepCopyOf: self) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(mathOperator: self, context)
  }
}

final class MathOpContentNode: ContentNode {
  override func deepCopy() -> MathOpContentNode { MathOpContentNode(deepCopyOf: self) }

  override func cloneEmpty() -> Self { Self() }

  override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      var properties = super.getProperties(styleSheet)
      properties[MathProperty.variant] = .mathVariant(.serif)
      properties[MathProperty.italic] = .bool(false)
      properties[MathProperty.bold] = .bool(false)
      _cachedProperties = properties
    }
    return _cachedProperties!
  }
}
