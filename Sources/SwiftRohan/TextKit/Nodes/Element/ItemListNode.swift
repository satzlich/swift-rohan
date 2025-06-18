// Copyright 2024-2025 Lie Yan

import AppKit

enum ItemListSubtype: String, Codable, CaseIterable {
  case itemize
  case enumerate

  var command: String { rawValue }
}

final class ItemListNode: ElementNode {
  final override class var type: NodeType { .itemList }

  final override func deepCopy() -> Self { Self(deepCopyOf: self) }

  final override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(itemList: self, context)
  }

  final override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    switch subtype {
    case .itemize: return _getProperties(styleSheet, itemize: ())
    case .enumerate: return _getProperties(styleSheet, enumerate: ())
    }
  }

  private final func _getProperties(
    _ styleSheet: StyleSheet, itemize: Void
  ) -> PropertyDictionary {
    super.getProperties(styleSheet)
  }

  private final func _getProperties(
    _ styleSheet: StyleSheet, enumerate: Void
  ) -> PropertyDictionary {
    super.getProperties(styleSheet)
  }

  // MARK: - Node(Codable)

  private enum CodingKeys: String, CodingKey { case subtype }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.subtype = try container.decode(ItemListSubtype.self, forKey: .subtype)
    self._textList = Self._textList(forSubtype: subtype)
    try super.init(from: decoder)
  }

  final override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(subtype, forKey: .subtype)
    try super.encode(to: encoder)
  }

  // MARK: - Node(Storage)

  final override class var storageTags: Array<String> {
    ItemListSubtype.allCases.map(\.rawValue)
  }

  final override class func load(from json: JSONValue) -> NodeLoaded<Node> {
    loadSelf(from: json).cast()
  }

  final override func store() -> JSONValue {
    let children: Array<JSONValue> = childrenReadonly().map { $0.store() }
    let json = JSONValue.array([.string(subtype.rawValue), .array(children)])
    return json
  }

  // MARK: - ElementNode

  final override func accept<R, C, V: NodeVisitor<R, C>, T: GenNode, S: Collection<T>>(
    _ visitor: V, _ context: C, withChildren children: S
  ) -> R {
    visitor.visit(itemList: self, context, withChildren: children)
  }

  final override func cloneEmpty() -> Self { Self(subtype, []) }

  final override func encode<S: Collection<PartialNode>>(
    to encoder: any Encoder, withChildren children: S
  ) throws where S: Encodable {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(subtype, forKey: .subtype)
    try super.encode(to: encoder, withChildren: children)
  }

  // MARK: - Storage

  final class func loadSelf(from json: JSONValue) -> NodeLoaded<ItemListNode> {
    guard case let .array(array) = json,
      array.count == 2,
      case let .string(tag) = array[0],
      let subtype = ItemListSubtype(rawValue: tag),
      case let .array(children) = array[1]
    else { return .failure(UnknownNode(json)) }
    let (nodes, corrupted) = NodeStoreUtils.loadChildren(children)
    let result = Self(subtype, nodes)
    return corrupted ? .corrupted(result) : .success(result)
  }

  // MARK: - ItemListNode

  let subtype: ItemListSubtype
  private var _textList: NSTextList

  init(_ subtype: ItemListSubtype, _ children: ElementStore) {
    self.subtype = subtype
    self._textList = Self._textList(forSubtype: subtype)
    super.init(children)
  }

  private init(deepCopyOf node: ItemListNode) {
    self.subtype = node.subtype
    self._textList = Self._textList(forSubtype: subtype)
    super.init(deepCopyOf: node)
  }

  private static func _textList(forSubtype subtype: ItemListSubtype) -> NSTextList {
    switch subtype {
    case .itemize:
      return NSTextList(markerFormat: .disc, options: 0)
    case .enumerate:
      return NSTextList(markerFormat: .decimal, startingItemNumber: 1)
    }
  }

  static var commandRecords: Array<CommandRecord> {
    ItemListSubtype.allCases.map { subtype in
      let expr = ItemListExpr(subtype)
      return CommandRecord(subtype.command, CommandBody(expr, 1))
    }
  }
}
