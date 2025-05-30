// Copyright 2024-2025 Lie Yan

import Foundation

enum NodeSerdeUtils {
  static let registeredNodes: [NodeType: Node.Type] = [
    .linebreak: LinebreakNode.self,
    .text: TextNode.self,
    .unknown: UnknownNode.self,
    // template
    .apply: ApplyNode.self,
    .argument: ArgumentNode.self,
    .variable: VariableNode.self,
    // element
    .content: ContentNode.self,
    .emphasis: EmphasisNode.self,
    .heading: HeadingNode.self,
    .paragraph: ParagraphNode.self,
    .root: RootNode.self,
    .strong: StrongNode.self,
    .textMode: TextModeNode.self,
    // math
    .accent: AccentNode.self,
    .attach: AttachNode.self,
    .equation: EquationNode.self,
    .fraction: FractionNode.self,
    .leftRight: LeftRightNode.self,
    .mathAttributes: MathAttributesNode.self,
    .mathExpression: MathExpressionNode.self,
    .mathOperator: MathOperatorNode.self,
    .namedSymbol: NamedSymbolNode.self,
    .mathVariant: MathVariantNode.self,
    .matrix: MatrixNode.self,
    .overspreader: OverspreaderNode.self,
    .radical: RadicalNode.self,
    .underspreader: UnderspreaderNode.self,
  ]

  static func decodeListOfListsOfNodes<Store, NestedStore>(
    from container: inout UnkeyedDecodingContainer
  ) throws -> Store
  where
    Store: RangeReplaceableCollection, Store.Element == NestedStore,
    NestedStore: RangeReplaceableCollection, NestedStore.Element == Node
  {
    var store: Store = .init()
    if let count = container.count {
      store.reserveCapacity(count)
    }
    while !container.isAtEnd {
      let currentIndex = container.currentIndex
      var nestedContainer = try container.nestedUnkeyedContainer()
      store.append(try decodeListOfNodes(from: &nestedContainer))
      assert(currentIndex + 1 == container.currentIndex)
    }
    return store
  }

  static func decodeListOfNodes<Store>(
    from container: inout UnkeyedDecodingContainer
  ) throws -> Store
  where Store: RangeReplaceableCollection, Store.Element == Node {
    var store: Store = .init()
    if let count = container.count {
      store.reserveCapacity(count)
    }
    while !container.isAtEnd {
      store.append(try decodeNode(from: &container))
    }
    return store
  }

  /// Decode a node from an _unkeyed decoding container_.
  private static func decodeNode(
    from container: inout UnkeyedDecodingContainer
  ) throws -> Node {
    let currentIndex = container.currentIndex
    // peek node type
    var containerCopy = container  // use copy to peek
    guard
      let nodeContainer = try? containerCopy.nestedContainer(
        keyedBy: Node.CodingKeys.self),
      let rawValue = try? nodeContainer.decode(NodeType.RawValue.self, forKey: .type)
    else {
      assert(currentIndex == container.currentIndex)
      let node = try UnknownNode(from: try container.superDecoder())
      assert(currentIndex + 1 == container.currentIndex)
      return node
    }
    let nodeType = NodeType(rawValue: rawValue) ?? .unknown
    // get node class
    let klass = registeredNodes[nodeType] ?? UnknownNode.self
    // decode node
    assert(currentIndex == container.currentIndex)
    let node = try klass.init(from: try container.superDecoder())
    assert(currentIndex + 1 == container.currentIndex)
    return node
  }

  /// Decode a node from json.
  static func decodeNode(from json: Data) throws -> Node {
    try JSONDecoder().decode(WildcardNode.self, from: json).node
  }

  /// Decode a list of nodes from json.
  static func decodeListOfNodes<Store>(from json: Data) throws -> Store
  where
    Store: RangeReplaceableCollection, Store.Element == Node,
    Store: Decodable
  {
    try JSONDecoder().decode(ListOfNodes<Store>.self, from: json).store
  }

  /// Decode a list of lists of nodes from json.
  static func decodeListOfListsOfNodes<Store, NestedStore>(
    from json: Data
  ) throws -> Store
  where
    Store: RangeReplaceableCollection, Store.Element == NestedStore,
    NestedStore: RangeReplaceableCollection, NestedStore.Element == Node,
    Store: Decodable, NestedStore: Decodable
  {
    try JSONDecoder().decode(ListOfListsOfNodes<Store, NestedStore>.self, from: json)
      .store
  }
}

private struct WildcardNode: Decodable {
  let node: Node

  init(from decoder: any Decoder) throws {
    guard let container = try? decoder.container(keyedBy: Node.CodingKeys.self),
      let rawValue = try? container.decode(NodeType.RawValue.self, forKey: .type)
    else {
      node = try UnknownNode(from: decoder)
      return
    }
    let nodeType = NodeType(rawValue: rawValue) ?? .unknown
    // get node class
    let klass = NodeSerdeUtils.registeredNodes[nodeType] ?? UnknownNode.self
    // decode node
    node = try klass.init(from: decoder)
  }
}

private struct ListOfNodes<Store>: Decodable
where
  Store: RangeReplaceableCollection, Store.Element == Node,
  Store: Decodable
{
  let store: Store

  init(from decoder: any Decoder) throws {
    var container = try decoder.unkeyedContainer()
    store = try NodeSerdeUtils.decodeListOfNodes(from: &container)
  }
}

private struct ListOfListsOfNodes<Store, NestedStore>: Decodable
where
  Store: RangeReplaceableCollection, Store.Element == NestedStore,
  NestedStore: RangeReplaceableCollection, NestedStore.Element == Node,
  Store: Decodable, NestedStore: Decodable
{
  let store: Store

  init(from decoder: any Decoder) throws {
    var container = try decoder.unkeyedContainer()
    store = try NodeSerdeUtils.decodeListOfListsOfNodes(from: &container)
  }
}
