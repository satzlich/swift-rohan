// Copyright 2024-2025 Lie Yan

import DequeModule
import Foundation

public final class HeadingNode: ElementNode {
  override class var type: NodeType { .heading }

  override public func selector() -> TargetSelector {
    HeadingNode.selector(level: level)
  }

  typealias Subtype = HeadingExpr.Subtype

  public let level: Int

  var subtype: Subtype { Subtype(level: level) }

  public init(level: Int, _ children: [Node]) {
    precondition(HeadingExpr.validate(level: level))
    self.level = level
    super.init(Store(children))
  }

  public init(level: Int, _ children: ElementNode.Store) {
    precondition(HeadingExpr.validate(level: level))
    self.level = level
    super.init(children)
  }

  internal init(deepCopyOf headingNode: HeadingNode) {
    self.level = headingNode.level
    super.init(deepCopyOf: headingNode)
  }

  override public func deepCopy() -> Self { Self(deepCopyOf: self) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(heading: self, context)
  }

  override func accept<R, C, V, T, S>(
    _ visitor: V, _ context: C, withChildren children: S
  ) -> R where V: NodeVisitor<R, C>, T: GenNode, T == S.Element, S: Collection {
    visitor.visit(heading: self, context, withChildren: children)
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

  override class var storageTags: [String] {
    (1...5).map { "h\($0)" }
  }

  override func store() -> JSONValue {
    let children: [JSONValue] = getChildren_readonly().map { $0.store() }
    let json = JSONValue.array([.string("h\(level)"), .array(children)])
    return json
  }

  class func loadSelf(from json: JSONValue) -> _LoadResult<HeadingNode> {
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

  override class func load(from json: JSONValue) -> Node._LoadResult<Node> {
    loadSelf(from: json).cast()
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case level }

  public required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    level = try container.decode(Int.self, forKey: .level)
    try super.init(from: decoder)
  }

  public override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(level, forKey: .level)
    try super.encode(to: encoder)
  }

  internal override func encode<S: Collection<PartialNode>>(
    to encoder: any Encoder, withChildren children: S
  ) throws where S: Encodable {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(level, forKey: .level)
    try super.encode(to: encoder, withChildren: children)
  }

  // MARK: - Content

  override func cloneEmpty() -> Self { Self(level: level, []) }
  override func createSuccessor() -> ElementNode? { ParagraphNode() }

  // MARK: - Styles

  public static func selector(level: Int? = nil) -> TargetSelector {
    precondition(level == nil || HeadingExpr.validate(level: level!))
    guard let level else { return TargetSelector(.heading) }
    return TargetSelector(.heading, PropertyMatcher(.level, .integer(level)))
  }
}
