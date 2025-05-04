// Copyright 2024-2025 Lie Yan

import Foundation

public enum CommandBody {
  /// insert string
  case insertString(InsertString)

  /// insert expressions
  case insertExpressions(InsertExpressions)

  /// edit attach
  case editAttach(EditAttach)

  /// edit matrix
  case editMatrix(EditMatrix)

  init(_ string: String, _ category: ContentCategory) {
    let insertString = InsertString(string, category)
    self = .insertString(insertString)
  }

  init(_ symbol: SymbolMnemonic, _ category: ContentCategory) {
    let insertString = InsertString(symbol.string, category, symbol.backwardMoves)
    self = .insertString(insertString)
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

  init(
    _ expressions: [Expr], _ category: ContentCategory, _ backwardMoves: Int,
    image imageName: String
  ) {
    let preview = CommandPreview.image(imageName)
    let insertExpressions =
      InsertExpressions(expressions, category, backwardMoves, preview: preview)
    self = .insertExpressions(insertExpressions)
  }

  init(_ index: MathIndex) {
    let editAttach = EditAttach.attachComponent(index)
    self = .editAttach(editAttach)
  }

  func isCompatible(with container: ContainerCategory) -> Bool {
    switch self {
    case .insertString(let insertString):
      return container.isCompatible(with: insertString.category)
    case .insertExpressions(let insertExpressions):
      return container.isCompatible(with: insertExpressions.category)
    case .editAttach:
      return container == .mathContainer
    case .editMatrix:
      return container == .mathContainer
    }
  }

  var isUniversal: Bool {
    switch self {
    case .insertString(let insertString):
      return insertString.category.isUniversal
    case .insertExpressions(let insertExpressions):
      return insertExpressions.category.isUniversal
    case .editAttach:
      return false
    case .editMatrix:
      return false
    }
  }

  var isMathOnly: Bool {
    switch self {
    case .insertString(let insertString):
      return insertString.category.isMathOnly
    case .insertExpressions(let insertExpressions):
      return insertExpressions.category.isMathOnly
    case .editAttach:
      return true
    case .editMatrix:
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

    case .editAttach(_):
      return .string(Strings.dottedSquare)

    case .editMatrix(_):
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

  public enum EditAttach {
    /// Attach or goto math component
    case attachComponent(MathIndex)
    case removeComponent(MathIndex)
  }

  public enum EditMatrix {
    case insertRowAbove
    case insertRowBelow
    case insertColumnBefore
    case insertColumnAfter
    case deleteRow
    case deleteColumn
  }
}
