import Foundation
import _RopeModule

final class MathOperatorNode: SimpleNode {
  // MARK: - Node

  final override func deepCopy() -> Self { Self(mathOperator) }

  final override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(mathOperator: self, context)
  }

  final override class var type: NodeType { .mathOperator }

  final override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      var current = super.getProperties(styleSheet)

      let mathContext = MathUtils.resolveMathContext(current, styleSheet)
      let fontSize = FontSize(rawValue: mathContext.getFontSize())
      current[TextProperty.size] = .fontSize(fontSize)

      _cachedProperties = current
    }
    return _cachedProperties!
  }

  // MARK: - Node(Layout)

  final override func layoutLength() -> Int { 1 }

  final override func performLayout(
    _ context: any LayoutContext, fromScratch: Bool, atBlockEdge: Bool
  ) -> Int {
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
        return 1
      }
      context.skipForward(1)
    }

    return 1
  }

  // MARK: - Node(Codable)

  private enum CodingKeys: CodingKey { case command }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let command = try container.decode(String.self, forKey: .command)
    guard let mathOp = MathOperator.lookup(command)
    else {
      throw DecodingError.dataCorruptedError(
        forKey: .command, in: container,
        debugDescription: "Invalid math operator command: \(command)")
    }
    self.mathOperator = mathOp
    try super.init(from: decoder)
  }

  final override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(mathOperator.command, forKey: .command)
    try super.encode(to: encoder)
  }

  // MARK: - Node(Storage)

  final override class var storageTags: Array<String> {
    MathOperator.allCommands.map(\.command)
  }

  final override class func load(from json: JSONValue) -> NodeLoaded<Node> {
    loadSelf(from: json).cast()
  }

  final override func store() -> JSONValue {
    let json = JSONValue.array([.string(mathOperator.command)])
    return json
  }

  // MARK: - Storage

  final class func loadSelf(from json: JSONValue) -> NodeLoaded<MathOperatorNode> {
    guard case let .array(array) = json,
      array.count == 1,
      case let .string(command) = array[0],
      let mathOp = MathOperator.lookup(command)
    else { return .failure(UnknownNode(json)) }
    return .success(MathOperatorNode(mathOp))
  }

  // MARK: - MathOperatorNode

  internal let mathOperator: MathOperator
  private var _mathOperatorFragment: MathOperatorLayoutFragment? = nil

  init(_ mathOp: MathOperator) {
    self.mathOperator = mathOp
    super.init()
  }
}
