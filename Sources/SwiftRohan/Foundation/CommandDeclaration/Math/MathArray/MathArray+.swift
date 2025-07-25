import Foundation

private let ALIGN_ROW_GAP = Em(0.5)
private let ALIGN_COL_GAP = Em(1.0)
private let MATRIX_ROW_GAP = Em(0.3)
private let MATRIX_COL_GAP = Em(0.8)
private let SMALLMATRIX_ROW_GAP = Em(0.15)
private let SMALLMATRIX_COL_GAP = Em(0.4)
private let SUBSTACK_ROW_GAP = Em.zero

extension MathArray.Subtype {
  func getRowGap() -> Em {
    switch self {
    case .align, .alignAst, .aligned: return ALIGN_ROW_GAP
    case .cases: return MATRIX_ROW_GAP
    case .gather, .gatherAst, .gathered: return ALIGN_ROW_GAP
    case .matrix: return MATRIX_ROW_GAP
    case .multline, .multlineAst: return ALIGN_ROW_GAP
    case .smallmatrix: return SMALLMATRIX_ROW_GAP
    case .substack: return SUBSTACK_ROW_GAP
    }
  }

  func getCellAlignments(_ rowCount: Int) -> CellAlignmentProvider {
    switch self {
    case .align, .alignAst, .aligned: return AlternateCellAlignmentProvider()
    case .cases: return FixedCellAlignmentProvider(.start)
    case .gather, .gatherAst, .gathered: return FixedCellAlignmentProvider(.center)
    case .matrix: return FixedCellAlignmentProvider(.center)
    case .multline, .multlineAst: return MultlineCellAlignmentProvider(rowCount)
    case .smallmatrix: return FixedCellAlignmentProvider(.center)
    case .substack: return FixedCellAlignmentProvider(.center)
    }
  }

  func getColumnGapCalculator(
    _ columns: Array<Array<MathListLayoutFragment>>,
    _ mathContext: MathContext
  ) -> ColumnGapProvider {
    let alignments = getCellAlignments(columns.first?.count ?? 0)
    switch self {
    case .align, .alignAst, .aligned:
      return AlignColumnGapProvider(columns, alignments, mathContext)
    case .cases: return MatrixColumnGapProvider(MATRIX_COL_GAP)
    case .gather, .gatherAst, .gathered: return PlaceholderColumnGapProvider()  // unused
    case .matrix: return MatrixColumnGapProvider(MATRIX_COL_GAP)
    case .multline, .multlineAst: return PlaceholderColumnGapProvider()  // unused
    case .smallmatrix: return MatrixColumnGapProvider(SMALLMATRIX_COL_GAP)
    case .substack: return PlaceholderColumnGapProvider()  // unused
    }
  }
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
/// Note that **Multline** is not a typo, it stands for the environment name in LaTeX.
private struct MultlineCellAlignmentProvider: CellAlignmentProvider {
  private let _rowCount: Int

  init(_ rowCount: Int) {
    self._rowCount = rowCount
  }

  func get(_ column: Int) -> FixedAlignment { .start }

  func get(_ row: Int, _ column: Int) -> FixedAlignment {
    row == 0
      ? .start
      : row == _rowCount - 1
        ? .end
        : .center
  }
}

// MARK: - Column Gaps

protocol ColumnGapProvider {
  /// Get the gap between the given column and its next column.
  /// - Precondition: `index\in [0,columnCount)`
  func get(_ columnIndex: Int) -> Em
}

/// Placeholder column gap provider, used when the column gap is not specified.
private struct PlaceholderColumnGapProvider: ColumnGapProvider {
  func get(_ columnIndex: Int) -> Em { MATRIX_COL_GAP }
}

private struct MatrixColumnGapProvider: ColumnGapProvider {
  private let _columnGap: Em

  init(_ columnGap: Em) {
    self._columnGap = columnGap
  }

  func get(_ columnIndex: Int) -> Em { _columnGap }
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

  func get(_ columnIndex: Int) -> Em {
    precondition(0..<_columns.count ~= columnIndex)

    guard columnIndex + 1 < _columns.count,
      _columnAlignments.get(columnIndex) == .end
        && _columnAlignments.get(columnIndex + 1) == .start
    else { return ALIGN_COL_GAP }

    let column = _columns[columnIndex]
    let nextColumn = _columns[columnIndex + 1]

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
