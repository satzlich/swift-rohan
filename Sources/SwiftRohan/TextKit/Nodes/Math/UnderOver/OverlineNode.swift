//// Copyright 2024-2025 Lie Yan
//
//import Foundation
//import _RopeModule
//
//final class OverlineNode: _UnderOverlineNode {
//  override class var type: NodeType { .overline }
//
//  init(_ nucleus: [Node]) {
//    super.init(.over, nucleus)
//  }
//
//  init(_ nucleus: CrampedNode) {
//    super.init(.over, nucleus)
//  }
//
//  init(deepCopyOf node: OverlineNode) {
//    super.init(deepCopyOf: node)
//  }
//
//  // MARK: - Codable
//
//  private enum CodingKeys: CodingKey { case nuc }
//
//  required init(from decoder: any Decoder) throws {
//    let container = try decoder.container(keyedBy: CodingKeys.self)
//    let nucleus = try container.decode(CrampedNode.self, forKey: .nuc)
//    super.init(.over, nucleus)
//  }
//
//  override func encode(to encoder: any Encoder) throws {
//    var container = encoder.container(keyedBy: CodingKeys.self)
//    try container.encode(_nucleus, forKey: .nuc)
//    try super.encode(to: encoder)
//  }
//
//  // MARK: - Clone and Visitor
//
//  override func deepCopy() -> Self { Self(deepCopyOf: self) }
//
//  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
//  where V: NodeVisitor<R, C> {
//    visitor.visit(overline: self, context)
//  }
//
//  private static let uniqueTag = "overline"
//
//  var command: String { Self.uniqueTag }
//
//  override class var storageTags: [String] {
//    [uniqueTag]
//  }
//
//  override func store() -> JSONValue {
//    let nucleus = _nucleus.store()
//    let json = JSONValue.array([.string(Self.uniqueTag), nucleus])
//    return json
//  }
//
//  class func loadSelf(from json: JSONValue) -> _LoadResult<OverlineNode> {
//    guard case let .array(array) = json,
//      array.count == 2,
//      case let .string(tag) = array[0],
//      tag == uniqueTag
//    else {
//      return .failure(UnknownNode(json))
//    }
//
//    let nucleus = CrampedNode.loadSelf(from: array[1]) as _LoadResult<CrampedNode>
//
//    switch nucleus {
//    case .success(let node):
//      return .success(OverlineNode(node))
//    case .corrupted(let node):
//      return .corrupted(OverlineNode(node))
//    case .failure:
//      return .failure(UnknownNode(json))
//    }
//  }
//
//  override class func load(from json: JSONValue) -> Node._LoadResult<Node> {
//    loadSelf(from: json).cast()
//  }
//}
