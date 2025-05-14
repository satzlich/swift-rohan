// Copyright 2024-2025 Lie Yan

import Foundation

public enum CommandBody {
  /// insert string
  case insertString(InsertString)

  /// insert expressions
  case insertExpressions(InsertExpressions)

  /// edit attach
  case editMath(EditMath)

  /// edit matrix
  case editGrid(EditGrid)

  init(_ string: String, _ category: ContentCategory) {
    let insertString = InsertString(string, category)
    self = .insertString(insertString)
  }

  init(_ symbol: SymbolMnemonic, _ category: ContentCategory) {
    let insertString = InsertString(symbol.string, category, symbol.backwardMoves)
    self = .insertString(insertString)
  }

  init(
    _ expr: Expr, _ category: ContentCategory, _ backwardMoves: Int,
    _ preview: String? = nil
  ) {
    self.init([expr], category, backwardMoves, preview)
  }

  init(
    _ expressions: [Expr], _ category: ContentCategory, _ backwardMoves: Int,
    _ preview: String? = nil
  ) {
    let preview = preview.map(CommandPreview.string)
    let insertExpressions =
      InsertExpressions(expressions, category, backwardMoves, preview: preview)
    self = .insertExpressions(insertExpressions)
  }

  init(_ expr: Expr, _ category: ContentCategory, _ backwardMoves: Int, image: String) {
    self.init([expr], category, backwardMoves, image: image)
  }

  init(
    _ expressions: [Expr], _ category: ContentCategory, _ backwardMoves: Int,
    image: String
  ) {
    let preview = CommandPreview.image(image)
    let insertExpressions =
      InsertExpressions(expressions, category, backwardMoves, preview: preview)
    self = .insertExpressions(insertExpressions)
  }

  init(_ editAttach: EditMath) {
    self = .editMath(editAttach)
  }

  func isCompatible(with container: ContainerCategory) -> Bool {
    switch self {
    case .insertString(let insertString):
      return container.isCompatible(with: insertString.category)
    case .insertExpressions(let insertExpressions):
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
    case .insertExpressions(let insertExpressions):
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
    case .insertExpressions(let insertExpressions):
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

    case .insertExpressions(let insertExpressions):
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
            return .string(Strings.dottedSquare)
          }
        }
        else {
          return .string(Strings.dottedSquare)
        }
      }

    case .editMath(_):
      return .string(Strings.dottedSquare)

    case .editGrid(_):
      return .string(Strings.dottedSquare)
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

  public struct InsertExpressions {
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
    CommandBody(AccentExpr(accent, []), .mathContent, 1, accent.preview())
  }

  static func from(_ frac: MathGenFrac, image: String) -> CommandBody {
    let expr = FractionExpr(num: [], denom: [], subtype: frac)
    return CommandBody(expr, .mathContent, 2, image: image)
  }

  /// Create a command body from a matrix.
  /// - Parameter image: preview image name without extension.
  static func from(_ matrix: MathArray, image: String) -> CommandBody {
    let rowCount = 2
    let columnCount = 2

    let rows: [MatrixExpr.Row] = (0..<rowCount).map { _ in
      let elements = (0..<columnCount).map { _ in MatrixExpr.Element() }
      return MatrixExpr.Row(elements)
    }
    let expr = MatrixExpr(matrix, rows)

    return CommandBody(expr, .mathContent, rowCount * columnCount, image: image)
  }

  static func from(_ mathOp: MathOperator) -> CommandBody {
    let expr = MathOperatorExpr(mathOp)
    let preview = "\(mathOp.string)"
    return CommandBody(expr, .mathContent, 0, preview)
  }

  static func from(_ symbol: MathSymbol) -> CommandBody {
    let expr = MathSymbolExpr(symbol)
    let insertExpr = InsertExpressions([expr], .mathText, 0)
    return .insertExpressions(insertExpr)
  }

  static func fromMathSymbol(_ command: String) -> CommandBody? {
    guard let symbol = MathSymbol.lookup(command)
    else { return nil }
    return from(symbol)
  }

  static func from(_ mathTextStyle: MathTextStyle) -> CommandBody {
    let expr = MathVariantExpr(mathTextStyle, [])
    return CommandBody(expr, .mathContent, 1, mathTextStyle.preview())
  }

  static func from(_ overSpreader: MathOverSpreader, image: String) -> CommandBody {
    let char = overSpreader.spreader
    let expr = OverspreaderExpr(char, [])
    return CommandBody(expr, .mathContent, 1, image: image)
  }

  static func from(_ underSpreader: MathUnderSpreader, image: String) -> CommandBody {
    let char = underSpreader.spreader
    let expr = UnderspreaderExpr(char, [])
    return CommandBody(expr, .mathContent, 1, image: image)
  }
}
