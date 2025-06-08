// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

private let PLACEHOLDER = "[Unknown Node]"

/**
 - Note: This class is meant to represent unknown nodes serialized *with JSON*.
    This is a very important distinction as the class has no means of representing
    mappings with keys as arbitrary values which is possible with the generic
    Codable interface.
 */
final class UnknownNode: SimpleNode {
  // MARK: - Node

  public override init() {
    self.data = .null
    super.init()
  }

  final override func deepCopy() -> Self { Self(data) }

  final override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(unknown: self, context)
  }

  final override class var type: NodeType { .unknown }

  final override func layoutLength() -> Int { PLACEHOLDER.length }

  // MARK: - Node(Codable)

  required init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    data = try container.decode(JSONValue.self)
    super.init()
  }

  final override func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(data)
    // NB: no need to encode super as it is not a part of the JSON representation
  }

  // MARK: - UnknownNode

  var placeholder: String { PLACEHOLDER }

  override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    context.insertText(PLACEHOLDER, self)
  }

  override class var storageTags: [String] {
    // intentionally empty
    []
  }

  let data: JSONValue

  init(_ data: JSONValue) {
    self.data = data
    super.init()
  }

  override func store() -> JSONValue { data }
}
