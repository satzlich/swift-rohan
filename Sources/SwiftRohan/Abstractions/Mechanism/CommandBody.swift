// Copyright 2024-2025 Lie Yan

import Foundation

public enum CommandBody {
  /// insert string
  case insertString(InsertString)

  /// insert expressions
  case insertExpressions(InsertExpressions)

  /// add/goto math component
  case addMathComponent(MathIndex)

  init(_ string: String, _ category: ContentCategory) {
    let insertString = InsertString(string, category)
    self = .insertString(insertString)
  }

  init(_ symbol: SymbolMnemonic, _ category: ContentCategory) {
    let insertString = InsertString(symbol.string, category, symbol.backwardMoves)
    self = .insertString(insertString)
  }

  init(
    _ expressions: [Expr],
    _ category: ContentCategory,
    _ backwardMoves: Int,
    _ preview: String
  ) {
    let preview = CommandPreview.string(preview)
    let insertExpressions =
      InsertExpressions(expressions, category, backwardMoves, preview: preview)
    self = .insertExpressions(insertExpressions)
  }

  init(
    _ expressions: [Expr],
    _ category: ContentCategory,
    _ backwardMoves: Int,
    image imageName: String? = nil
  ) {
    let preview = imageName.map { CommandPreview.image($0) }
    let insertExpressions =
      InsertExpressions(expressions, category, backwardMoves, preview: preview)
    self = .insertExpressions(insertExpressions)
  }

  init(_ index: MathIndex) {
    self = .addMathComponent(index)
  }

  func isCompatible(with container: ContainerCategory) -> Bool {
    switch self {
    case .insertString(let insertString):
      return container.isCompatible(with: insertString.category)
    case .insertExpressions(let insertExpressions):
      return container.isCompatible(with: insertExpressions.category)
    case .addMathComponent:
      return container == .mathContainer
    }
  }

  var isUniversal: Bool {
    switch self {
    case .insertString(let insertString):
      return insertString.category.isUniversal
    case .insertExpressions(let insertExpressions):
      return insertExpressions.category.isUniversal
    case .addMathComponent:
      return false
    }
  }

  var isMathOnly: Bool {
    switch self {
    case .insertString(let insertString):
      return insertString.category.isMathOnly
    case .insertExpressions(let insertExpressions):
      return insertExpressions.category.isMathOnly
    case .addMathComponent:
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
        if expressions.count == 1,
          let text = expressions.first as? TextExpr
        {
          return .string(preview(for: text.string))
        }
        else {
          return .string(Strings.dottedSquare)
        }
      }
    case .addMathComponent:
      return .string(Strings.dottedSquare)
    }

    func preview<S: Collection<Character>>(for string: S) -> String {
      string.count > 2 ? string.prefix(2) + "…" : String(string)
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
      _ expressions: [Expr],
      _ category: ContentCategory,
      _ backwardMoves: Int,
      preview: CommandPreview? = nil
    ) {
      precondition(backwardMoves >= 0)

      self.expressions = expressions
      self.category = category
      self.backwardMoves = backwardMoves
      self.preview = preview
    }
  }
}

enum CommandPreview {
  case string(String)
  case image(String)  // file name without extension
}
