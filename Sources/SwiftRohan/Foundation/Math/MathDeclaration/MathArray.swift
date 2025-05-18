// Copyright 2024-2025 Lie Yan

import Foundation

private let ALIGN_ROW_GAP = Em(0.5)
private let ALIGN_COL_GAP = Em(1.0)
private let MATRIX_ROW_GAP = Em(0.3)
private let MATRIX_COL_GAP = Em(0.8)

struct MathArray: Codable, MathDeclarationProtocol {
  enum Subtype: Codable {
    case aligned
    case cases
    case matrix(DelimiterPair)

    var isMatrix: Bool {
      switch self {
      case .aligned, .cases: return false
      case .matrix: return true
      }
    }
  }

  let command: String
  let subtype: Subtype

  var isMatrix: Bool {
    subtype.isMatrix
  }

  var delimiters: DelimiterPair {
    switch subtype {
    case .aligned: return DelimiterPair.NONE
    case .cases: return DelimiterPair.LBRACE
    case .matrix(let delimiters): return delimiters
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
    case .matrix: return MATRIX_ROW_GAP
    }
  }

  func getColumnAlignments() -> ColumnAlignmentProvider {
    switch subtype {
    case .aligned: return AlternateColumnAlignmentProvider()
    case .cases: return FixedColumnAlignmentProvider(.start)
    case .matrix: return FixedColumnAlignmentProvider(.center)
    }
  }

  func getColumnGapCalculator(
    _ columns: Array<Array<MathListLayoutFragment>>,
    _ mathContext: MathContext
  ) -> ColumnGapProvider {
    let alignments = getColumnAlignments()

    switch subtype {
    case .aligned: return AlignColumnGapProvider(columns, alignments, mathContext)
    case .cases: return MatrixColumnGapProvider(columns, alignments, mathContext)
    case .matrix: return MatrixColumnGapProvider(columns, alignments, mathContext)
    }
  }
}

extension MathArray {
  static let predefinedCases: [MathArray] = [
    .aligned,
    .cases,
    .matrix,
    .pmatrix,
    .bmatrix,
    .Bmatrix,
    .vmatrix,
    .Vmatrix,
  ]

  private static let _dictionary: [String: MathArray] =
    Dictionary(uniqueKeysWithValues: predefinedCases.map { ($0.command, $0) })

  static func lookup(_ command: String) -> MathArray? {
    _dictionary[command]
  }

  static let aligned = MathArray("aligned", .aligned)
  static let cases = MathArray("cases", .cases)
  //
  static let matrix = MathArray("matrix", .matrix(DelimiterPair.NONE))
  static let pmatrix = MathArray("pmatrix", .matrix(DelimiterPair.PAREN))
  static let bmatrix = MathArray("bmatrix", .matrix(DelimiterPair.BRACKET))
  static let Bmatrix = MathArray("Bmatrix", .matrix(DelimiterPair.BRACE))
  static let vmatrix = MathArray("vmatrix", .matrix(DelimiterPair.VERT))
  static let Vmatrix = MathArray("Vmatrix", .matrix(DelimiterPair.DOUBLE_VERT))
}

protocol ColumnAlignmentProvider {
  func get(_ index: Int) -> FixedAlignment
}

private struct FixedColumnAlignmentProvider: ColumnAlignmentProvider {
  let alignment: FixedAlignment

  init(_ alignment: FixedAlignment) {
    self.alignment = alignment
  }

  func get(_ index: Int) -> FixedAlignment {
    return alignment
  }
}

private struct AlternateColumnAlignmentProvider: ColumnAlignmentProvider {
  func get(_ index: Int) -> FixedAlignment {
    return index % 2 == 0 ? .end : .start
  }
}

// MARK: - Column Gaps

protocol ColumnGapProvider {
  /// Get the gap between the given column and its next column.
  /// - Precondition: `index\in [0,columnCount)`
  func get(_ index: Int) -> Em
}

private struct MatrixColumnGapProvider: ColumnGapProvider {
  init(
    _ columns: Array<Array<MathListLayoutFragment>>,
    _ columnAlignments: ColumnAlignmentProvider,
    _ mathContext: MathContext
  ) {
    // no-op
  }

  func get(_ index: Int) -> Em { MATRIX_COL_GAP }
}

private struct AlignColumnGapProvider: ColumnGapProvider {
  private let _columns: Array<Array<MathListLayoutFragment>>
  private let _columnAlignments: ColumnAlignmentProvider
  private let _mathContext: MathContext

  init(
    _ columns: Array<Array<MathListLayoutFragment>>,
    _ columnAlignments: ColumnAlignmentProvider,
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
