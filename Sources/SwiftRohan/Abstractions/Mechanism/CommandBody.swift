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
  case editGrid(EditGrid)

  // MARK: - Canonical

  private init(_ expressions: [Expr], _ backwardMoves: Int, text preview: String? = nil) {
    guard let category = TreeUtils.contentCategory(of: expressions)
    else { fatalError("Category cannot be nil") }
    assert(category.isTextual == false)

    let preview = preview.map(CommandPreview.string)
    let insertExpressions =
      InsertExprs(expressions, category, backwardMoves, preview: preview)
    self = .insertExprs(insertExpressions)
  }

  private init(_ expressions: [Expr], _ backwardMoves: Int, image: String) {
    guard let category = TreeUtils.contentCategory(of: expressions)
    else { fatalError("Category cannot be nil") }
    assert(category.isTextual == false)

    let preview = CommandPreview.image(image)
    let insertExpressions =
      InsertExprs(expressions, category, backwardMoves, preview: preview)
    self = .insertExprs(insertExpressions)
  }

  init(_ editAttach: EditMath) {
    self = .editMath(editAttach)
  }

  // MARK: - Convenience

  init(_ string: String, _ category: ContentCategory) {
    let insertString = InsertString(string, category)
    self = .insertString(insertString)
  }

  init(_ symbol: TextSymbol, _ category: ContentCategory) {
    let insertString = InsertString(String(symbol.char), category, 0)
    self = .insertString(insertString)
  }

  init(_ expr: Expr, _ backwardMoves: Int, text: String? = nil) {
    self.init([expr], backwardMoves, text: text)
  }

  init(_ expr: Expr, _ backwardMoves: Int, image: String) {
    self.init([expr], backwardMoves, image: image)
  }

  func isCompatible(with container: ContainerCategory) -> Bool {
    switch self {
    case .insertString(let insertString):
      return container.isCompatible(with: insertString.category)
    case .insertExprs(let insertExpressions):
      return container.isCompatible(with: insertExpressions.category)
    case .editMath:
      return container == .mathContainer
    case .editGrid:
      return container == .mathContainer
    }
  }

  var isUniversal: Bool {
    switch self {
    case .insertString(let insertString):
      return insertString.category.isUniversal
    case .insertExprs(let insertExpressions):
      return insertExpressions.category.isUniversal
    case .editMath:
      return false
    case .editGrid:
      return false
    }
  }

  var isMathOnly: Bool {
    switch self {
    case .insertString(let insertString):
      return insertString.category.isMathOnly
    case .insertExprs(let insertExpressions):
      return insertExpressions.category.isMathOnly
    case .editMath:
      return true
    case .editGrid:
      return true
    }
  }

  var preview: CommandPreview {
    switch self {
    case .insertString(let insertString):
      return .string(preview(for: insertString.string))

    case .insertExprs(let insertExpressions):
      if let preview = insertExpressions.preview {
        return preview
      }
      else {
        let expressions = insertExpressions.expressions
        if expressions.count == 1 {
          switch expressions[0] {
          case let text as TextExpr:
            return .string(preview(for: text.string))
          case let symbol as MathSymbolExpr:
            return .string(symbol.mathSymbol.preview())
          default:
            return .string("⬚")
          }
        }
        else {
          return .string("⬚")
        }
      }

    case .editMath(_):
      return .string("⬚")

    case .editGrid(_):
      return .string("⬚")
    }

    func preview<S: Collection<Character>>(for string: S) -> String {
      string.count > 3 ? string.prefix(2) + "…" : String(string)
    }
  }

  func insertString() -> InsertString? {
    switch self {
    case .insertString(let insertString):
      return insertString
    default:
      return nil
    }
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
  }

  public struct InsertExprs {
    let expressions: [Expr]
    let category: ContentCategory
    let backwardMoves: Int
    let preview: CommandPreview?

    init(
      _ expressions: [Expr], _ category: ContentCategory, _ backwardMoves: Int,
      preview: CommandPreview? = nil
    ) {
      precondition(backwardMoves >= 0)

      self.expressions = expressions
      self.category = category
      self.backwardMoves = backwardMoves
      self.preview = preview
    }
  }

  public enum EditMath {
    /// Attach or goto math component
    case addComponent(MathIndex)
    /// Delete math component
    case removeComponent(MathIndex)
  }

  public enum EditGrid {
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
    return CommandBody(expr, 1, text: accent.preview())
  }

  static func from(_ frac: MathGenFrac, image: String) -> CommandBody {
    let expr = FractionExpr(num: [], denom: [], subtype: frac)
    return CommandBody(expr, 2, image: image)
  }

  /// Create a command body from a matrix.
  /// - Parameter image: preview image name without extension.
  static func from(_ matrix: MathArray, image: String) -> CommandBody {
    let rowCount = 2
    let columnCount = 2
    let count = rowCount * columnCount

    switch matrix.subtype {
    case .align:
      let rows: [AlignedExpr.Row] = (0..<rowCount).map { _ in
        let elements = (0..<columnCount).map { _ in AlignedExpr.Element() }
        return AlignedExpr.Row(elements)
      }
      let expr = AlignedExpr(rows)
      return CommandBody(expr, count, image: image)

    case .cases:
      let rows: [CasesExpr.Row] = (0..<rowCount).map { _ in
        let elements = (0..<columnCount).map { _ in CasesExpr.Element() }
        return CasesExpr.Row(elements)
      }
      let expr = CasesExpr(rows)
      return CommandBody(expr, count, image: image)

    case .matrix:
      let rows: [MatrixExpr.Row] = (0..<rowCount).map { _ in
        let elements = (0..<columnCount).map { _ in MatrixExpr.Element() }
        return MatrixExpr.Row(elements)
      }
      let expr = MatrixExpr(matrix, rows)
      return CommandBody(expr, count, image: image)
    }
  }

  static func from(_ mathExpression: MathExpression, preview: String) -> CommandBody {
    let expr = MathExpressionExpr(mathExpression)
    return CommandBody(expr, 0, text: preview)
  }

  static func from(_ mathKind: MathKind) -> CommandBody {
    let expr = MathKindExpr(mathKind)
    return CommandBody(expr, 1)
  }

  static func from(_ mathOp: MathOperator) -> CommandBody {
    let expr = MathOperatorExpr(mathOp)
    let preview = "\(mathOp.string)"
    return CommandBody(expr, 0, text: preview)
  }

  static func from(_ symbol: MathSymbol) -> CommandBody {
    let expr = MathSymbolExpr(symbol)
    return CommandBody(expr, 0)
  }

  static func fromMathSymbol(_ command: String) -> CommandBody? {
    guard let symbol = MathSymbol.lookup(command)
    else { return nil }
    return from(symbol)
  }

  static func from(_ mathTextStyle: MathTextStyle) -> CommandBody {
    let expr = MathVariantExpr(mathTextStyle, [])
    return CommandBody(expr, 1, text: mathTextStyle.preview())
  }

  static func from(_ spreader: MathSpreader, image: String) -> CommandBody {
    let expr =
      switch spreader.subtype {
      case .over: OverspreaderExpr(spreader, [])
      case .under: UnderspreaderExpr(spreader, [])
      }
    return CommandBody(expr, 1, image: image)
  }
}
