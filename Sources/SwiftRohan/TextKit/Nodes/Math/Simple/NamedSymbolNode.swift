// Copyright 2024-2025 Lie Yan

import Foundation

final class NamedSymbolNode: SimpleNode {
  // MARK: - Node

  final override func deepCopy() -> Self { Self(namedSymbol) }

  final override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(namedSymbol: self, context)
  }

  final override class var type: NodeType { .namedSymbol }

  // MARK: - Node(Layout)

  final override func layoutLength() -> Int { namedSymbol.string.length }

  final override func performLayoutForward(
    _ context: any LayoutContext, fromScratch: Bool
  ) -> Int {
    switch context {
    case let context as MathListLayoutContext:
      if fromScratch {
        if namedSymbol.string.count <= 1 {
          context.insertText(namedSymbol.string, self)
        }
        else {
          let fragments = context.getFragments(for: namedSymbol.string, self)
          let composite = FragmentCompositeFragment(fragments)
          let fragment = MathFragmentWrapper(composite, layoutLength())
          context.insertFragment(fragment, self)
        }
      }
      else {
        assertionFailure("theoretically we should not reach here")
        context.skipForward(layoutLength())
      }

    default:
      if fromScratch {
        context.insertText(String(namedSymbol.string), self)
      }
      else {
        assertionFailure("theoretically we should not reach here")
        context.skipForward(layoutLength())
      }
    }

    return layoutLength()
  }

  // MARK: - Node(Codable)

  private enum CodingKeys: CodingKey { case command }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let command = try container.decode(String.self, forKey: .command)
    guard let symbol = NamedSymbol.lookup(command) else {
      throw DecodingError.dataCorruptedError(
        forKey: .command, in: container,
        debugDescription: "Invalid named symbol command: \(command)")
    }
    self.namedSymbol = symbol
    try super.init(from: decoder)
  }

  final override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(namedSymbol.command, forKey: .command)
    try super.encode(to: encoder)
  }

  // MARK: - Node(Storage)

  final override class var storageTags: Array<String> {
    NamedSymbol.allCommands.map(\.command)
  }

  final override class func load(from json: JSONValue) -> NodeLoaded<Node> {
    loadSelf(from: json).cast()
  }

  final override func store() -> JSONValue {
    let json = JSONValue.array([.string(namedSymbol.command)])
    return json
  }

  // MARK: - Storage

  final class func loadSelf(from json: JSONValue) -> NodeLoaded<NamedSymbolNode> {
    guard case let .array(array) = json,
      array.count == 1,
      case let .string(command) = array[0],
      let mathSymbol = NamedSymbol.lookup(command)
    else { return .failure(UnknownNode(json)) }
    return .success(NamedSymbolNode(mathSymbol))
  }

  // MARK: - NamedSymbolNode

  internal let namedSymbol: NamedSymbol

  init(_ namedSymbol: NamedSymbol) {
    self.namedSymbol = namedSymbol
    super.init()
  }
}
