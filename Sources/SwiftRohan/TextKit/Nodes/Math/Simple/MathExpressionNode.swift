// Copyright 2024-2025 Lie Yan

import Foundation

final class MathExpressionNode: SimpleNode {
  override class var type: NodeType { .mathExpression }

  let mathExpression: MathExpression
  private let _deflated: Node

  init(_ mathExpression: MathExpression) {
    self.mathExpression = mathExpression
    self._deflated = mathExpression.deflated()
    super.init()
    _setUp()
  }

  private func _setUp() {
    _deflated.setParent(self)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case mexpr }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    mathExpression = try container.decode(MathExpression.self, forKey: .mexpr)
    _deflated = mathExpression.deflated()
    try super.init(from: decoder)
    _setUp()
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(mathExpression, forKey: .mexpr)
    try super.encode(to: encoder)
  }

  // MARK: - Layout

  override func layoutLength() -> Int { _deflated.layoutLength() }

  override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    precondition(context is MathListLayoutContext)
    let context = context as! MathListLayoutContext

    if fromScratch {
      _deflated.performLayout(context, fromScratch: true)
    }
    else {
      context.skipBackwards(layoutLength())
    }
  }

  // MARK: - Clone and Visitor

  override func deepCopy() -> MathExpressionNode {
    MathExpressionNode(mathExpression)
  }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(mathExpression: self, context)
  }

  override class var storageTags: [String] {
    MathExpression.predefinedCases.map { $0.command }
  }

  override func store() -> JSONValue {
    let json = JSONValue.array([.string(mathExpression.command)])
    return json
  }

  class func loadSelf(from json: JSONValue) -> _LoadResult<MathExpressionNode> {
    guard case let .array(array) = json,
      array.count == 1,
      case let .string(tag) = array[0],
      let mathExpression = MathExpression.lookup(tag)
    else { return .failure(UnknownNode(json)) }
    return .success(MathExpressionNode(mathExpression))
  }

  override class func load(from json: JSONValue) -> _LoadResult<Node> {
    loadSelf(from: json).cast()
  }
}
