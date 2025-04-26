// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

final class MatrixNode: Node {
  override class var type: NodeType { .matrix }

  typealias Element = ContentNode
  typealias Row = _MatrixRow<Element>

  private let delimiters: DelimiterPair
  private var rows: Array<Row> = []

  var rowCount: Int { rows.count }

  var columnCount: Int { rows.first?.count ?? 0 }

  func getRow(_ row: Int) -> Row { return rows[row] }

  func getElement(_ row: Int, _ column: Int) -> Element { return rows[row][column] }

  init(_ rows: Array<Row>, _ delimiters: DelimiterPair) {
    self.rows = rows
    self.delimiters = delimiters
    super.init()
    self._setUp()
  }

  init(deepCopyOf matrixNode: MatrixNode) {
    self.rows = matrixNode.rows.map { row in Row(row.map { $0.deepCopy() }) }
    self.delimiters = matrixNode.delimiters
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

  private enum CodingKeys: CodingKey { case rows, delimiters }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    rows = try container.decode([Row].self, forKey: .rows)
    delimiters = try container.decode(DelimiterPair.self, forKey: .delimiters)
    super.init()
    self._setUp()
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(rows, forKey: .rows)
    try container.encode(delimiters, forKey: .delimiters)
    try super.encode(to: encoder)
  }

  // MARK: - Content

  override func getChild(_ index: RohanIndex) -> Node? {
    guard let index = index.gridIndex(),
      index.row < rowCount,
      index.column < columnCount
    else { return nil }
    return getElement(index.row, index.column)
  }

  override func contentDidChange(delta: LengthSummary, inStorage: Bool) {
    if inStorage { _isDirty = true }
    parent?.contentDidChange(delta: .zero, inStorage: inStorage)
  }

  override func stringify() -> BigString { "matrix" }

  private var _editLog: Array<MatrixEvent> = []
  private var _addedNodes: Set<NodeIdentifier> = []

  func insertRow(at index: Int, inStorage: Bool) {
    precondition(index >= 0 && index <= rowCount)

    let elements = (0..<columnCount).map { _ in Element() }

    if inStorage {
      _editLog.append(.insertRow(at: index))
      elements.forEach { _addedNodes.insert($0.id) }
    }

    elements.forEach { $0.setParent(self) }
    rows.insert(Row(elements), at: index)

    self.contentDidChange(delta: .zero, inStorage: inStorage)
  }

  func insertColumn(at index: Int, inStorage: Bool) {
    precondition(index >= 0 && index < columnCount)

    let elements = (0..<rowCount).map { _ in Element() }

    if inStorage {
      _editLog.append(.insertColumn(at: index))
      elements.forEach { _addedNodes.insert($0.id) }
    }

    elements.forEach { $0.setParent(self) }

    for i in (0..<rowCount) {
      rows[i].insert(elements[i], at: index)
    }

    self.contentDidChange(delta: .zero, inStorage: inStorage)
  }

  func removeRow(at index: Int, inStorage: Bool) {
    precondition(index >= 0 && index < rowCount)

    if inStorage {
      _editLog.append(.removeRow(at: index))
    }

    rows.remove(at: index)

    self.contentDidChange(delta: .zero, inStorage: inStorage)
  }

  func removeColumn(at index: Int, inStorage: Bool) {
    precondition(index >= 0 && index < columnCount)

    if inStorage {
      _editLog.append(.removeColumn(at: index))
    }

    for i in (0..<rowCount) {
      _ = rows[i].remove(at: index)
    }

    self.contentDidChange(delta: .zero, inStorage: inStorage)
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

  func destinationIndex(
    for index: GridIndex, _ direction: TextSelectionNavigation.Direction
  ) -> GridIndex? {
    var row = index.row
    var column = index.column

    switch direction {
    case .forward:
      if column + 1 < columnCount {
        column += 1
      }
      else if row + 1 < rowCount {
        row += 1
        column = 0
      }
      else {
        return nil
      }
      return GridIndex(row, column)

    case .backward:
      if column > 0 {
        column -= 1
      }
      else if row > 0 {
        row -= 1
        column = columnCount - 1
      }
      else {
        return nil
      }
      return GridIndex(row, column)

    default:
      assertionFailure("unsupported direction")
      return nil
    }
  }

  // MARK: - Layout

  override func layoutLength() -> Int { 1 }

  override var isBlock: Bool { false }

  private var _isDirty: Bool = false
  override var isDirty: Bool { _isDirty }

  private var _matrixFragment: MathMatrixLayoutFragment? = nil

  var layoutFragment: MathLayoutFragment? { _matrixFragment }

  override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    precondition(context is MathListLayoutContext)
    let context = context as! MathListLayoutContext
    let mathContext = context.mathContext

    if fromScratch {
      let matrixFragment = MathMatrixLayoutFragment(
        rowCount: rowCount, columnCount: columnCount, delimiters, .center, mathContext)
      _matrixFragment = matrixFragment

      // layout each element
      for i in (0..<rowCount) {
        for j in (0..<columnCount) {
          let element = getElement(i, j)
          let fragment = matrixFragment.getElement(i, j)
          LayoutUtils.reconcileFragmentEcon(
            element, fragment, parent: context, fromScratch: true)
        }
      }
      // layout the matrix
      matrixFragment.fixLayout(mathContext)
      // insert the matrix fragment
      context.insertFragment(matrixFragment, self)
    }
    else {
      assert(_matrixFragment != nil)
      let matrixFragment = _matrixFragment!

      // play edit log
      for event in _editLog {
        switch event {
        case let .insertRow(at: index):
          matrixFragment.insertRow(at: index)
        case let .removeRow(at: index):
          matrixFragment.removeRow(at: index)
        case let .insertColumn(at: index):
          matrixFragment.insertColumn(at: index)
        case let .removeColumn(at: index):
          matrixFragment.removeColumn(at: index)
        }
      }

      var needsFixLayout = false
      // layout each element
      if _isDirty {
        for i in (0..<rowCount) {
          for j in (0..<columnCount) {
            let element = getElement(i, j)
            let fragment = matrixFragment.getElement(i, j)
            if _addedNodes.contains(element.id) {
              LayoutUtils.reconcileFragmentEcon(
                element, fragment, parent: context, fromScratch: true)
              needsFixLayout = true
            }
            else if element.isDirty {
              let bounds = fragment.bounds
              LayoutUtils.reconcileFragmentEcon(
                element, fragment, parent: context, fromScratch: false)
              if bounds.isNearlyEqual(to: fragment.bounds) == false {
                needsFixLayout = true
              }
            }
          }
        }
      }

      if needsFixLayout {
        let bounds = matrixFragment.bounds
        matrixFragment.fixLayout(mathContext)
        if bounds.isNearlyEqual(to: matrixFragment.bounds) == false {
          context.invalidateBackwards(layoutLength())
        }
        else {
          context.skipBackwards(layoutLength())
        }
      }
      else {
        context.skipBackwards(layoutLength())
      }
    }

    // clear
    _isDirty = false
    _editLog = []
    _addedNodes = []
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
    _matrixFragment?.getElement(index.row, index.column)
  }

  func getGridIndex(interactingAt point: CGPoint) -> GridIndex? {
    _matrixFragment?.getGridIndex(interactingAt: point)
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

extension MatrixNode.Row {
  init(_ elements: [[Node]]) {
    self.init(elements.map { MatrixNode.Element($0) })
  }
}
