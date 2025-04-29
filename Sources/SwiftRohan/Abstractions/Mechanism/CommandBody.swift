// Copyright 2024-2025 Lie Yan

import Foundation

public struct CommandBody {
  enum Content {
    case string(String)
    case expressions([Expr])
    case mathComponent(MathIndex)

    func string() -> String? {
      switch self {
      case .string(let string): return string
      case .expressions, .mathComponent: return nil
      }
    }
  }

  enum Preview {
    case string(String)
    case image(String)  // file name without extension
  }

  /// Content produced by this command.
  let content: Content

  /// Category of the content produced by this command.
  let category: ContentCategory

  /// Preview string for the content.
  let preview: Preview?

  /// Backward moves needed to relocate the cursor.
  let backwardMoves: Int

  private init(
    _ content: Content, _ category: ContentCategory, _ backwardMoves: Int,
    _ preview: Preview?
  ) {
    precondition(backwardMoves >= 0)
    self.content = content
    self.category = category
    self.backwardMoves = backwardMoves
    self.preview = preview
  }

  init(
    _ string: String, _ category: ContentCategory, _ backwardMoves: Int = 0,
    _ preview: String? = nil
  ) {
    let preview = preview.map { Preview.string($0) }
    self.init(.string(string), category, backwardMoves, preview)
  }

  init(_ symbol: SymbolMnemonic, _ category: ContentCategory) {
    self.init(.string(symbol.string), category, symbol.backwardMoves, nil)
  }

  init(
    _ exprs: [Expr], _ category: ContentCategory, _ backwardMoves: Int,
    _ preview: String? = nil
  ) {
    let preview = preview.map { Preview.string($0) }
    self.init(.expressions(exprs), category, backwardMoves, preview)
  }

  init(
    _ exprs: [Expr], _ category: ContentCategory, _ backwardMoves: Int,
    image fileName: String
  ) {
    let preview = Preview.image(fileName)
    self.init(.expressions(exprs), category, backwardMoves, preview)
  }

  init(_ component: MathIndex, _ backwardMoves: Int) {
    precondition(component == .sub || component == .sup)
    self.init(.mathComponent(component), .mathContent, backwardMoves, nil)
  }
}
