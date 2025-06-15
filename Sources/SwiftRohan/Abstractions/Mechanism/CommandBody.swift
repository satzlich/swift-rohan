// Copyright 2024-2025 Lie Yan

import Foundation

public enum CommandBody {
  /// insert string
  case insertString(InsertString)

  /// insert expressions
  case insertExprs(InsertExprs)

  /// edit attach
  case editMath(EditMath)

  /// edit matrix
  case editArray(EditArray)

  // MARK: - Canonical

  private init(_ expressions: Array<Expr>, _ backwardMoves: Int, preview: CommandPreview)
  {
    guard let category = TreeUtils.contentCategory(of: expressions)
    else { fatalError("Expect non-nil category") }
    assert(category.isPlaintext == false)
    let insertExprs = InsertExprs(expressions, category, backwardMoves, preview: preview)
    self = .insertExprs(insertExprs)
  }

  init(_ editAttach: EditMath) {
    self = .editMath(editAttach)
  }

  // MARK: - Convenience

  init(_ string: String, _ category: ContentCategory) {
    let insertString = InsertString(string, category)
    self = .insertString(insertString)
  }

  init(_ expr: Expr, _ backwardMoves: Int, preview: CommandPreview = .string("⬚")) {
    self.init([expr], backwardMoves, preview: preview)
  }

  func isCompatible(with container: ContainerCategory) -> Bool {
    switch self {
    case .insertString(let insertString):
      return container.isCompatible(with: insertString.category)
    case .insertExprs(let insertExprs):
      return container.isCompatible(with: insertExprs.category)
    case .editMath:
      return container == .mathContainer
    case .editArray:
      return container == .mathContainer
    }
  }

  var isUniversal: Bool {
    switch self {
    case .insertString(let insertString):
      return insertString.category.isUniversal
    case .insertExprs(let insertExprs):
      return insertExprs.category.isUniversal
    case .editMath:
      return false
    case .editArray:
      return false
    }
  }

  var isMathOnly: Bool {
    switch self {
    case .insertString(let insertString):
      return insertString.category.isMathOnly
    case .insertExprs(let insertExprs):
      return insertExprs.category.isMathOnly
    case .editMath:
      return true
    case .editArray:
      return true
    }
  }

  var preview: CommandPreview {
    switch self {
    case .insertString(let insertString):
      return .string(insertString.preview())
    case .insertExprs(let insertExprs):
      return insertExprs.preview
    case .editMath(_):
      return .string("⬚")
    case .editArray(_):
      return .string("⬚")
    }
  }

  internal func insertString() -> InsertString? {
    if case let .insertString(insertString) = self {
      return insertString
    }
    return nil
  }

  // MARK: - Variants

  enum CommandPreview {
    case string(String)
    case image(String)  // file name without extension
  }

  public struct InsertString {
    let string: String
    let category: ContentCategory
    let backwardMoves: Int

    init(_ string: String, _ category: ContentCategory, _ backwardMoves: Int = 0) {
      precondition(backwardMoves >= 0)
      self.string = string
      self.category = category
      self.backwardMoves = backwardMoves
    }

    func preview() -> String {
      string.count > 3 ? string.prefix(2) + "…" : string
    }
  }

  public struct InsertExprs {
    let exprs: Array<Expr>
    let category: ContentCategory
    let backwardMoves: Int
    let preview: CommandPreview

    init(
      _ exprs: Array<Expr>, _ category: ContentCategory, _ backwardMoves: Int,
      preview: CommandPreview
    ) {
      precondition(backwardMoves >= 0)
      self.exprs = exprs
      self.category = category
      self.backwardMoves = backwardMoves
      self.preview = preview
    }
  }

  public enum EditMath {
    /// Attach or goto math component
    case attachOrGotoComponent(MathIndex)
    /// Delete math component
    case removeComponent(MathIndex)
  }

  public enum EditArray {
    case insertRowBefore
    case insertRowAfter
    case insertColumnBefore
    case insertColumnAfter
    case deleteRow
    case deleteColumn
  }
}

extension CommandBody {
  static func from(_ accent: MathAccent) -> CommandBody {
    let expr = AccentExpr(accent, [])
    return CommandBody(expr, 1, preview: accent.preview())
  }

  static func from(_ frac: MathGenFrac, image: String) -> CommandBody {
    let expr = FractionExpr(num: [], denom: [], genfrac: frac)
    return CommandBody(expr, 2, preview: .image(image))
  }

  /// Create a command body from a matrix.
  /// - Parameter image: preview image name without extension.
  static func arrayExpr<T: ArrayExpr>(
    _ matrix: MathArray, image: String, _ arrayClass: T.Type
  ) -> CommandBody {
    let rowCount = 2
    let columnCount = matrix.isMultiColumnEnabled ? 2 : 1
    let count = rowCount * columnCount

    let rows: Array<ArrayExpr.Row> = (0..<rowCount).map { _ in
      let elements = (0..<columnCount).map { _ in MatrixExpr.Element() }
      return ArrayExpr.Row(elements)
    }
    let expr = arrayClass.init(matrix, rows)
    return CommandBody(expr, count, preview: .image(image))
  }

  static func from(
    _ mathExpression: MathExpression, preview: CommandPreview
  ) -> CommandBody {
    let expr = MathExpressionExpr(mathExpression)
    return CommandBody(expr, 0, preview: preview)
  }

  static func from(_ mathAttributes: MathAttributes) -> CommandBody {
    let expr = MathAttributesExpr(mathAttributes)
    return CommandBody(expr, 1)
  }

  static func from(_ mathOp: MathOperator) -> CommandBody {
    let expr = MathOperatorExpr(mathOp)
    return CommandBody(expr, 0, preview: .string(mathOp.string))
  }

  static func from(_ symbol: NamedSymbol) -> CommandBody {
    let expr = NamedSymbolExpr(symbol)
    return CommandBody(expr, 0, preview: .string(symbol.preview()))
  }

  static func fromNamedSymbol(_ command: String) -> CommandBody? {
    guard let symbol = NamedSymbol.lookup(command)
    else { return nil }
    return from(symbol)
  }

  static func from(_ template: MathTemplate, preview: CommandPreview) -> CommandBody {
    let expr = ApplyExpr(template)
    return CommandBody(expr, template.parameterCount, preview: preview)
  }

  static func from(_ mathStyles: MathStyles) -> CommandBody {
    let expr = MathStylesExpr(mathStyles, [])
    return CommandBody(expr, 1, preview: mathStyles.preview())
  }

  static func from(_ spreader: MathSpreader, image: String) -> CommandBody {
    let expr = UnderOverExpr(spreader, [])
    return CommandBody(expr, 1, preview: .image(image))
  }
}
