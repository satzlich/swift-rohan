// Copyright 2024-2025 Lie Yan

import Foundation

enum NodeSerdeUtils {
  static let registeredNodes: [NodeType: Node.Type] = [
    .apply: ApplyNode.self,
    .argument: ArgumentNode.self,
    .content: ContentNode.self,
    .emphasis: EmphasisNode.self,
    .equation: EquationNode.self,
    .fraction: FractionNode.self,
    .heading: HeadingNode.self,
    .paragraph: ParagraphNode.self,
    .root: RootNode.self,
    .text: TextNode.self,
    .textMode: TextModeNode.self,
    .variable: VariableNode.self,
    .unknown: UnknownNode.self,
  ]

  static func decodeNodes(
    from container: inout UnkeyedDecodingContainer
  ) throws -> ElementNode.BackStore {
    var nodes: ElementNode.BackStore = []
    while !container.isAtEnd {
      nodes.append(try decodeNode(from: &container))
    }
    return nodes
  }

  /** Decode a node from an _unkeyed decoding container_. */
  private static func decodeNode(from container: inout UnkeyedDecodingContainer) throws -> Node {
    var containerCopy = container
    let currentIndex = container.currentIndex
    // peek node type
    guard let nodeContainer = try? containerCopy.nestedContainer(keyedBy: Node.CodingKeys.self),
      let rawValue = try? nodeContainer.decode(NodeType.RawValue.self, forKey: .type)
    else {
      assert(currentIndex == container.currentIndex)
      let decoder = try container.superDecoder()
      let node = try UnknownNode(from: decoder)
      assert(currentIndex + 1 == container.currentIndex)
      return node
    }
    let nodeType = NodeType(rawValue: rawValue) ?? .unknown
    // get node class
    let klass = registeredNodes[nodeType] ?? UnknownNode.self
    // decode node
    assert(currentIndex == container.currentIndex)
    let decoder = try container.superDecoder()
    let node = try klass.init(from: decoder)
    assert(currentIndex + 1 == container.currentIndex)
    return node
  }

  /** Decode a node from json */
  static func decodeNode(from json: Data) throws -> Node {
    let decoder = JSONDecoder()
    return try decoder.decode(WildcardNode.self, from: json).node
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
