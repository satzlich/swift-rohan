// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

final class MathOperatorNode: _SimpleNode {
  override class var type: NodeType { .mathOperator }

  let content: ContentNode

  init(_ content: [Node]) {
    self.content = ContentNode(content)
    super.init()
    _setUp()
  }

  init(deepCopyOf node: MathOperatorNode) {
    self.content = node.content.deepCopy()
    super.init()
    _setUp()
  }

  private func _setUp() {
    self.content.setParent(self)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case content }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    content = try container.decode(ContentNode.self, forKey: .content)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(content, forKey: .content)
    try super.encode(to: encoder)
  }

  override func stringify() -> BigString {
    "mathoperator"
  }

  // MARK: - Layout

  override func layoutLength() -> Int { 1 }
  
  private var _mathOperatorFragment: MathOperatorLayoutFragment? = nil
    

  override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {

  }

  // MARK: - Clone and Visitor

  override func deepCopy() -> MathOperatorNode { MathOperatorNode(deepCopyOf: self) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(mathOperator: self, context)
  }

}
