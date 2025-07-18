// Copyright 2024-2025 Lie Yan

import Foundation
import LatexParser

struct MathArray: Codable, CommandDeclarationProtocol {
  let command: String
  var tag: CommandTag { .null }
  var source: CommandSource { .preBuilt }
  let subtype: Subtype

  init(_ command: String, _ subtype: Subtype) {
    self.command = command
    self.subtype = subtype
  }

  var requiresMatrixNode: Bool { subtype.requiresMatrixNode }
  var requiresMultilineNode: Bool { subtype.requiresMultilineNode }

  var delimiters: DelimiterPair { subtype.delimiters }
  var isMatrix: Bool { subtype.isMatrix }
  var isMultline: Bool { subtype.isMultline }

  var isMultiColumnEnabled: Bool { subtype.isMultiColumnEnabled }
  var shouldProvideCounter: Bool { subtype.shouldProvideCounter }

  func mathStyle(for value: MathStyle) -> MathStyle { subtype.mathStyle(for: value) }

  func getRowGap() -> Em { subtype.getRowGap() }

  func getCellAlignments(_ rowCount: Int) -> CellAlignmentProvider {
    subtype.getCellAlignments(rowCount)
  }

  func getColumnGapCalculator(
    _ columns: Array<Array<MathListLayoutFragment>>,
    _ mathContext: MathContext
  ) -> ColumnGapProvider {
    subtype.getColumnGapCalculator(columns, mathContext)
  }
}

extension MathArray {
  enum Subtype: Codable {
    case align
    case alignAst
    case aligned
    case cases
    case gather
    case gatherAst
    case gathered
    case matrix(DelimiterPair)
    case multline
    case multlineAst
    case substack

    var requiresMatrixNode: Bool {
      switch self {
      case .aligned, .cases, .gathered, .matrix, .substack:
        return true
      case .align, .alignAst, .gather, .gatherAst, .multline, .multlineAst:
        return false
      }
    }

    var requiresMultilineNode: Bool { !requiresMatrixNode }

    var isMatrix: Bool {
      switch self {
      case .matrix: true
      case _: false
      }
    }

    var isMultline: Bool {
      switch self {
      case .multline, .multlineAst: true
      case _: false
      }
    }

    var isMultiColumnEnabled: Bool {
      switch self {
      case .align, .alignAst, .aligned: true
      case .cases: true
      case .gather, .gatherAst, .gathered: false
      case .matrix: true
      case .multline, .multlineAst: false
      case .substack: false
      }
    }

    var shouldProvideCounter: Bool {
      switch self {
      case .align: true
      case .alignAst: false
      case .aligned: false
      case .cases: false
      case .gather: true
      case .gatherAst: false
      case .gathered: false
      case .matrix: false
      case .multline: true
      case .multlineAst: false
      case .substack: false
      }
    }

    func mathStyle(for value: MathStyle) -> MathStyle {
      switch self {
      case .align, .alignAst, .aligned: MathUtils.alignedStyle(for: value)
      case .gather, .gatherAst, .gathered: MathUtils.gatheredStyle(for: value)
      case .multline, .multlineAst: MathUtils.multlineStyle(for: value)
      case .cases: MathUtils.matrixStyle(for: value)
      case .matrix: MathUtils.matrixStyle(for: value)
      case .substack: MathUtils.matrixStyle(for: value)
      }
    }

    var delimiters: DelimiterPair {
      switch self {
      case .align, .alignAst, .aligned: return DelimiterPair.NONE
      case .cases: return DelimiterPair.LBRACE
      case .gather, .gatherAst, .gathered: return DelimiterPair.NONE
      case .matrix(let delimiters): return delimiters
      case .multline, .multlineAst: return DelimiterPair.NONE
      case .substack: return DelimiterPair.NONE
      }
    }
  }
}

extension MathArray {
  static let allCommands: Array<MathArray> = inlineMathCommands + blockMathCommands

  /// - Note: These commands are used by MatrixNode.
  static let inlineMathCommands: Array<MathArray> = [
    aligned,
    cases,
    gathered,
    // matrix commands
    matrix,
    pmatrix,
    bmatrix,
    Bmatrix,
    vmatrix,
    Vmatrix,
    //
    substack,
  ]

  /// - Note: These commands are used by MultilineNode.
  static let blockMathCommands: Array<MathArray> = [
    align,
    alignAst,
    gather,
    gatherAst,
    multline,
    multlineAst,
  ]

  private static let _dictionary: Dictionary<String, MathArray> =
    Dictionary(uniqueKeysWithValues: allCommands.map { ($0.command, $0) })

  static func lookup(_ command: String) -> MathArray? {
    _dictionary[command]
  }

  // inline math commands

  static let aligned = MathArray("aligned", .aligned)
  static let cases = MathArray("cases", .cases)
  static let gathered = MathArray("gathered", .gathered)
  // matrix commands
  static let matrix = MathArray("matrix", .matrix(DelimiterPair.NONE))
  static let pmatrix = MathArray("pmatrix", .matrix(DelimiterPair.PAREN))
  static let bmatrix = MathArray("bmatrix", .matrix(DelimiterPair.BRACKET))
  static let Bmatrix = MathArray("Bmatrix", .matrix(DelimiterPair.BRACE))
  static let vmatrix = MathArray("vmatrix", .matrix(DelimiterPair.VERT))
  static let Vmatrix = MathArray("Vmatrix", .matrix(DelimiterPair.DOUBLE_VERT))
  static let substack = MathArray("substack", .substack)

  // block math commands

  //
  static let align = MathArray("align", .align)
  static let alignAst = MathArray("align*", .alignAst)
  static let gather = MathArray("gather", .gather)
  static let gatherAst = MathArray("gather*", .gatherAst)
  static let multline = MathArray("multline", .multline)
  static let multlineAst = MathArray("multline*", .multlineAst)
}
