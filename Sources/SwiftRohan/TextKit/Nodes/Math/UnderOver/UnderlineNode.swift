// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

final class UnderlineNode: _UnderOverlineNode {
  override class var type: NodeType { .underline }

  init(_ nucleus: [Node]) {
    super.init(.under, nucleus)
  }

  init(_ nucleus: ContentNode) {
    super.init(.under, nucleus)
  }

  init(deepCopyOf node: UnderlineNode) {
    super.init(deepCopyOf: node)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case nuc }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    // nucleus is un-cramped
    let nucleus = try container.decode(ContentNode.self, forKey: .nuc)
    super.init(.under, nucleus)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(_nucleus, forKey: .nuc)
    try super.encode(to: encoder)
  }

  // MARK: - Clone and Visitor

  override func deepCopy() -> Self { Self(deepCopyOf: self) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(underline: self, context)
  }

  private static let uniqueTag: String = "underline"

  override class var storageTags: [String] {
    [uniqueTag]
  }

  override func store() -> JSONValue {
    let nuclues = nucleus.store()
    let json = JSONValue.array([.string(Self.uniqueTag), nuclues])
    return json
  }

  class func loadSelf(from json: JSONValue) -> _LoadResult<UnderlineNode> {
    guard case let .array(array) = json,
      array.count == 2,
      case let .string(tag) = array[0],
      let spreader = MathSpreader.lookup(tag)
    else { return .failure(UnknownNode(json)) }

    let nucleus = ContentNode.load(from: array[1])
    switch nucleus {
    case let .success(nucleus):
      guard let nucleus = nucleus as? ContentNode
      else { return .failure(UnknownNode(json)) }
      return .success(UnderlineNode(nucleus))

    case let .corrupted(nucleus):
      guard let nucleus = nucleus as? ContentNode
      else { return .failure(UnknownNode(json)) }
      return .corrupted(UnderlineNode(nucleus))

    case .failure:
      return .failure(UnknownNode(json))
    }
  }
  
  override class func load(from json: JSONValue) -> _LoadResult<Node> {
    loadSelf(from: json).cast()
  }
}
