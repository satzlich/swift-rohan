// Copyright 2024-2025 Lie Yan

import Foundation

final class MathExpressionNode: SimpleNode {
  // MARK: - Node

  final override func deepCopy() -> Self { Self(mathExpression) }

  final override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(mathExpression: self, context)
  }

  final override class var type: NodeType { .mathExpression }

  final override func resetCachedProperties() {
    super.resetCachedProperties()
    _deflated.resetCachedProperties()
  }

  // MARK: - Node(Layout)

  final override func layoutLength() -> Int { _deflated.layoutLength() }

  final override func performLayout(
    _ context: any LayoutContext, fromScratch: Bool
  ) -> Int {
    precondition(context is MathListLayoutContext)
    let context = context as! MathListLayoutContext

    if fromScratch {
      return _deflated.performLayout(context, fromScratch: true)
    }
    else {
      assertionFailure("theorectically, we should never reach here")
      let layoutLength = _deflated.layoutLength()
      context.skipBackwards(layoutLength)
      return layoutLength
    }
  }

  // MARK: - Node(Codable)

  private enum CodingKeys: CodingKey { case command }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let command = try container.decode(String.self, forKey: .command)
    guard let mathExpression = MathExpression.lookup(command) else {
      throw DecodingError.dataCorruptedError(
        forKey: .command, in: container,
        debugDescription: "Unknown math expression command: \(command)")
    }

    self.mathExpression = mathExpression
    self._deflated = mathExpression.deflated()
    try super.init(from: decoder)
    _setUp()
  }

  final override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(mathExpression.command, forKey: .command)
    try super.encode(to: encoder)
  }

  // MARK: - Node(Storage)

  final override class var storageTags: Array<String> {
    MathExpression.allCommands.map(\.command)
  }

  final override class func load(from json: JSONValue) -> NodeLoaded<Node> {
    loadSelf(from: json).cast()
  }

  final override func store() -> JSONValue {
    let json = JSONValue.array([.string(mathExpression.command)])
    return json
  }

  // MARK: - Storage

  final class func loadSelf(from json: JSONValue) -> NodeLoaded<MathExpressionNode> {
    guard case let .array(array) = json,
      array.count == 1,
      case let .string(tag) = array[0],
      let mathExpression = MathExpression.lookup(tag)
    else { return .failure(UnknownNode(json)) }
    return .success(MathExpressionNode(mathExpression))
  }

  // MARK: - MathExpressionNode

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
}
