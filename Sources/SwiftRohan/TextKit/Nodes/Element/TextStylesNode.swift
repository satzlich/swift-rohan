// Copyright 2024-2025 Lie Yan

import DequeModule
import Foundation

final class TextStylesNode: ElementNodeImpl {
  // MARK: - Node

  final override func deepCopy() -> Self { Self(deepCopyOf: self) }

  final override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(textStyles: self, context)
  }

  final override class var type: NodeType { .textStyles }

  static func selector(command: String) -> TargetSelector {
    TargetSelector(.textStyles, PropertyMatcher(.command, .string(command)))
  }

  final override func selector() -> TargetSelector {
    Self.selector(command: subtype.command)
  }

  final override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      var properties = super.getProperties(styleSheet)
      TextStylesNode.setProperties(&properties, styleSheet, self.subtype)
      _cachedProperties = properties
    }
    return _cachedProperties!
  }

  static func setProperties(
    _ properties: inout PropertyDictionary, _ styleSheet: StyleSheet,
    _ textStyles: TextStyles
  ) {
    switch textStyles {
    case .emph:
      let key = TextProperty.style
      let value = key.resolveValue(properties, styleSheet).fontStyle()!
      properties[key] = .fontStyle(emphasisStyle(for: value))

    case .textbf:
      properties[TextProperty.weight] = .fontWeight(.bold)

    case .textit:
      properties[TextProperty.style] = .fontStyle(.italic)

    case .texttt:
      // this is done with style sheet rules.
      break
    }
  }

  static func emphasisStyle(for fontStyle: FontStyle) -> FontStyle {
    switch fontStyle {
    case .normal: .italic
    case .italic: .normal
    }
  }

  // MARK: - Node(Codable)

  private enum CodingKeys: CodingKey { case command }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let command = try container.decode(String.self, forKey: .command)
    guard let subtype = TextStyles.lookup(command) else {
      throw DecodingError.dataCorruptedError(
        forKey: .command, in: container,
        debugDescription: "Invalid textStyles node command: \(command)")
    }
    self.subtype = subtype
    try super.init(from: decoder)
  }

  final override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(subtype.command, forKey: .command)
    try super.encode(to: encoder)
  }

  // MARK: - Node(Storage)

  final override class var storageTags: Array<String> {
    TextStyles.allCommands.map(\.command)
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
    visitor.visit(textStyles: self, context, withChildren: children)
  }

  final override func cloneEmpty() -> Self { Self(subtype, []) }

  final override func encode<S: Collection<PartialNode> & Encodable>(
    to encoder: any Encoder, withChildren children: S
  ) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(command, forKey: .command)
    try super.encode(to: encoder, withChildren: children)
  }

  // MARK: - Storage

  class func loadSelf(from json: JSONValue) -> NodeLoaded<TextStylesNode> {
    guard case let .array(array) = json,
      array.count == 2,
      case let .string(tag) = array[0],
      let subtype = TextStyles.lookup(tag),
      case let .array(children) = array[1]
    else { return .failure(UnknownNode(json)) }
    let (nodes, corrupted) = NodeStoreUtils.loadChildren(children)
    let result = Self(subtype, nodes)
    return corrupted ? .corrupted(result) : .success(result)
  }

  // MARK: - TextStylesNode

  let subtype: TextStyles

  var command: String { subtype.command }

  init(_ subtype: TextStyles, _ children: ElementStore) {
    self.subtype = subtype
    super.init(children)
  }

  private init(deepCopyOf node: TextStylesNode) {
    self.subtype = node.subtype
    super.init(deepCopyOf: node)
  }

  static var commandRecords: Array<CommandRecord> {
    TextStyles.allCases.map { subtype in
      let expr = TextStylesExpr(subtype, [])
      return CommandRecord(subtype.command, CommandBody(expr, 1))
    }
  }
}
