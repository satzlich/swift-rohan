// Copyright 2024-2025 Lie Yan

import Foundation

final class AlignedNode: ArrayNode {
  override class var type: NodeType { .aligned }

  init(_ rows: Array<ArrayNode.Row>) {
    super.init(.aligned, rows)
  }

  init(deepCopyOf node: AlignedNode) {
    super.init(deepCopyOf: node)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case rows }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let rows = try container.decode([Row].self, forKey: .rows)
    super.init(.aligned, rows)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(_rows, forKey: .rows)
    try super.encode(to: encoder)
  }

  // MARK: - Clone and Visitor

  override func deepCopy() -> AlignedNode { AlignedNode(deepCopyOf: self) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(aligned: self, context)
  }

  private static let uniqueTag = MathArray.aligned.command

  override class var storageTags: [String] {
    [uniqueTag]
  }

  override func store() -> JSONValue {
    let rows: [JSONValue] = _rows.map { row in
      let children: [JSONValue] = row.map { $0.store() }
      return JSONValue.array(children)
    }
    let json = JSONValue.array([.string(Self.uniqueTag), .array(rows)])
    return json
  }

  class func loadSelf(from json: JSONValue) -> _LoadResult<AlignedNode> {
    guard case let .array(array) = json,
      array.count == 2,
      case let .string(tag) = array[0],
      tag == uniqueTag,
      case let .array(rows) = array[1]
    else { return .failure(UnknownNode(json)) }

    let resultRows = NodeStoreUtils.loadRows(rows)
    switch resultRows {
    case .success(let rows):
      let node = Self(rows)
      return .success(node)
    case .corrupted(let rows):
      let node = Self(rows)
      return .corrupted(node)
    case .failure:
      return .failure(UnknownNode(json))
    }
  }

  override class func load(from json: JSONValue) -> Node._LoadResult<Node> {
    loadSelf(from: json).cast()
  }
}
