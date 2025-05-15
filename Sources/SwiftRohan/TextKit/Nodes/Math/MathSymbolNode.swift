// Copyright 2024-2025 Lie Yan

import Foundation

final class MathSymbolNode: SimpleNode {
  override class var type: NodeType { .mathSymbol }

  let mathSymbol: MathSymbol

  init(_ mathSymbol: MathSymbol) {
    self.mathSymbol = mathSymbol
    super.init()
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case msym }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.mathSymbol = try container.decode(MathSymbol.self, forKey: .msym)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(mathSymbol, forKey: .msym)
    try super.encode(to: encoder)
  }

  // MARK: - Layout

  override func layoutLength() -> Int {
    mathSymbol.symbol.length
  }

  override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    precondition(context is MathListLayoutContext)
    let context = context as! MathListLayoutContext

    if fromScratch {
      context.insertText(String(mathSymbol.symbol), self)
    }
    else {
      context.skipBackwards(layoutLength())
    }
  }

  // MARK: - Clone and Visitor

  override func deepCopy() -> MathSymbolNode {
    MathSymbolNode(mathSymbol)
  }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(mathSymbol: self, context)
  }

  override class var storageTags: [String] {
    MathSymbol.predefinedCases.map { $0.command }
  }

  override func store() -> JSONValue {
    let json = JSONValue.array([.string(mathSymbol.command)])
    return json
  }

  override class func load(from json: JSONValue) -> Node._LoadResult {
    guard case let .array(array) = json,
      array.count == 1,
      case let .string(command) = array[0],
      let mathSymbol = MathSymbol.lookup(command)
    else { return .failure(UnknownNode(json)) }
    return .success(MathSymbolNode(mathSymbol))
  }
}
