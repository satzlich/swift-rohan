// Copyright 2024-2025 Lie Yan

import Foundation

final class MatrixNode: ArrayNode {
  // MARK: - Node
  final override func deepCopy() -> Self { Self(deepCopyOf: self) }

  final override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(matrix: self, context)
  }

  final override class var type: NodeType { .matrix }

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
    let rows = try container.decode([Row].self, forKey: .rows)
    super.init(subtype, rows)
  }

  final override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(subtype.command, forKey: .command)
    try container.encode(_rows, forKey: .rows)
    try super.encode(to: encoder)
  }

  // MARK: - MatrixNode

  override init(_ subtype: MathArray, _ rows: Array<ArrayNode.Row>) {
    super.init(subtype, rows)
  }

  init(_ subtype: MathArray, _ rows: Array<Array<Cell>>) {
    let rows = rows.map { Row($0) }
    super.init(subtype, rows)
  }

  private init(deepCopyOf matrixNode: MatrixNode) {
    super.init(deepCopyOf: matrixNode)
  }

  // MARK: - Clone and Visitor

  override class var storageTags: [String] {
    MathArray.allCommands.map { $0.command }
  }

  override func store() -> JSONValue {
    let rows: [JSONValue] = _rows.map { row in
      let children: [JSONValue] = row.map { $0.store() }
      return JSONValue.array(children)
    }
    let json = JSONValue.array([.string(subtype.command), .array(rows)])
    return json
  }

  class func loadSelf(from json: JSONValue) -> _LoadResult<MatrixNode> {
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

  override class func load(from json: JSONValue) -> _LoadResult<Node> {
    loadSelf(from: json).cast()
  }
}
