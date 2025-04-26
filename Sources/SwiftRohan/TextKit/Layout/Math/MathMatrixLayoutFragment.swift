// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation
import SatzAlgorithms
import TTFParser
import UnicodeMathClass

private let VERTICAL_PADDING = 0.1  // ratio
private let DEFAULT_STROKE_THHICKNESS = Em(0.05)
private let DEFAULT_ROW_GAP = Em(0.2)
private let DEFAULT_COL_GAP = Em(0.5)

/// How much less high scaled delimiters can be than what they wrap.
private let DELIMITER_SHORTFALL = Em(0.1)

final class MathMatrixLayoutFragment: MathLayoutFragment {
  private let mathContext: MathContext
  private let delimiters: DelimiterPair

  private var columns: Array<Array<MathListLayoutFragment>>

  private var _composition: MathComposition

  /// y-coordinates of the (top) row edges from 0 to rowCount
  private var _rowEdges: Array<Double>
  /// x-coordinates of the (left) column edges from 0 to columnCount
  private var _columnEdges: Array<Double>

  var rowCount: Int { columns.first?.count ?? 0 }
  var columnCount: Int { columns.count }
  let align: FixedAlignment

  init(
    rowCount: Int, columnCount: Int,
    _ delimiters: DelimiterPair,
    _ align: FixedAlignment,
    _ mathContext: MathContext
  ) {
    let columns =
      (0..<columnCount).map { _ in
        (0..<rowCount).map { _ in MathListLayoutFragment(mathContext) }
      }

    self.columns = columns

    self.delimiters = delimiters
    self.align = align
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
    let colGap = font.convertToPoints(DEFAULT_COL_GAP)

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
    _columnEdges = []
    _columnEdges.reserveCapacity(columnCount + 1)

    var x = xDelta
    for (_, col) in columns.enumerated() {
      // add to column edges
      _columnEdges.append(x)

      // compute alignments
      let alignments = SwiftRohan.alignments(col)
      let points = alignments.points
      let rcol = alignments.width

      var y = yDelta
      for (cell, height) in zip(col, heights) {
        let xx =
          points.isEmpty
          ? x + align.position(rcol - cell.width)
          : x
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
    let shot_fall = font.convertToPoints(DELIMITER_SHORTFALL)
    let target = height + shot_fall * VERTICAL_PADDING

    func layout(_ char: Character) -> MathFragment? {
      let unicodeScalar = char.unicodeScalars.first!
      guard let fragment = GlyphFragment(unicodeScalar, font, mathContext.table)
      else { return nil }
      return fragment.stretchVertical(target, shortfall: shot_fall, mathContext)
    }

    let left: MathFragment? = delimiters.open.value.flatMap { layout($0) }
    let right: MathFragment? = delimiters.close.value.flatMap { layout($0) }
    return (left, right)
  }

  func debugPrint(_ name: String?) -> Array<String> {
    preconditionFailure()
  }

  // MARK: - Edit

  func getElement(_ row: Int, _ column: Int) -> MathListLayoutFragment {
    self.columns[column][row]
  }

  func insertRow(at index: Int) {
    for j in 0..<columnCount {
      columns[j].insert(MathListLayoutFragment(mathContext), at: index)
    }
  }

  func removeRow(at index: Int) {
    for j in 0..<columnCount {
      columns[j].remove(at: index)
    }
  }

  func insertColumn(at index: Int) {
    let column = (0..<rowCount).map { _ in MathListLayoutFragment(mathContext) }
    columns.insert(column, at: index)
  }

  func removeColumn(at index: Int) {
    columns.remove(at: index)
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
}

private struct AlignmentResult {
  let points: Array<Double>
  let width: Double

  init(_ points: Array<Double>, _ width: Double) {
    self.points = points
    self.width = width
  }
}

enum FixedAlignment {
  case start
  case center
  case end

  /// Returns the position of this alignment in a container with the given
  /// extent.
  func position(_ extent: Double) -> Double {
    switch self {
    case .start: return 0
    case .center: return extent / 2
    case .end: return extent
    }
  }
}

/// Determine the positions of the alignment points, according to the input rows combined.
private func alignments(_ rows: Array<MathListLayoutFragment>) -> AlignmentResult {
  var widths = Array<Double>()

  var pending_width = 0.0
  for row in rows {
    var width = 0.0
    var alignment_index = 0

    for fragment in row {
      if matchAlign(fragment) {
        if alignment_index < widths.count {
          widths[alignment_index] = max(widths[alignment_index], width)
        }
        else {
          widths.append(max(width, pending_width))
        }
        width = 0
        alignment_index += 1
      }
      else {
        width += fragment.width
      }
    }

    if widths.isEmpty {
      pending_width = max(pending_width, width)
    }
    else if alignment_index < widths.count {
      widths[alignment_index] = max(widths[alignment_index], width)
    }
    else {
      widths.append(max(width, pending_width))
    }
  }

  var points = widths
  if !points.isEmpty {
    for i in 1..<points.count {
      let prev = points[i - 1]
      points[i] += prev
    }
  }
  return AlignmentResult(points, points.last ?? pending_width)

  // Helper

  // TODO: match Align (&)
  func matchAlign(_ fragment: MathLayoutFragment) -> Bool { false }
}
