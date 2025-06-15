// Copyright 2024-2025 Lie Yan

import Foundation

final class MultilineNode: ArrayNode {
  // MARK: - Node
  final override func deepCopy() -> Self { Self(deepCopyOf: self) }

  final override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(multiline: self, context)
  }

  final override class var type: NodeType { .multiline }

  final override func selector() -> TargetSelector {
    MultilineNode.selector(isMultline: _isMultline())
  }

  // MARK: - Node(Layout)

  final override var isBlock: Bool { true }

  final override func performLayout(
    _ context: any LayoutContext, fromScratch: Bool
  ) -> Int {
    precondition(context is TextLayoutContext)

    guard _isMultline() else {
      return super.performLayout(context, fromScratch: fromScratch)
    }
    assert(self.columnCount == 1)

    // TODO: Implement multiline layout logic
    return super.performLayout(context, fromScratch: fromScratch)
  }

  // MARK: - Node(Codable)

  private enum CodingKeys: CodingKey { case rows, command }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    let command = try container.decode(String.self, forKey: .command)
    guard let subtype = MathArray.lookup(command) else {
      throw DecodingError.dataCorruptedError(
        forKey: .command, in: container,
        debugDescription: "Invalid matrix command: \(command)")
    }
    let rows = try container.decode(Array<Row>.self, forKey: .rows)
    super.init(subtype, rows)
  }

  final override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(subtype.command, forKey: .command)
    try container.encode(_rows, forKey: .rows)
    try super.encode(to: encoder)
  }

  // MARK: - Node(Storage)

  final override class var storageTags: Array<String> {
    MathArray.blockMathCommands.map(\.command)
  }

  final override class func load(from json: JSONValue) -> NodeLoaded<Node> {
    loadSelf(from: json).cast()
  }

  final override func store() -> JSONValue {
    let rows: Array<JSONValue> = _rows.map { row in
      let children: Array<JSONValue> = row.map { $0.store() }
      return JSONValue.array(children)
    }
    let json = JSONValue.array([.string(subtype.command), .array(rows)])
    return json
  }

  // MARK: - ArrayNode

  final override func getGridIndex(interactingAt point: CGPoint) -> GridIndex? {
    _matrixFragment?.getGridIndex(interactingAt: point, shouldClamp: true)
  }

  // MARK: - Storage

  final class func loadSelf(from json: JSONValue) -> NodeLoaded<MultilineNode> {
    guard case let .array(array) = json,
      array.count == 2,
      case let .string(tag) = array[0],
      let subtype = MathArray.lookup(tag),
      case let .array(rows) = array[1]
    else { return .failure(UnknownNode(json)) }

    let resultRows = NodeStoreUtils.loadRows(rows)
    switch resultRows {
    case .success(let rows):
      let node = Self(subtype, rows)
      return .success(node)
    case .corrupted(let rows):
      let node = Self(subtype, rows)
      return .corrupted(node)
    case .failure:
      return .failure(UnknownNode(json))
    }
  }

  // MARK: - MultilineNode

  override init(_ subtype: MathArray, _ rows: Array<Row>) {
    super.init(subtype, rows)
  }

  init(_ subtype: MathArray, _ rows: Array<Array<Cell>>) {
    let rows = rows.map { Row($0) }
    super.init(subtype, rows)
  }

  private init(deepCopyOf multilineNode: MultilineNode) {
    super.init(deepCopyOf: multilineNode)
  }

  internal static func selector(isMultline: Bool) -> TargetSelector {
    TargetSelector(.multiline, PropertyMatcher(.isMultline, .bool(isMultline)))
  }

  /// Returns true if this node corresponds to a `{multline}` environment.
  private func _isMultline() -> Bool {
    switch subtype.subtype {
    case .multline: return true
    default: return false
    }
  }
}
