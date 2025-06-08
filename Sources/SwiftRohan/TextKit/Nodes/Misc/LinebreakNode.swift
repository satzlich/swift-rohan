// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

final class LinebreakNode: SimpleNode {
  // MARK: - Node
  override init() { super.init() }

  override class var type: NodeType { .linebreak }

  override func layoutLength() -> Int { 1 }

  // MARK: - LinebreakNode

  required init(from decoder: any Decoder) throws {
    try super.init(from: decoder)
  }

  // MARK: - Layout

  override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    context.insertText("\n", self)
  }

  // MARK: - Clone and Visitor

  override func deepCopy() -> LinebreakNode { LinebreakNode() }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(linebreak: self, context)
  }

  private static let uniqueTag = "linebreak"

  override class var storageTags: [String] {
    [uniqueTag]
  }

  override func store() -> JSONValue {
    let json = JSONValue.array([.string(Self.uniqueTag)])
    return json
  }

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

  override class func load(from json: JSONValue) -> _LoadResult<Node> {
    loadSelf(from: json).cast()
  }
}
