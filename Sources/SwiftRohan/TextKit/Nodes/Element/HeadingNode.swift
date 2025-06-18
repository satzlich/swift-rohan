// Copyright 2024-2025 Lie Yan

import DequeModule
import Foundation

final class HeadingNode: ElementNode {
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

  private enum CodingKeys: CodingKey { case level }

  internal required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.level = try container.decode(Int.self, forKey: .level)
    try super.init(from: decoder)
  }

  final override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.level, forKey: .level)
    try super.encode(to: encoder)
  }

  // MARK: - Node(Storage)

  final override class var storageTags: Array<String> { (1...5).map { "h\($0)" } }

  final override class func load(from json: JSONValue) -> NodeLoaded<Node> {
    loadSelf(from: json).cast()
  }

  final override func store() -> JSONValue {
    let children: Array<JSONValue> = childrenReadonly().map { $0.store() }
    let json = JSONValue.array([.string("h\(level)"), .array(children)])
    return json
  }

  // MARK: - ElementNode

  final override func accept<R, C, V: NodeVisitor<R, C>, T: GenNode, S: Collection<T>>(
    _ visitor: V, _ context: C, withChildren children: S
  ) -> R {
    visitor.visit(heading: self, context, withChildren: children)
  }

  final override func createSuccessor() -> ElementNode? {
    /* create "paragraph" */
    ParagraphNode()
  }

  final override func cloneEmpty() -> Self { Self(level: level, []) }

  final override func encode<S: Collection<PartialNode> & Encodable>(
    to encoder: any Encoder, withChildren children: S
  ) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(level, forKey: .level)
    try super.encode(to: encoder, withChildren: children)
  }

  // MARK: - Storage

  final class func loadSelf(from json: JSONValue) -> NodeLoaded<HeadingNode> {
    guard case let .array(array) = json,
      array.count == 2,
      case let .string(tag) = array[0],
      (try? #/h([1-5])/#.wholeMatch(in: tag)) != nil,
      let level = Int(tag.dropFirst()),
      case let .array(children) = array[1]
    else { return .failure(UnknownNode(json)) }
    let (nodes, corrupted) = NodeStoreUtils.loadChildren(children)
    let result = Self(level: level, nodes)
    return corrupted ? .corrupted(result) : .success(result)
  }

  // MARK: - HeadingNode

  typealias Subtype = HeadingExpr.Subtype

  let level: Int
  var subtype: Subtype { Subtype(level: level) }

  init(level: Int, _ children: ElementStore) {
    precondition(HeadingExpr.validate(level: level))
    self.level = level
    super.init(children)
  }

  private init(deepCopyOf headingNode: HeadingNode) {
    self.level = headingNode.level
    super.init(deepCopyOf: headingNode)
  }

  static func selector(level: Int? = nil) -> TargetSelector {
    precondition(level == nil || HeadingExpr.validate(level: level!))
    guard let level else { return TargetSelector(.heading) }
    return TargetSelector(.heading, PropertyMatcher(.level, .integer(level)))
  }

  // MARK: - Command

  var command: String? { Self._command(forLevel: level) }

  private static func _command(forLevel level: Int) -> String? {
    switch level {
    case 1: return "section*"
    case 2: return "subsection*"
    case 3: return "subsubsection*"
    case 4: return nil
    case 5: return nil
    default: return nil
    }
  }

  /// Returns a command body for the given heading level.
  static func commandBody(forLevel: Int) -> CommandBody {
    precondition(HeadingExpr.validate(level: forLevel))
    return CommandBody(HeadingExpr(level: forLevel), 1)
  }

  /// Returns **all** command records emitted by this heading class.
  static var commandRecords: Array<CommandRecord> {
    var records: Array<CommandRecord> = []
    records.reserveCapacity(5)
    for level in 1...5 {
      guard let command = _command(forLevel: level) else { continue }
      records.append(CommandRecord(command, commandBody(forLevel: level)))
    }
    return records
  }
}
