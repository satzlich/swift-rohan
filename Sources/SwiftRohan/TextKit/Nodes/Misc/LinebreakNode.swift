// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

final class LinebreakNode: SimpleNode {
  // MARK: - Node

  override init() { super.init() }

  final override func deepCopy() -> Self { Self() }

  final override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(linebreak: self, context)
  }

  final override class var type: NodeType { .linebreak }

  final override func layoutLength() -> Int { 1 }

  // MARK: - Node(Codable)

  required init(from decoder: any Decoder) throws {
    try super.init(from: decoder)
  }

  // MARK: - Node(Storage)

  private static let uniqueTag = "linebreak"

  final override class var storageTags: Array<String> { [uniqueTag] }

  final override class func load(from json: JSONValue) -> _LoadResult<Node> {
    loadSelf(from: json).cast()
  }

  final override func store() -> JSONValue {
    let json = JSONValue.array([.string(Self.uniqueTag)])
    return json
  }

  // MARK: - LinebreakNode

  override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    context.insertText("\n", self)
  }

  // MARK: - Clone and Visitor

  class func loadSelf(from json: JSONValue) -> _LoadResult<LinebreakNode> {
    guard case let .array(array) = json,
      array.count == 1,
      case let .string(tag) = array[0],
      tag == uniqueTag
    else {
      return .failure(UnknownNode(json))
    }
    return .success(LinebreakNode())
  }
}
