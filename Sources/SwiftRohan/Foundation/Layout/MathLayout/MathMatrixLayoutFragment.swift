// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation
import SatzAlgorithms
import TTFParser
import UnicodeMathClass

private let VERTICAL_PADDING = 0.1  // ratio
private let DEFAULT_STROKE_THICKNESS = Em(0.05)
private let DEFAULT_ROW_GAP = Em(0.2)
private let DEFAULT_COL_GAP = Em(0.5)

/// How much less high scaled delimiters can be than what they wrap.
private let DELIMITER_SHORTFALL = Em(0.1)

final class MathMatrixLayoutFragment: MathLayoutFragment {
  private let mathContext: MathContext
  private let delimiters: DelimiterPair

  private var _columns: Array<Array<MathListLayoutFragment>>
  private var _columnAlignments: ColumnAlignmentProvider
  private var _columnGapCalculator: ColumnGapCalculator.Type

  private var _composition: MathComposition

  /// y-coordinates of the (top) row edges from 0 to rowCount
  private var _rowEdges: Array<Double>
  /// x-coordinates of the (left) column edges from 0 to columnCount
  private var _columnEdges: Array<Double>

  var rowCount: Int { _columns.first?.count ?? 0 }
  var columnCount: Int { _columns.count }

  init(
    rowCount: Int, columnCount: Int,
    _ delimiters: DelimiterPair,
    _ columnAlignments: ColumnAlignmentProvider,
    _ columnGapCalculator: ColumnGapCalculator.Type,
    _ mathContext: MathContext
  ) {
    precondition(rowCount > 0 && columnCount > 0)

    let columns =
      (0..<columnCount).map { _ in
        (0..<rowCount).map { _ in MathListLayoutFragment(mathContext) }
      }

    self._columns = columns
    self.delimiters = delimiters
    self._columnAlignments = columnAlignments
    self._columnGapCalculator = columnGapCalculator
    self.mathContext = mathContext

    self._composition = MathComposition()
    self.glyphOrigin = .zero
    self._rowEdges = []
    self._columnEdges = []
  }

  // MARK: - Frame

  private(set) var glyphOrigin: CGPoint

  func setGlyphOrigin(_ origin: CGPoint) { self.glyphOrigin = origin }

  var layoutLength: Int { 1 }

  func draw(at point: CGPoint, in context: CGContext) {
    _composition.draw(at: point, in: context)
  }

  // MARK: - Metrics

  var width: Double { _composition.width }
  var height: Double { _composition.height }
  var ascent: Double { _composition.ascent }
  var descent: Double { _composition.descent }
  var italicsCorrection: Double { 0 }
  var accentAttachment: Double { width / 2 }

  var clazz: MathClass { .Normal }
  var limits: Limits { .never }

  var isSpaced: Bool { false }
  var isTextLike: Bool { false }

  // MARK: - Layout

  // Used by fixLayout()
  private struct Height {
    var ascent, descent: Double
    init(_ ascent: Double, _ descent: Double) {
      self.ascent = ascent
      self.descent = descent
    }
  }

  func fixLayout(_ mathContext: MathContext) {
    let font = mathContext.getFont()
    let table = mathContext.table
    let constants = mathContext.constants

    func metric(from mathValue: MathValueRecord) -> Double {
      font.convertToPoints(mathValue.value)
    }

    let axisHeight = metric(from: constants.axisHeight)
    let rowGap = font.convertToPoints(DEFAULT_ROW_GAP)
    let colGapCalculator =
      _columnGapCalculator.init(_columns, _columnAlignments, mathContext)

    // We pad ascent and descent with the ascent and descent of the paren
    // to ensure that normal matrices are aligned with others unless they are
    // way too big.
    let paren = GlyphFragment("(", font, table)!
    // This variable stores the maximum ascent and descent for each row.
    let heights: Array<Height> = {
      let value = Height(paren.ascent, paren.descent)
      var heights = Array(repeating: value, count: rowCount)
      for i in 0..<rowCount {
        for j in 0..<columnCount {
          let fragment = getElement(i, j)
          heights[i].ascent = max(heights[i].ascent, fragment.ascent)
          heights[i].descent = max(heights[i].descent, fragment.descent)
        }
      }
      return heights
    }()

    // For each row, combine maximum ascent and descent into a row height.
    // Sum the row heights, then add the total height of the gaps between rows.
    let total_height =
      heights.lazy.map { $0.ascent + $0.descent }.reduce(0, +)
      + Double(rowCount - 1) * rowGap
    var total_ascent = total_height / 2 + axisHeight
    var total_descent = total_height - total_ascent

    // compute row edges
    do {
      _rowEdges.removeAll(keepingCapacity: true)
      _rowEdges.reserveCapacity(rowCount + 1)
      var y = -total_ascent
      for i in 0..<rowCount {
        _rowEdges.append(y)
        y += heights[i].ascent + heights[i].descent + rowGap
      }
      y -= rowGap
      _rowEdges.append(y)
      assert(_rowEdges.count == rowCount + 1)
    }

    // layout delimiters
    let (left, right) = layoutDelimiters(total_height, mathContext)

    // x, y offsets for the matrix element
    let xDelta = left?.width ?? 0
    let yDelta = -(axisHeight + total_height / 2)

    var items: [MathComposition.Item] = []
    _columnEdges.removeAll(keepingCapacity: true)
    _columnEdges.reserveCapacity(columnCount + 1)

    var x = xDelta
    var colGap = 0.0
    for (j, col) in _columns.enumerated() {
      // add to column edges
      _columnEdges.append(x)

      let rcol = col.lazy.map(\.width).max() ?? 0

      var y = yDelta
      for (cell, height) in zip(col, heights) {
        let xx = x + _columnAlignments.get(j).position(rcol - cell.width)
        let yy = y + height.ascent
        let pos = CGPoint(x: xx, y: yy)

        // set the cell
        cell.setGlyphOrigin(pos)
        items.append((cell, pos))

        y += height.ascent + height.descent + rowGap
      }

      // Advance to the end of the column
      x += rcol
      // advance to the start of the next column
      colGap = font.convertToPoints(colGapCalculator.getColumnGap(j))
      x += colGap
    }

    // subtract the extra space at the end of the last column
    x -= colGap
    // add the last column edge
    _columnEdges.append(x)

    if let left = left {
      items.append((left, CGPoint.zero))

      // ignore adjusting x as it is already done

      // update total ascent and descent
      total_ascent = max(total_ascent, left.ascent)
      total_descent = max(total_descent, left.descent)
    }
    if let right = right {
      items.append((right, CGPoint(x: x, y: 0)))

      // adjust x
      x += right.width
      // update total ascent and descent
      total_ascent = max(total_ascent, right.ascent)
      total_descent = max(total_descent, right.descent)
    }

    _composition = MathComposition(
      width: x, ascent: total_ascent, descent: total_descent, items: items)
  }

  private func layoutDelimiters(
    _ height: Double, _ mathContext: MathContext
  ) -> (left: MathFragment?, right: MathFragment?) {
    let font = mathContext.getFont()
    let short_fall = font.convertToPoints(DELIMITER_SHORTFALL)
    let target = height + short_fall * VERTICAL_PADDING

    return LayoutUtils.layoutDelimiters(
      delimiters, target, shortfall: short_fall, mathContext)
  }

  func debugPrint(_ name: String?) -> Array<String> {
    let name = name ?? "matrix"
    let description = "\(name) \(boxDescription)"
    return PrintUtils.compose([description], [])
  }

  // MARK: - Edit

  func getElement(_ row: Int, _ column: Int) -> MathListLayoutFragment {
    self._columns[column][row]
  }

  func insertRow(at index: Int) {
    for j in 0..<columnCount {
      _columns[j].insert(MathListLayoutFragment(mathContext), at: index)
    }
  }

  func removeRow(at index: Int) {
    for j in 0..<columnCount {
      _columns[j].remove(at: index)
    }
  }

  func insertColumn(at index: Int) {
    let column = (0..<rowCount).map { _ in MathListLayoutFragment(mathContext) }
    _columns.insert(column, at: index)
  }

  func removeColumn(at index: Int) {
    _columns.remove(at: index)
  }

  // MARK: - Picking

  /// Resolve the point to a grid index.
  /// - Parameter point: The point to resolve in the coordinate system of the fragment.
  func getGridIndex(interactingAt point: CGPoint) -> GridIndex? {
    let i = Satz.upperBound(_rowEdges, point.y)
    let j = Satz.upperBound(_columnEdges, point.x)

    if i > 0, j > 0, i != _rowEdges.count, j != _columnEdges.count {
      return GridIndex(i - 1, j - 1)
    }
    return nil
  }

  /// Returns the rayshoot result for the given index.
  func rayshoot(
    from point: CGPoint, _ index: GridIndex,
    in direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    let i = index.row
    let j = index.column
    let eps = Rohan.tolerance

    switch direction {
    case .up:
      // if move up is possible
      if i > 0, rowCount != 0 {
        let ii = i - 1
        let fragment = getElement(ii, j)
        let x = point.x.clamped(fragment.minX + eps, fragment.maxX - eps)
        let y = fragment.maxY - eps
        return RayshootResult(CGPoint(x: x, y: y), true)
      }
      else {
        return RayshootResult(point.with(y: self.minY), false)
      }

    case .down:
      // if move down is possible
      if i + 1 < rowCount {
        let ii = i + 1
        let fragment = getElement(ii, j)
        let x = point.x.clamped(fragment.minX + eps, fragment.maxX - eps)
        let y = fragment.minY + eps
        return RayshootResult(CGPoint(x: x, y: y), true)
      }
      else {
        return RayshootResult(point.with(y: self.maxY), false)
      }

    default:
      assertionFailure("Unsupported direction")
      return nil
    }
  }
}

protocol ColumnGapCalculator {
  init(
    _ columns: Array<Array<MathListLayoutFragment>>,
    _ columnAlignments: ColumnAlignmentProvider,
    _ mathContext: MathContext)

  /// Get the gap between the given column and its next column.
  /// - Precondition: `index\in [0,columnCount)`
  func getColumnGap(_ index: Int) -> Em
}

struct DefaultColumnGapCalculator: ColumnGapCalculator {
  init(
    _ columns: Array<Array<MathListLayoutFragment>>,
    _ columnAlignments: ColumnAlignmentProvider,
    _ mathContext: MathContext
  ) {
    // no-op
  }

  func getColumnGap(_ index: Int) -> Em { DEFAULT_COL_GAP }
}

struct AlignedColumnGapCalculator: ColumnGapCalculator {
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

  func getColumnGap(_ index: Int) -> Em {
    precondition(0..<_columns.count ~= index)

    guard index + 1 < _columns.count,
      _columnAlignments.get(index) == .end
        && _columnAlignments.get(index + 1) == .start
    else { return DEFAULT_COL_GAP }

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
