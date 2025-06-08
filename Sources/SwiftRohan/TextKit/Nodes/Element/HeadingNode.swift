// Copyright 2024-2025 Lie Yan

import DequeModule
import Foundation

final class HeadingNode: ElementNode {
  // MARK: - Node

  final override func deepCopy() -> Self { Self(deepCopyOf: self) }

  final override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(heading: self, context)
  }

  final override class var type: NodeType { .heading }

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

  final override class func load(from json: JSONValue) -> _LoadResult<Node> {
    loadSelf(from: json).cast()
  }

  final override func store() -> JSONValue {
    let children: [JSONValue] = getChildren_readonly().map { $0.store() }
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

  final class func loadSelf(from json: JSONValue) -> _LoadResult<HeadingNode> {
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

  public let level: Int

  var subtype: Subtype { Subtype(level: level) }

  init(level: Int, _ children: [Node]) {
    precondition(HeadingExpr.validate(level: level))
    self.level = level
    super.init(ElementStore(children))
  }

  public init(level: Int, _ children: ElementStore) {
    precondition(HeadingExpr.validate(level: level))
    self.level = level
    super.init(children)
  }

  private init(deepCopyOf headingNode: HeadingNode) {
    self.level = headingNode.level
    super.init(deepCopyOf: headingNode)
  }

  var command: String? {
    switch level {
    case 1: return "section*"
    case 2: return "subsection*"
    case 3: return "subsubsection*"
    case 4: return nil
    case 5: return nil
    default: return nil
    }
  }

  public static func selector(level: Int? = nil) -> TargetSelector {
    precondition(level == nil || HeadingExpr.validate(level: level!))
    guard let level else { return TargetSelector(.heading) }
    return TargetSelector(.heading, PropertyMatcher(.level, .integer(level)))
  }
}
