// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

final class MathOperatorNode: SimpleNode {
  override class var type: NodeType { .mathOperator }

  let mathOperator: MathOperator

  init(_ mathOp: MathOperator) {
    self.mathOperator = mathOp
    super.init()
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case mathOp }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    mathOperator = try container.decode(MathOperator.self, forKey: .mathOp)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(mathOperator, forKey: .mathOp)
    try super.encode(to: encoder)
  }

  // MARK: - Layout

  override func layoutLength() -> Int { 1 }

  private var _mathOperatorFragment: MathOperatorLayoutFragment? = nil

  override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    precondition(context is MathListLayoutContext)
    let context = context as! MathListLayoutContext

    if fromScratch {
      let fragment =
        MathOperatorLayoutFragment(self, context.styleSheet, context.mathContext)
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

  override func deepCopy() -> MathOperatorNode { MathOperatorNode(mathOperator) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(mathOperator: self, context)
  }

  override class var storageTags: [String] {
    MathOperator.allCommands.map { $0.command }
  }

  override func store() -> JSONValue {
    let json = JSONValue.array([.string(mathOperator.command)])
    return json
  }

  class func loadSelf(from json: JSONValue) -> _LoadResult<MathOperatorNode> {
    guard case let .array(array) = json,
      array.count == 1,
      case let .string(command) = array[0],
      let mathOp = MathOperator.lookup(command)
    else { return .failure(UnknownNode(json)) }
    return .success(MathOperatorNode(mathOp))
  }

  override class func load(from json: JSONValue) -> _LoadResult<Node> {
    loadSelf(from: json).cast()
  }
}
