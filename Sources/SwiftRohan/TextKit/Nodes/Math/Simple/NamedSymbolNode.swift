// Copyright 2024-2025 Lie Yan

import Foundation

final class NamedSymbolNode: SimpleNode {
  override class var type: NodeType { .namedSymbol }

  let namedSymbol: NamedSymbol

  init(_ namedSymbol: NamedSymbol) {
    self.namedSymbol = namedSymbol
    super.init()
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case msym }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.namedSymbol = try container.decode(NamedSymbol.self, forKey: .msym)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(namedSymbol, forKey: .msym)
    try super.encode(to: encoder)
  }

  // MARK: - Layout

  override func layoutLength() -> Int {
    namedSymbol.string.length
  }

  override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    precondition(context is MathListLayoutContext)
    let context = context as! MathListLayoutContext

    if fromScratch {
      context.insertText(String(namedSymbol.string), self)
    }
    else {
      context.skipBackwards(layoutLength())
    }
  }

  // MARK: - Clone and Visitor

  override func deepCopy() -> NamedSymbolNode {
    NamedSymbolNode(namedSymbol)
  }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(namedSymbol: self, context)
  }

  override class var storageTags: [String] {
    NamedSymbol.predefinedCases.map { $0.command }
  }

  override func store() -> JSONValue {
    let json = JSONValue.array([.string(namedSymbol.command)])
    return json
  }

  class func loadSelf(from json: JSONValue) -> _LoadResult<NamedSymbolNode> {
    guard case let .array(array) = json,
      array.count == 1,
      case let .string(command) = array[0],
      let mathSymbol = NamedSymbol.lookup(command)
    else { return .failure(UnknownNode(json)) }
    return .success(NamedSymbolNode(mathSymbol))
  }

  override class func load(from json: JSONValue) -> _LoadResult<Node> {
    loadSelf(from: json).cast()
  }
}
