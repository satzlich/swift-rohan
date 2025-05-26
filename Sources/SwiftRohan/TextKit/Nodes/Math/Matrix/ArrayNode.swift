// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

class ArrayNode: Node {
  typealias Cell = ContentNode
  typealias Row = GridRow<Cell>

  typealias Subtype = ArrayExpr.Subtype

  private enum ArrayEvent {
    case insertRow(at: Int)
    case insertColumn(at: Int)
    case removeRow(at: Int)
    case removeColumn(at: Int)
  }

  internal let subtype: Subtype
  internal var _rows: Array<Row> = []

  final var rowCount: Int { _rows.count }
  final var columnCount: Int { _rows.first?.count ?? 0 }

  /// Returns the row at given index.
  final func getRow(at index: Int) -> Row { return _rows[index] }

  /// Returns the element at the specified row and column.
  /// - Precondition: `row` and `column` must be within bounds.
  final func getElement(_ row: Int, _ column: Int) -> Cell {
    return _rows[row][column]
  }

  init(_ subtype: Subtype, _ rows: Array<Row>) {
    precondition(ArrayNode.validate(rows: rows, subtype: subtype))
    self.subtype = subtype
    self._rows = rows
    super.init()
    self._setUp()
  }

  init(deepCopyOf node: ArrayNode) {
    self.subtype = node.subtype
    self._rows = node._rows.map { row in Row(row.map { $0.deepCopy() }) }
    super.init()
    self._setUp()
  }

  private final func _setUp() {
    for row in _rows {
      for element in row {
        element.setParent(self)
      }
    }
  }

  required init(from decoder: any Decoder) throws {
    preconditionFailure("should not be called")
  }

  private static func validate(rows: Array<Row>) -> Bool {
    guard rows.isEmpty == false,
      rows[0].isEmpty == false
    else { return false }

    let columnCount = rows[0].count

    guard rows.dropFirst().allSatisfy({ $0.count == columnCount })
    else { return false }

    return true
  }

  static func validate(rows: Array<Row>, subtype: Subtype) -> Bool {
    validate(rows: rows)
      && (subtype.isMultiColumnEnabled || rows[0].count == 1)
  }

  // MARK: - Content

  final override func getChild(_ index: RohanIndex) -> Node? {
    guard let index = index.gridIndex() else { return nil }
    return getComponent(index)
  }

  final func getComponent(_ index: GridIndex) -> Cell? {
    guard index.row < rowCount,
      index.column < columnCount
    else { return nil }
    return _rows[index.row][index.column]
  }

  override func contentDidChange(delta: LengthSummary, inStorage: Bool) {
    if inStorage { _isDirty = true }
    parent?.contentDidChange(delta: .zero, inStorage: inStorage)
  }

  private var _editLog: Array<ArrayEvent> = []
  private var _addedNodes: Set<NodeIdentifier> = []

  final func insertRow(at index: Int, inStorage: Bool) {
    precondition(index >= 0 && index <= rowCount)

    let elements = (0..<columnCount).map { _ in Cell() }

    if inStorage {
      _editLog.append(.insertRow(at: index))
      elements.forEach { _addedNodes.insert($0.id) }
    }

    elements.forEach { $0.setParent(self) }
    _rows.insert(Row(elements), at: index)

    contentDidChange(delta: .zero, inStorage: inStorage)
  }

  final func removeRow(at index: Int, inStorage: Bool) {
    precondition(index >= 0 && index < rowCount)

    if inStorage {
      _editLog.append(.removeRow(at: index))
    }

    _rows.remove(at: index)

    contentDidChange(delta: .zero, inStorage: inStorage)
  }

  func insertColumn(at index: Int, inStorage: Bool) {
    precondition(index >= 0 && index <= columnCount)

    let elements = (0..<rowCount).map { _ in Cell() }

    if inStorage {
      _editLog.append(.insertColumn(at: index))
      elements.forEach { _addedNodes.insert($0.id) }
    }

    elements.forEach { $0.setParent(self) }

    for i in (0..<rowCount) {
      _rows[i].insert(elements[i], at: index)
    }

    self.contentDidChange(delta: .zero, inStorage: inStorage)
  }

  func removeColumn(at index: Int, inStorage: Bool) {
    precondition(index >= 0 && index < columnCount)

    if inStorage {
      _editLog.append(.removeColumn(at: index))
    }

    for i in (0..<rowCount) {
      _ = _rows[i].remove(at: index)
    }

    self.contentDidChange(delta: .zero, inStorage: inStorage)
  }

  // MARK: - Location

  final override func firstIndex() -> RohanIndex? {
    guard rowCount > 0, columnCount > 0 else { return nil }
    return .gridIndex(0, 0)
  }

  final override func lastIndex() -> RohanIndex? {
    guard rowCount > 0, columnCount > 0 else { return nil }
    return .gridIndex(rowCount - 1, columnCount - 1)
  }

  final func destinationIndex(
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

  final override func layoutLength() -> Int { 1 }

  final override var isBlock: Bool { false }

  private var _isDirty: Bool = false
  final override var isDirty: Bool { _isDirty }

  private var _matrixFragment: MathArrayLayoutFragment? = nil

  final var layoutFragment: MathLayoutFragment? { _matrixFragment }

  final override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    precondition(context is MathListLayoutContext)
    let context = context as! MathListLayoutContext
    let mathContext = context.mathContext

    if fromScratch {
      let matrixFragment = MathArrayLayoutFragment(
        rowCount: rowCount, columnCount: columnCount, subtype: subtype, mathContext)
      _matrixFragment = matrixFragment

      // layout each element
      for i in (0..<rowCount) {
        for j in (0..<columnCount) {
          let element = getElement(i, j)
          let fragment = matrixFragment.getElement(i, j)
          LayoutUtils.reconcileMathListLayoutFragmentEcon(
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

      // save metrics before any layout changes
      let oldMetrics = matrixFragment.boxMetrics
      var needsFixLayout = false

      // play edit log
      needsFixLayout = !_editLog.isEmpty
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

      // layout each element
      if _isDirty {
        for i in (0..<rowCount) {
          for j in (0..<columnCount) {
            let element = getElement(i, j)
            let fragment = matrixFragment.getElement(i, j)
            if _addedNodes.contains(element.id) {
              LayoutUtils.reconcileMathListLayoutFragmentEcon(
                element, fragment, parent: context, fromScratch: true)
              needsFixLayout = true
            }
            else if element.isDirty {
              let oldMetrics = fragment.boxMetrics
              LayoutUtils.reconcileMathListLayoutFragmentEcon(
                element, fragment, parent: context, fromScratch: false)
              if fragment.isNearlyEqual(to: oldMetrics) == false {
                needsFixLayout = true
              }
            }
          }
        }
      }

      if needsFixLayout {
        matrixFragment.fixLayout(mathContext)
        if matrixFragment.isNearlyEqual(to: oldMetrics) == false {
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

  final override func getLayoutOffset(_ index: RohanIndex) -> Int? {
    // layout offset for matrix is not well-defined and is unused
    nil
  }

  final override func getRohanIndex(
    _ layoutOffset: Int
  ) -> (RohanIndex, childOffset: Int)? {
    // layout offset for matrix is not well-defined and is unused
    nil
  }

  final override func enumerateTextSegments(
    _ path: ArraySlice<RohanIndex>, _ endPath: ArraySlice<RohanIndex>,
    _ context: any LayoutContext, layoutOffset: Int, originCorrection: CGPoint,
    type: DocumentManager.SegmentType, options: DocumentManager.SegmentOptions,
    using block: (RhTextRange?, CGRect, CGFloat) -> Bool
  ) -> Bool {
    guard path.count >= 2,
      endPath.count >= 2,
      let index: GridIndex = path.first?.gridIndex(),
      let endIndex: GridIndex = endPath.first?.gridIndex(),
      // must not fork
      index == endIndex,
      let component = getComponent(index),
      let fragment = getFragment(index)
    else { return false }

    // obtain super frame with given layout offset (affinity can be arbitrary)
    guard let superFrame = context.getSegmentFrame(for: layoutOffset, .downstream, self)
    else { return false }
    // set new layout offset
    let layoutOffset = 0
    // compute new origin correction
    let originCorrection: CGPoint =
      originCorrection.translated(by: superFrame.frame.origin)
      .with(yDelta: superFrame.baselinePosition)  // relative to glyph origin of super frame
      .translated(by: fragment.glyphOrigin)
      .with(yDelta: -fragment.ascent)  // relative to glyph origin of fragment

    let newContext =
      LayoutUtils.createMathListLayoutContext(for: component, fragment, parent: context)
    return component.enumerateTextSegments(
      path.dropFirst(), endPath.dropFirst(), newContext,
      layoutOffset: layoutOffset, originCorrection: originCorrection,
      type: type, options: options, using: block)
  }

  final override func resolveTextLocation(
    with point: CGPoint, _ context: any LayoutContext, _ trace: inout Trace,
    _ affinity: inout RhTextSelection.Affinity
  ) -> Bool {
    // resolve grid index for point
    guard let index: GridIndex = getGridIndex(interactingAt: point),
      let component = getComponent(index),
      let fragment = getFragment(index)
    else { return false }
    // create sub-context
    let newContext =
      LayoutUtils.createMathListLayoutContext(for: component, fragment, parent: context)
    let relPoint = {
      // top-left corner of component fragment relative to container fragment
      // in the glyph coordinate sytem of container fragment
      let frameOrigin = fragment.glyphOrigin.with(yDelta: -fragment.ascent)
      // convert to relative position to top-left corner of component fragment
      return point.relative(to: frameOrigin)
    }()
    // append to trace
    trace.emplaceBack(self, .gridIndex(index))
    // recurse
    let modified =
      component.resolveTextLocation(with: relPoint, newContext, &trace, &affinity)
    // fix accordingly
    if !modified {
      trace.emplaceBack(component, .index(0))
    }
    return true
  }

  final override func rayshoot(
    from path: ArraySlice<RohanIndex>, affinity: RhTextSelection.Affinity,
    direction: TextSelectionNavigation.Direction, context: any LayoutContext,
    layoutOffset: Int
  ) -> RayshootResult? {
    guard path.count >= 2,
      let index: GridIndex = path.first?.gridIndex(),
      let component = getComponent(index),
      let fragment = getFragment(index)
    else { return nil }
    // obtain super frame with given layout offset
    guard let superFrame = context.getSegmentFrame(for: layoutOffset, affinity, self)
    else { return nil }
    // create sub-context
    let newContext =
      LayoutUtils.createMathListLayoutContext(for: component, fragment, parent: context)
    // rayshoot in the component with layout offset reset to "0"
    let componentResult = component.rayshoot(
      from: path.dropFirst(), affinity: affinity, direction: direction,
      context: newContext, layoutOffset: 0)
    guard let componentResult else { return nil }
    // if resolved, return origin-corrected result
    guard componentResult.isResolved == false else {
      // compute origin correction
      let originCorrection: CGPoint =
        superFrame.frame.origin
        // relative to glyph origin of super frame
        .with(yDelta: superFrame.baselinePosition)
        // relative to top-left corner of fragment (translate + yDelta)
        .translated(by: fragment.glyphOrigin)
        .with(yDelta: -fragment.ascent)

      let corrected = componentResult.position.translated(by: originCorrection)
      return componentResult.with(position: corrected)
    }
    // otherwise, rayshoot in the node

    // convert to position relative to glyph origin of the fragment of the node
    let relPosition =
      componentResult.position
      // relative to glyph origin of the fragment of the component
      .with(yDelta: -fragment.ascent)
      // relative to glyph origin of the fragment of the node
      .translated(by: fragment.glyphOrigin)

    guard let nodeResult = self.rayshoot(from: relPosition, index, in: direction)
    else { return nil }

    // compute origin correction
    let originCorrection: CGPoint =
      superFrame.frame.origin
      // relative to glyph origin of super frame
      .with(yDelta: superFrame.baselinePosition)
    // return corrected result
    let corrected = nodeResult.position.translated(by: originCorrection)
    return nodeResult.with(position: corrected)
  }

  private func getFragment(_ index: GridIndex) -> MathListLayoutFragment? {
    guard let matrixFragment = _matrixFragment,
      index.row < rowCount,
      index.column < columnCount
    else { return nil }
    return matrixFragment.getElement(index.row, index.column)
  }

  private func getGridIndex(interactingAt point: CGPoint) -> GridIndex? {
    _matrixFragment?.getGridIndex(interactingAt: point)
  }

  private func rayshoot(
    from point: CGPoint, _ index: GridIndex,
    in direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    _matrixFragment?.rayshoot(from: point, index, in: direction)
  }

  // MARK: - Styles

  final override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      var properties = super.getProperties(styleSheet)
      let key = MathProperty.style
      let value = resolveProperty(key, styleSheet).mathStyle()!
      switch subtype.subtype {
      case .matrix, .cases:
        properties[key] = .mathStyle(MathUtils.matrixStyle(for: value))
      case .aligned:
        properties[key] = .mathStyle(MathUtils.alignedStyle(for: value))
      }

      _cachedProperties = properties
    }
    return _cachedProperties!
  }

  final override func resetCachedProperties(recursive: Bool) {
    super.resetCachedProperties(recursive: recursive)
    if recursive {
      for row in _rows {
        for element in row {
          element.resetCachedProperties(recursive: recursive)
        }
      }
    }
  }
}
