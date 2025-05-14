// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

final class MathOperatorNode: _SimpleNode {
  override class var type: NodeType { .mathOperator }

  let mathOp: MathOperator

  init(_ mathOp: MathOperator) {
    self.mathOp = mathOp
    super.init()
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case mathOp }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    mathOp = try container.decode(MathOperator.self, forKey: .mathOp)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(mathOp, forKey: .mathOp)
    try super.encode(to: encoder)
  }

  // MARK: - Layout

  override func layoutLength() -> Int { 1 }

  private var _mathOperatorFragment: MathOperatorLayoutFragment? = nil

  override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    precondition(context is MathListLayoutContext)
    let context = context as! MathListLayoutContext

    if fromScratch {
      let subContext = TextLineLayoutContext(context.styleSheet)

      // layout content
      subContext.beginEditing()
      subContext.insertText(mathOp.string, self)
      subContext.endEditing()

      // set fragment
      let content = TextLineLayoutFragment(
        subContext.textStorage, subContext.ctLine, options: .imageBounds)
      let fragment = MathOperatorLayoutFragment(content, mathOp)
      _mathOperatorFragment = fragment
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

  // MARK: - Styles

  override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      var properties = super.getProperties(styleSheet)
      // CAUTION: avoid infinite loop
      let mathContext = MathUtils.resolveMathContext(properties, styleSheet)
      let fontSize = FontSize(rawValue: mathContext.getFont().size)

      properties[TextProperty.size] = .fontSize(fontSize)

      _cachedProperties = properties
    }
    return _cachedProperties!
  }

  // MARK: - Clone and Visitor

  override func deepCopy() -> MathOperatorNode { MathOperatorNode(mathOp) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(mathOperator: self, context)
  }
}
