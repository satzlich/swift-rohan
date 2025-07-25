import Foundation

enum ExprSerdeUtils {
  static let registeredExprs: Dictionary<ExprType, Expr.Type> = [
    .counter: CounterExpr.self,
    .linebreak: LinebreakExpr.self,
    .text: TextExpr.self,
    .unknown: UnknownExpr.self,
    // Template
    .apply: ApplyExpr.self,
    .cVariable: CompiledVariableExpr.self,
    .variable: VariableExpr.self,
    // Element
    .content: ContentExpr.self,
    .heading: HeadingExpr.self,
    .itemList: ItemListExpr.self,
    .paragraph: ParagraphExpr.self,
    .parList: ParListExpr.self,
    .root: RootExpr.self,
    .textStyles: TextStylesExpr.self,
    // Math
    .accent: AccentExpr.self,
    .attach: AttachExpr.self,
    .equation: EquationExpr.self,
    .fraction: FractionExpr.self,
    .leftRight: LeftRightExpr.self,
    .mathAttributes: MathAttributesExpr.self,
    .mathExpression: MathExpressionExpr.self,
    .mathOperator: MathOperatorExpr.self,
    .namedSymbol: NamedSymbolExpr.self,
    .mathStyles: MathStylesExpr.self,
    .matrix: MatrixExpr.self,
    .multiline: MultilineExpr.self,
    .radical: RadicalExpr.self,
    .textMode: TextModeExpr.self,
    .underOver: UnderOverExpr.self,
  ]

  /// A subroutine for decoding a list of expressions from an **unkeyed decoding
  /// container**.
  static func decodeListOfExprs<Store: RangeReplaceableCollection<Expr>>(
    from container: inout UnkeyedDecodingContainer
  ) throws -> Store {
    var store: Store = .init()
    if let count = container.count {
      store.reserveCapacity(count)
    }
    while !container.isAtEnd {
      store.append(try decodeExpr(from: &container))
    }
    return store
  }

  /// Decode a node from an _unkeyed decoding container_.
  private static func decodeExpr(
    from container: inout UnkeyedDecodingContainer
  ) throws -> Expr {
    let currentIndex = container.currentIndex
    // peek node type
    var containerCopy = container  // use copy to peek
    guard
      let nodeContainer =
        try? containerCopy.nestedContainer(keyedBy: Expr.CodingKeys.self),
      let rawValue = try? nodeContainer.decode(ExprType.RawValue.self, forKey: .type)
    else {
      assert(currentIndex == container.currentIndex)
      let expr = try UnknownExpr(from: try container.superDecoder())
      assert(currentIndex + 1 == container.currentIndex)
      return expr
    }
    let exprType = ExprType(rawValue: rawValue) ?? .unknown
    // get node class
    let klass = registeredExprs[exprType] ?? UnknownExpr.self
    // decode expr
    assert(currentIndex == container.currentIndex)
    let expr = try klass.init(from: try container.superDecoder())
    assert(currentIndex + 1 == container.currentIndex)
    return expr
  }

  /// Decode a node from json
  static func decodeExpr(from json: Data) throws -> Expr {
    try JSONDecoder().decode(WildcardExpr.self, from: json).expr
  }
}

struct WildcardExpr: Decodable {
  let expr: Expr

  init(from decoder: any Decoder) throws {
    guard let container = try? decoder.container(keyedBy: Expr.CodingKeys.self),
      let rawValue = try? container.decode(ExprType.RawValue.self, forKey: .type)
    else {
      expr = try UnknownExpr(from: decoder)
      return
    }
    let exprType = ExprType(rawValue: rawValue) ?? .unknown
    let klass = ExprSerdeUtils.registeredExprs[exprType] ?? UnknownExpr.self
    expr = try klass.init(from: decoder)
  }
}
