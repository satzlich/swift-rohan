// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

final class OverspreaderNode: _UnderOverspreaderNode {
  override class var type: NodeType { .overspreader }

  override init(_ spreader: MathSpreader, _ nucleus: [Node]) {
    super.init(spreader, nucleus)
  }

  init(_ spreader: MathSpreader, _ nucleus: CrampedNode) {
    super.init(spreader, nucleus)
  }

  init(deepCopyOf node: OverspreaderNode) {
    super.init(deepCopyOf: node)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case spreader, nuc }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let spreader = try container.decode(MathSpreader.self, forKey: .spreader)
    let nucleus = try container.decode(CrampedNode.self, forKey: .nuc)
    super.init(spreader, nucleus)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(spreader, forKey: .spreader)
    try container.encode(nucleus, forKey: .nuc)
    try super.encode(to: encoder)
  }

  // MARK: - Clone and Visitor

  override func deepCopy() -> Node { Self(deepCopyOf: self) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(overspreader: self, context)
  }

  override class var storageTags: [String] {
    MathSpreader.overCases.map { $0.command }
  }

  override func store() -> JSONValue {
    let nucleus = nucleus.store()
    let json = JSONValue.array([.string(spreader.command), nucleus])
    return json
  }

  class func loadSelf(from json: JSONValue) -> _LoadResult<OverspreaderNode> {
    guard case let .array(array) = json,
      array.count == 2,
      case let .string(command) = array[0],
      let spreader = MathSpreader.lookup(command)
    else { return .failure(UnknownNode(json)) }
    let nucleus = CrampedNode.loadSelf(from: array[1])
    switch nucleus {
    case .success(let node):
      return .success(Self(spreader, node))
    case .corrupted(let node):
      return .corrupted(Self(spreader, node))
    case .failure:
      return .failure(UnknownNode(json))
    }
  }

  override class func load(from json: JSONValue) -> _LoadResult<Node> {
    loadSelf(from: json).cast()
  }
}
