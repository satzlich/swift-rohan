// Copyright 2024-2025 Lie Yan

import DequeModule
import Foundation

/// Load children of element from JSON for given tag.
/// - Returns: Either a list of nodes or an unknown node.
private func loadChildren(
  from json: JSONValue, _ uniqueTag: String
) -> Either<[Node], UnknownNode> {
  guard case let .array(array) = json,
    array.count == 2,
    case let .string(tag) = array[0],
    tag == uniqueTag,
    case let .array(children) = array[1]
  else { return .Right(UnknownNode(json)) }
  let nodes = children.map { NodeStoreUtils.loadNode($0).unwrap() }
  return .Left(nodes)
}

public final class RootNode: ElementNode {
  override class var type: NodeType { .root }

  override public func deepCopy() -> Self { Self(deepCopyOf: self) }
  override func cloneEmpty() -> Self { Self() }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(root: self, context)
  }

  private static let uniqueTag = "document"

  override class var storageTags: [String] {
    [uniqueTag]
  }

  override func store() -> JSONValue {
    let children: [JSONValue] = getChildren_readonly().map { $0.store() }
    let json = JSONValue.array([.string(Self.uniqueTag), .array(children)])
    return json
  }

  override class func load(from json: JSONValue) -> LoadNodeResult {
    let children = loadChildren(from: json, uniqueTag)
    switch children {
    case let .Left(nodes):
      return .success(Self(nodes))
    case let .Right(unknownNode):
      return .unknown(unknownNode)
    }
  }
}

public class ContentNode: ElementNode {
  override final class var type: NodeType { .content }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(content: self, context)
  }

  override public func deepCopy() -> ContentNode { ContentNode(deepCopyOf: self) }
  override func cloneEmpty() -> ContentNode { ContentNode() }

  override class var storageTags: [String] {
    // intentionally empty
    []
  }

  // this is a placeholder, and will be ignored in parsing
  private static let uniqueTag = "yMI2WiDcTK"

  final override func store() -> JSONValue {
    let children: [JSONValue] = getChildren_readonly().map { $0.store() }
    let json = JSONValue.array([.string(Self.uniqueTag), .array(children)])
    return json
  }

  override class func load(from json: JSONValue) -> LoadNodeResult {
    guard case let .array(array) = json,
      array.count == 2,
      case let .string(tag) = array[0],
      // we don't check the tag here
      case let .array(children) = array[1]
    else { return .unknown(UnknownNode(json)) }
    let nodes = children.map { NodeStoreUtils.loadNode($0).unwrap() }
    return .success(ContentNode(nodes))
  }
}

public final class ParagraphNode: ElementNode {
  override class var type: NodeType { .paragraph }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(paragraph: self, context)
  }

  override public func deepCopy() -> Self { Self(deepCopyOf: self) }
  override func cloneEmpty() -> Self { Self() }
  override func createSuccessor() -> ElementNode? { ParagraphNode() }

  private static let uniqueTag = "paragraph"

  override class var storageTags: [String] {
    [uniqueTag]
  }

  override func store() -> JSONValue {
    let children: [JSONValue] = getChildren_readonly().map { $0.store() }
    let json = JSONValue.array([.string(Self.uniqueTag), .array(children)])
    return json
  }

  override class func load(from json: JSONValue) -> LoadNodeResult {
    let children = loadChildren(from: json, uniqueTag)
    switch children {
    case let .Left(nodes):
      return .success(Self(nodes))
    case let .Right(unknownNode):
      return .unknown(unknownNode)
    }
  }
}

public final class HeadingNode: ElementNode {
  override class var type: NodeType { .heading }

  typealias Subtype = HeadingExpr.Subtype

  public let level: Int

  var subtype: Subtype { Subtype(level: level) }

  public init(level: Int, _ children: [Node]) {
    precondition(HeadingExpr.validate(level: level))
    self.level = level
    super.init(Store(children))
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

  override class var storageTags: [String] {
    (1...5).map { "h\($0)" }
  }

  override func store() -> JSONValue {
    let children: [JSONValue] = getChildren_readonly().map { $0.store() }
    let json = JSONValue.array([.string("h\(level)"), .array(children)])
    return json
  }

  override class func load(from json: JSONValue) -> LoadNodeResult {
    let pattern = #/h([1-5])/#

    guard case let .array(array) = json,
      array.count == 2,
      case let .string(tag) = array[0],
      (try? pattern.wholeMatch(in: tag)) != nil,
      let level = Int(tag.dropFirst()),
      case let .array(children) = array[1]
    else { return .unknown(UnknownNode(json)) }
    let childNodes = children.map { NodeStoreUtils.loadNode($0).unwrap() }
    return .success(Self(level: level, childNodes))
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

  override public func selector() -> TargetSelector {
    HeadingNode.selector(level: level)
  }

  public static func selector(level: Int? = nil) -> TargetSelector {
    precondition(level == nil || HeadingExpr.validate(level: level!))
    guard let level else { return TargetSelector(.heading) }
    return TargetSelector(.heading, PropertyMatcher(.level, .integer(level)))
  }
}

public final class EmphasisNode: ElementNode {
  override class var type: NodeType { .emphasis }

  override public func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    func invert(fontStyle: FontStyle) -> FontStyle {
      switch fontStyle {
      case .normal: return .italic
      case .italic: return .normal
      }
    }

    if _cachedProperties == nil {
      // inherit properties
      var properties = super.getProperties(styleSheet)
      // invert font style
      let key = TextProperty.style
      let value = key.resolve(properties, styleSheet.defaultProperties).fontStyle()!
      properties[key] = .fontStyle(invert(fontStyle: value))
      // cache properties
      _cachedProperties = properties
    }
    return _cachedProperties!
  }

  override public func deepCopy() -> Self { Self(deepCopyOf: self) }
  override func cloneEmpty() -> Self { Self() }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(emphasis: self, context)
  }

  private static let uniqueTag = "emph"
  override class var storageTags: [String] {
    [uniqueTag]
  }

  override func store() -> JSONValue {
    let children: [JSONValue] = getChildren_readonly().map { $0.store() }
    let json = JSONValue.array([.string(Self.uniqueTag), .array(children)])
    return json
  }

  override class func load(from json: JSONValue) -> Node.LoadNodeResult {
    let children = loadChildren(from: json, uniqueTag)
    switch children {
    case let .Left(nodes):
      return .success(Self(nodes))
    case let .Right(unknownNode):
      return .unknown(unknownNode)
    }
  }
}

public final class StrongNode: ElementNode {
  override class var type: NodeType { .strong }

  override public func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      // inherit properties
      var properties = super.getProperties(styleSheet)
      // invert font style
      let key = TextProperty.weight
      properties[key] = .fontWeight(.bold)
      // cache properties
      _cachedProperties = properties
    }
    return _cachedProperties!
  }

  override public func deepCopy() -> Self { Self(deepCopyOf: self) }
  override func cloneEmpty() -> Self { Self() }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(strong: self, context)
  }

  private static let uniqueTag = "strong"

  override class var storageTags: [String] {
    [uniqueTag]
  }

  override func store() -> JSONValue {
    let children: [JSONValue] = getChildren_readonly().map { $0.store() }
    let json = JSONValue.array([.string(Self.uniqueTag), .array(children)])
    return json
  }

  override class func load(from json: JSONValue) -> Node.LoadNodeResult {
    let children = loadChildren(from: json, uniqueTag)
    switch children {
    case let .Left(nodes):
      return .success(Self(nodes))
    case let .Right(unknownNode):
      return .unknown(unknownNode)
    }
  }
}
