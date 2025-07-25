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

  // MARK: - Node(Layout)

  final override func layoutLength() -> Int { PLACEHOLDER.length }

  final override func performLayout(
    _ context: any LayoutContext, fromScratch: Bool, atBlockEdge: Bool
  ) -> Int {
    if fromScratch {
      context.insertText(PLACEHOLDER, self)
    }
    else {
      assertionFailure("UnknownNode should not be laid out again")
    }
    return layoutLength()
  }

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

  // MARK: - Node(Storage)

  final override class var storageTags: Array<String> { /* intentionally empty */ [] }

  final override class func load(from json: JSONValue) -> NodeLoaded<Node> {
    assertionFailure("should not be called")
    return .failure(UnknownNode(json))
  }

  final override func store() -> JSONValue { data }

  // MARK: - UnknownNode

  var placeholder: String { PLACEHOLDER }
  let data: JSONValue

  init(_ data: JSONValue) {
    self.data = data
    super.init()
  }
}
