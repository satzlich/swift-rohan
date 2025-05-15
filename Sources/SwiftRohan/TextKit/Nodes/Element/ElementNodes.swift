// Copyright 2024-2025 Lie Yan

import DequeModule
import Foundation

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

  final class func loadSelf(from json: JSONValue) -> _LoadResult<RootNode> {
    guard let children = NodeStoreUtils.takeChildrenArray(json, uniqueTag)
    else { return .failure(UnknownNode(json)) }
    let (nodes, corrupted) = NodeStoreUtils.loadChildren(children)
    let result = Self(nodes)
    return corrupted ? .corrupted(result) : .success(result)
  }

  override class func load(from json: JSONValue) -> _LoadResult<Node> {
    loadSelf(from: json).cast()
  }
}

public class ContentNode: ElementNode {
  override final class var type: NodeType { .content }

  required init() {
    super.init()
  }

  required override init(_ children: [Node]) {
    super.init(Store(children))
  }

  required override init(_ children: ElementNode.Store) {
    super.init(children)
  }

  required init(deepCopyOf node: ContentNode) {
    super.init(deepCopyOf: node)
  }

  public required init(from decoder: any Decoder) throws {
    try super.init(from: decoder)
  }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(content: self, context)
  }

  final override public func deepCopy() -> Self { Self(deepCopyOf: self) }

  final override func cloneEmpty() -> Self { Self() }

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

  final class func loadSelfGeneric<T: ContentNode>(from json: JSONValue) -> _LoadResult<T>
  {
    guard case let .array(array) = json,
      array.count == 2,
      case .string(_) = array[0],
      // we don't check the tag here
      case let .array(children) = array[1]
    else { return .failure(UnknownNode(json)) }
    let (nodes, corrupted) = NodeStoreUtils.loadChildren(children)
    let result = T(nodes)
    return corrupted ? .corrupted(result) : .success(result)
  }

  final override class func load(from json: JSONValue) -> _LoadResult<Node> {
    (loadSelfGeneric(from: json) as _LoadResult<Self>).cast()
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

  final class func loadSelf(from json: JSONValue) -> _LoadResult<ParagraphNode> {
    guard let children = NodeStoreUtils.takeChildrenArray(json, uniqueTag)
    else { return .failure(UnknownNode(json)) }
    let (nodes, corrupted) = NodeStoreUtils.loadChildren(children)
    let result = Self(nodes)
    return corrupted ? .corrupted(result) : .success(result)
  }

  override class func load(from json: JSONValue) -> _LoadResult<Node> {
    loadSelf(from: json).cast()
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

  class func loadSelf(from json: JSONValue) -> _LoadResult<EmphasisNode> {
    guard let children = NodeStoreUtils.takeChildrenArray(json, uniqueTag)
    else { return .failure(UnknownNode(json)) }
    let (nodes, corrupted) = NodeStoreUtils.loadChildren(children)
    let result = Self(nodes)
    return corrupted ? .corrupted(result) : .success(result)
  }

  override class func load(from json: JSONValue) -> Node._LoadResult<Node> {
    loadSelf(from: json).cast()
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

  class func loadSelf(from json: JSONValue) -> _LoadResult<StrongNode> {
    guard let children = NodeStoreUtils.takeChildrenArray(json, uniqueTag)
    else { return .failure(UnknownNode(json)) }
    let (nodes, corrupted) = NodeStoreUtils.loadChildren(children)
    let result = Self(nodes)
    return corrupted ? .corrupted(result) : .success(result)
  }

  override class func load(from json: JSONValue) -> _LoadResult<Node> {
    loadSelf(from: json).cast()
  }
}
