// Copyright 2024-2025 Lie Yan

import Foundation
import LatexParser

private let ALIGN_ROW_GAP = Em(0.5)
private let ALIGN_COL_GAP = Em(1.0)
private let MATRIX_ROW_GAP = Em(0.3)
private let MATRIX_COL_GAP = Em(0.8)
private let SUBSTACK_ROW_GAP = Em.zero

struct MathArray: Codable, CommandDeclarationProtocol {
  enum Subtype: Codable {
    case aligned
    case cases
    case gathered
    case matrix(DelimiterPair)
    case multline
    case substack

    var isMatrix: Bool {
      if case .matrix = self { return true }
      return false
    }

    var isMultiColumnEnabled: Bool {
      switch self {
      case .aligned: true
      case .cases: true
      case .gathered: false
      case .matrix: true
      case .multline: false
      case .substack: false
      }
    }
  }

  let command: String
  var tag: CommandTag { .null }
  var source: CommandSource { .preBuilt }
  let subtype: Subtype

  var isMatrix: Bool { subtype.isMatrix }
  var isMultiColumnEnabled: Bool { subtype.isMultiColumnEnabled }

  var delimiters: DelimiterPair {
    switch subtype {
    case .aligned: return DelimiterPair.NONE
    case .cases: return DelimiterPair.LBRACE
    case .gathered: return DelimiterPair.NONE
    case .matrix(let delimiters): return delimiters
    case .multline: return DelimiterPair.NONE
    case .substack: return DelimiterPair.NONE
    }
  }

  init(_ command: String, _ subtype: Subtype) {
    self.command = command
    self.subtype = subtype
  }

  func getRowGap() -> Em {
    switch subtype {
    case .aligned: return ALIGN_ROW_GAP
    case .cases: return MATRIX_ROW_GAP
    case .gathered: return ALIGN_ROW_GAP
    case .matrix: return MATRIX_ROW_GAP
    case .multline: return ALIGN_ROW_GAP
    case .substack: return SUBSTACK_ROW_GAP
    }
  }

  func getCellAlignments() -> CellAlignmentProvider {
    switch subtype {
    case .aligned: return AlternateCellAlignmentProvider()
    case .cases: return FixedCellAlignmentProvider(.start)
    case .gathered: return FixedCellAlignmentProvider(.center)
    case .matrix: return FixedCellAlignmentProvider(.center)
    case .multline: return MultlineCellAlignmentProvider()
    case .substack: return FixedCellAlignmentProvider(.center)
    }
  }

  func getColumnGapCalculator(
    _ columns: Array<Array<MathListLayoutFragment>>,
    _ mathContext: MathContext
  ) -> ColumnGapProvider {
    let alignments = getCellAlignments()
    switch subtype {
    case .aligned: return AlignColumnGapProvider(columns, alignments, mathContext)
    case .cases: return MatrixColumnGapProvider()
    case .gathered: return PlaceholderColumnGapProvider()  // unused
    case .matrix: return MatrixColumnGapProvider()
    case .multline: return PlaceholderColumnGapProvider()  // unused
    case .substack: return PlaceholderColumnGapProvider()  // unused
    }
  }
}

extension MathArray {
  static let allCommands: Array<MathArray> = inlineMathCommands + blockMathCommands

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

  static let blockMathCommands: Array<MathArray> = [
    multline
  ]

  private static let _dictionary: Dictionary<String, MathArray> =
    Dictionary(uniqueKeysWithValues: allCommands.map { ($0.command, $0) })

  static func lookup(_ command: String) -> MathArray? {
    _dictionary[command]
  }

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
  //
  static let multline = MathArray("multline", .multline)
  static let substack = MathArray("substack", .substack)
}

protocol CellAlignmentProvider {
  /// Column alignment.
  func get(_ column: Int) -> FixedAlignment
  /// Cell alignment if more refined alignment is needed.
  func get(_ row: Int, _ column: Int) -> FixedAlignment
}

extension CellAlignmentProvider {
  func get(_ row: Int, _ column: Int) -> FixedAlignment {
    self.get(column)
  }
}

private struct FixedCellAlignmentProvider: CellAlignmentProvider {
  let alignment: FixedAlignment

  init(_ alignment: FixedAlignment) {
    self.alignment = alignment
  }

  func get(_ column: Int) -> FixedAlignment { alignment }
}

/// This is for `{aligned}` environment.
private struct AlternateCellAlignmentProvider: CellAlignmentProvider {
  func get(_ column: Int) -> FixedAlignment {
    column % 2 == 0 ? .end : .start
  }
}

/// This is for `{multline}` environment.
private struct MultlineCellAlignmentProvider: CellAlignmentProvider {
  func get(_ column: Int) -> FixedAlignment { .start }

  func get(_ row: Int, _ column: Int) -> FixedAlignment {
    row == 0 ? .start : .end
  }
}

// MARK: - Column Gaps

protocol ColumnGapProvider {
  /// Get the gap between the given column and its next column.
  /// - Precondition: `index\in [0,columnCount)`
  func get(_ index: Int) -> Em
}

/// Placeholder column gap provider, used when the column gap is not specified.
private struct PlaceholderColumnGapProvider: ColumnGapProvider {
  func get(_ index: Int) -> Em { MATRIX_COL_GAP }
}

private struct MatrixColumnGapProvider: ColumnGapProvider {
  func get(_ index: Int) -> Em { MATRIX_COL_GAP }
}

private struct AlignColumnGapProvider: ColumnGapProvider {
  private let _columns: Array<Array<MathListLayoutFragment>>
  private let _columnAlignments: CellAlignmentProvider
  private let _mathContext: MathContext

  init(
    _ columns: Array<Array<MathListLayoutFragment>>,
    _ columnAlignments: CellAlignmentProvider,
    _ mathContext: MathContext
  ) {
    self._columns = columns
    self._columnAlignments = columnAlignments
    self._mathContext = mathContext
  }

  func get(_ index: Int) -> Em {
    precondition(0..<_columns.count ~= index)

    guard index + 1 < _columns.count,
      _columnAlignments.get(index) == .end
        && _columnAlignments.get(index + 1) == .start
    else { return ALIGN_COL_GAP }

    let column = _columns[index]
    let nextColumn = _columns[index + 1]

    var maxSpacing = Em.zero
    for i in 0..<column.count {
      guard let lhs = column[i].last,
        let rhs = nextColumn[i].first
      else { continue }
      let spacing = MathUtils.resolveSpacing(lhs.clazz, rhs.clazz, _mathContext.mathStyle)
      maxSpacing = max(maxSpacing, spacing ?? Em.zero)
    }
    return maxSpacing
  }
}
