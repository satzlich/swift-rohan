// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

final class MatrixNode: Node {
  override class var type: NodeType { .matrix }

  typealias Row = MatrixRow<ContentNode>

  private var rows: Array<Row> = []

  var rowCount: Int { rows.count }

  var columnCount: Int { rows.first?.count ?? 0 }

  func getRow(_ row: Int) -> Row { return rows[row] }

  func get(_ row: Int, _ column: Int) -> ContentNode { return rows[row][column] }

  init(rows: Array<Row>) {
    self.rows = rows
    super.init()
    self._setUp()
  }

  init(deepCopyOf matrixNode: MatrixNode) {
    self.rows = matrixNode.rows.map { row in Row(row.map { $0.deepCopy() }) }
    super.init()
    self._setUp()
  }

  private final func _setUp() {
    for row in rows {
      for element in row {
        element.setParent(self)
      }
    }
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case rows }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    rows = try container.decode([Row].self, forKey: .rows)
    super.init()
    self._setUp()
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(rows, forKey: .rows)
    try super.encode(to: encoder)
  }

  // MARK: - Content

  override func getChild(_ index: RohanIndex) -> Node? {
    guard let index = index.gridIndex(),
      index.row < rowCount,
      index.column < columnCount
    else { return nil }
    return get(index.row, index.column)
  }

  override func contentDidChange(delta: LengthSummary, inStorage: Bool) {
    if inStorage { _isDirty = true }
    parent?.contentDidChange(delta: .zero, inStorage: inStorage)
  }

  override func stringify() -> BigString { "matrix" }

  private var operationLog: Array<MatrixEvent> = []

  func insertRow(at row: Int, inStorage: Bool) {
    precondition(row >= 0 && row <= rowCount)

    if inStorage { operationLog.append(.insertRow(at: row)) }

    fatalError("not implemented")
  }

  func insertColumn(at column: Int, inStorage: Bool) {
    precondition(column >= 0 && column < columnCount)

    if inStorage { operationLog.append(.insertColumn(at: column)) }

    fatalError("not implemented")
  }

  func removeRow(at row: Int, inStorage: Bool) {
    precondition(row >= 0 && row < rowCount)

    if inStorage { operationLog.append(.removeRow(at: row)) }

    fatalError("not implemented")
  }

  func removeColumn(at column: Int, inStorage: Bool) {
    precondition(column >= 0 && column < columnCount)

    if inStorage { operationLog.append(.removeColumn(at: column)) }

    fatalError("not implemented")
  }

  // MARK: - Location

  override func firstIndex() -> RohanIndex? {
    guard rowCount > 0, columnCount > 0 else { return nil }
    return .gridIndex(0, 0)
  }

  override func lastIndex() -> RohanIndex? {
    guard rowCount > 0, columnCount > 0 else { return nil }
    return .gridIndex(rowCount - 1, columnCount - 1)
  }

  // MARK: - Layout

  override func layoutLength() -> Int { 1 }

  override var isBlock: Bool { false }

  private var _isDirty: Bool = false
  override var isDirty: Bool { _isDirty }

  override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    preconditionFailure()
  }

  override func getLayoutOffset(_ index: RohanIndex) -> Int? {
    // layout offset for matrix is not well-defined and is unused
    nil
  }

  override func getRohanIndex(_ layoutOffset: Int) -> (RohanIndex, childOffset: Int)? {
    // layout offset for matrix is not well-defined and is unused
    nil
  }

  override func enumerateTextSegments(
    _ path: ArraySlice<RohanIndex>, _ endPath: ArraySlice<RohanIndex>,
    _ context: any LayoutContext, layoutOffset: Int, originCorrection: CGPoint,
    type: DocumentManager.SegmentType, options: DocumentManager.SegmentOptions,
    using block: (RhTextRange?, CGRect, CGFloat) -> Bool
  ) -> Bool {
    preconditionFailure()
  }

  override func resolveTextLocation(
    with point: CGPoint, _ context: any LayoutContext, _ trace: inout Trace,
    _ affinity: inout RhTextSelection.Affinity
  ) -> Bool {
    preconditionFailure()
  }

  override func rayshoot(
    from path: ArraySlice<RohanIndex>, affinity: RhTextSelection.Affinity,
    direction: TextSelectionNavigation.Direction, context: any LayoutContext,
    layoutOffset: Int
  ) -> RayshootResult? {
    preconditionFailure()
  }

  func getFragment(_ index: GridIndex) -> MathListLayoutFragment? {
    preconditionFailure()
  }

  func getGridIndex(interactingAt point: CGPoint) -> GridIndex? {
    preconditionFailure()
  }

  // MARK: - Styles

  override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      var properties = super.getProperties(styleSheet)

      // set math style ← matrix style
      let key = MathProperty.style
      let value = resolveProperty(key, styleSheet).mathStyle()!
      properties[key] = .mathStyle(MathUtils.matrixStyle(for: value))

      _cachedProperties = properties
    }
    return _cachedProperties!
  }

  override func resetCachedProperties(recursive: Bool) {
    super.resetCachedProperties(recursive: recursive)
    if recursive {
      for row in rows {
        for element in row {
          element.resetCachedProperties(recursive: recursive)
        }
      }
    }
  }

  // MARK: - Clone and Visitor

  override func deepCopy() -> MatrixNode { MatrixNode(deepCopyOf: self) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(matrix: self, context)
  }
}

private enum MatrixEvent {
  case insertRow(at: Int)
  case removeRow(at: Int)
  case insertColumn(at: Int)
  case removeColumn(at: Int)
}
