// Copyright 2024-2025 Lie Yan

import DequeModule
import Foundation

final class HeadingNode: ElementNodeImpl {
  // MARK: - Node
  final override class var type: NodeType { .heading }

  final override func deepCopy() -> Self { Self(deepCopyOf: self) }

  final override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(heading: self, context)
  }

  final override func selector() -> TargetSelector {
    HeadingNode.selector(level: level)
  }

  // MARK: - Node(Codable)

  private enum CodingKeys: CodingKey { case subtype }

  internal required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.subtype = try container.decode(HeadingSubtype.self, forKey: .subtype)
    try super.init(from: decoder)
  }

  final override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.subtype, forKey: .subtype)
    try super.encode(to: encoder)
  }

  // MARK: - Node(Storage)

  final override class var storageTags: Array<String> {
    HeadingSubtype.allCases.map(\.command)
  }

  final override class func load(from json: JSONValue) -> NodeLoaded<Node> {
    loadSelf(from: json).cast()
  }

  final override func store() -> JSONValue {
    let children: Array<JSONValue> = childrenReadonly().map { $0.store() }
    let json = JSONValue.array([.string(subtype.command), .array(children)])
    return json
  }

  // MARK: - ElementNode

  final override func accept<R, C, V: NodeVisitor<R, C>, T: GenNode, S: Collection<T>>(
    _ visitor: V, _ context: C, withChildren children: S
  ) -> R {
    visitor.visit(heading: self, context, withChildren: children)
  }

  final override func createSuccessor() -> ElementNode? { ParagraphNode() }

  final override func cloneEmpty() -> Self { Self(subtype, []) }

  final override func encode<S: Collection<PartialNode> & Encodable>(
    to encoder: any Encoder, withChildren children: S
  ) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(subtype, forKey: .subtype)
    try super.encode(to: encoder, withChildren: children)
  }

  // MARK: - Storage

  final class func loadSelf(from json: JSONValue) -> NodeLoaded<HeadingNode> {
    guard case let .array(array) = json,
      array.count == 2,
      case let .string(tag) = array[0],
      let subtype = HeadingSubtype.fromCommand(tag),
      case let .array(children) = array[1]
    else { return .failure(UnknownNode(json)) }
    let (nodes, corrupted) = NodeStoreUtils.loadChildren(children)
    let result = Self(subtype, nodes)
    return corrupted ? .corrupted(result) : .success(result)
  }

  // MARK: - HeadingNode

  var level: Int { subtype.level }
  let subtype: HeadingSubtype

  init(_ subtype: HeadingSubtype, _ children: ElementStore) {
    self.subtype = subtype
    super.init(children)
  }

  private init(deepCopyOf headingNode: HeadingNode) {
    self.subtype = headingNode.subtype
    super.init(deepCopyOf: headingNode)
  }

  static func selector(level: Int? = nil) -> TargetSelector {
    guard let level else { return TargetSelector(.heading) }
    return TargetSelector(.heading, PropertyMatcher(.level, .integer(level)))
  }

  // MARK: - Command

  var command: String { subtype.command }

  /// Returns a command body for the given heading level.
  static func commandBody(forSubtype subtype: HeadingSubtype) -> CommandBody {
    return CommandBody(HeadingExpr(subtype), 1)
  }

  /// Returns **all** command records emitted by this heading class.
  static let commandRecords: Array<CommandRecord> =
    HeadingSubtype.allCases.map { subtype in
      CommandRecord(subtype.command, commandBody(forSubtype: subtype))
    }
}
