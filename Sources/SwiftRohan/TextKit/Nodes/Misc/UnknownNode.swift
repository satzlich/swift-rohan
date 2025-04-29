// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

private let PLACEHOLDER = "□"

/**
 - Note: This class is meant to represent unknown nodes serialized *with JSON*.
    This is a very important distinction as the class has no means of representing
    mappings with keys as arbitrary values which is possible with the generic
    Codable interface.
 */
public final class UnknownNode: _SimpleNode {
  override class var type: NodeType { .unknown }

  public override init() {
    self.data = .null
    super.init()
  }

  // MARK: - Content

  override final func stringify() -> BigString {
    BigString(PLACEHOLDER)
  }

  // MARK: - Layout

  override func layoutLength() -> Int { PLACEHOLDER.utf16.count }

  override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    context.insertText(PLACEHOLDER, self)
  }

  // MARK: - Clone and Visitor

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(unknown: self, context)
  }

  // MARK: - Codable

  let data: JSONValue

  init(_ data: JSONValue) {
    self.data = data
    super.init()
  }

  public required init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    data = try container.decode(JSONValue.self)
    super.init()
  }

  override public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(data)
    // no need to encode super as it is not a part of the JSON representation
  }
}
