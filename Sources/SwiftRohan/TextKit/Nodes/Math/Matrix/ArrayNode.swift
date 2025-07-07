// Copyright 2024-2025 Lie Yan

import Foundation
import UnicodeMathClass
import _RopeModule

class ArrayNode: Node {
  // MARK: - Node(Styles)

  final override func resetCachedProperties() {
    super.resetCachedProperties()
    for row in _rows {
      for cell in row {
        cell.resetCachedProperties()
      }
    }
  }

  internal override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      var current = super.getProperties(styleSheet)

      do {
        let key = MathProperty.style
        let value = key.resolveValue(current, styleSheet).mathStyle()!
        let mathStyle =
          switch subtype.subtype {
          case .align, .aligned: MathUtils.alignedStyle(for: value)
          case .gather, .gathered: MathUtils.gatheredStyle(for: value)
          case .multline, .multlineAst: MathUtils.multlineStyle(for: value)
          case .cases: MathUtils.matrixStyle(for: value)
          case .matrix: MathUtils.matrixStyle(for: value)
          case .substack: MathUtils.matrixStyle(for: value)
          }
        current[key] = .mathStyle(mathStyle)
      }

      _cachedProperties = current
    }
    return _cachedProperties!
  }

  // MARK: - Node(Positioning)

  final override func getChild(_ index: RohanIndex) -> Node? {
    guard let index = index.gridIndex() else { return nil }
    return self.getCell(index)
  }

  final override func firstIndex() -> RohanIndex? {
    guard rowCount > 0, columnCount > 0 else { return nil }
    return .gridIndex(0, 0)
  }

  final override func lastIndex() -> RohanIndex? {
    guard rowCount > 0, columnCount > 0 else { return nil }
    return .gridIndex(rowCount - 1, columnCount - 1)
  }

  final override func getLayoutOffset(_ index: RohanIndex) -> Int? {
    // layout offset for matrix is not well-defined and is unused
    nil
  }

  final override func getPosition(_ layoutOffset: Int) -> PositionResult<RohanIndex> {
    // layout offset for matrix is not well-defined and is unused
    .null
  }

  // MARK: - Node(Layout)

  final override func contentDidChange() {
    guard _isCellDirty == false else { return }

    _isCellDirty = true
    parent?.contentDidChange()
  }

  /// Content did change but not for a cell.
  internal func contentDidChange(nonCell: Void) {
    guard self.isDirty == false else { return }
    parent?.contentDidChange()
  }

  final override func layoutLength() -> Int { 1 }

  internal override var isDirty: Bool { _isCellDirty }

  internal override func performLayout(
    _ context: any LayoutContext, fromScratch: Bool
  ) -> Int {
    // MathReflowLayoutContext is not used for layout, though it is used for
    // other methods such as rayshoot(), etc.
    precondition(context is MathListLayoutContext || context is TextLayoutContext)

    let mathContext = _createMathContext(context)

    if fromScratch {
      let nodeFragment = _createMathArrayLayoutFragment(context, mathContext)
      _nodeFragment = nodeFragment

      // layout each element
      for i in (0..<rowCount) {
        for j in (0..<columnCount) {
          let element = getElement(i, j)
          let fragment = nodeFragment.getElement(i, j)

          _reconcileMathListLayoutFragment(
            element, fragment, parent: context,
            fromScratch: true, previousClass: _previousClass(i, j))
        }
      }
      // layout the matrix
      nodeFragment.fixLayout(mathContext)
      // insert the matrix fragment
      context.insertFragment(nodeFragment, self)
    }
    else {
      assert(_nodeFragment != nil)
      let nodeFragment = _nodeFragment!

      // save metrics before any layout changes
      let oldMetrics = nodeFragment.boxMetrics
      var needsFixLayout = nodeFragment.needsLayout

      // play edit log
      needsFixLayout = needsFixLayout || _applyEditLogToFragment(nodeFragment)

      // layout each element
      if _isCellDirty {
        for i in (0..<rowCount) {
          for j in (0..<columnCount) {
            let element = getElement(i, j)
            let fragment = nodeFragment.getElement(i, j)
            if _addedNodes.contains(element.id) {
              _reconcileMathListLayoutFragment(
                element, fragment, parent: context,
                fromScratch: true, previousClass: _previousClass(i, j))
              needsFixLayout = true
            }
            else if element.isDirty {
              let oldMetrics = fragment.boxMetrics
              _reconcileMathListLayoutFragment(
                element, fragment, parent: context,
                fromScratch: false, previousClass: _previousClass(i, j))
              if fragment.isNearlyEqual(to: oldMetrics) == false {
                needsFixLayout = true
              }
            }
          }
        }
      }

      if needsFixLayout {
        nodeFragment.fixLayout(mathContext)
        if nodeFragment.isNearlyEqual(to: oldMetrics) == false {
          context.invalidateForward(1)
        }
        else {
          context.skipForward(1)
        }
      }
      else {
        context.skipForward(1)
      }
    }

    // clear
    _isCellDirty = false
    _editLog.removeAll()
    _addedNodes.removeAll()

    return 1
  }

  // MARK: - Node(Codable)

  private enum CodingKeys: CodingKey { case rows, command }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    let command = try container.decode(String.self, forKey: .command)

    guard let subtype = MathArray.lookup(command) else {
      throw DecodingError.dataCorruptedError(
        forKey: .command, in: container,
        debugDescription: "Invalid matrix command: \(command)")
    }

    let rows = try container.decode(Array<Row>.self, forKey: .rows)

    guard ArrayNode.validate(rows: rows, subtype: subtype) else {
      throw DecodingError.dataCorruptedError(
        forKey: .rows, in: container,
        debugDescription: "Invalid matrix rows")
    }

    self.subtype = subtype
    self._rows = rows
    super.init()
    self._setUp()
  }

  final override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(subtype.command, forKey: .command)
    try container.encode(_rows, forKey: .rows)
    try super.encode(to: encoder)
  }

  // MARK: - Node(Tree API)

  final override func enumerateTextSegments(
    _ path: ArraySlice<RohanIndex>, _ endPath: ArraySlice<RohanIndex>,
    context: any LayoutContext, layoutOffset: Int, originCorrection: CGPoint,
    type: DocumentManager.SegmentType, options: DocumentManager.SegmentOptions,
    using block: (RhTextRange?, CGRect, CGFloat) -> Bool
  ) -> Bool {
    precondition(
      context is MathListLayoutContext || context is MathReflowLayoutContext
        || context is TextLayoutContext)

    guard path.count >= 2,
      endPath.count >= 2,
      let index: GridIndex = path.first?.gridIndex(),
      let endIndex: GridIndex = endPath.first?.gridIndex(),
      // must not fork
      index == endIndex,
      let component = getCell(index),
      let fragment = getFragment(index)
    else { return false }

    // query with affinity=downstream.
    guard let superFrame = self.getSegmentFrame(context, layoutOffset, .downstream)
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
      LayoutUtils.safeInitMathListLayoutContext(for: component, fragment, parent: context)
    return component.enumerateTextSegments(
      path.dropFirst(), endPath.dropFirst(), context: newContext,
      layoutOffset: layoutOffset, originCorrection: originCorrection,
      type: type, options: options, using: block)
  }

  internal override func resolveTextLocation(
    with point: CGPoint, context: any LayoutContext, layoutOffset: Int,
    trace: inout Trace, affinity: inout SelectionAffinity
  ) -> Bool {
    precondition(
      context is MathListLayoutContext || context is MathReflowLayoutContext
        || context is TextLayoutContext)

    // resolve grid index for point
    guard let point = convertToLocal(point, context, layoutOffset),
      let index: GridIndex = getGridIndex(interactingAt: point),
      let component = getCell(index),
      let fragment = getFragment(index)
    else { return false }
    // create sub-context
    let newContext =
      LayoutUtils.safeInitMathListLayoutContext(for: component, fragment, parent: context)
    let relPoint: CGPoint
    do {
      // top-left corner of component fragment relative to container fragment
      // in the glyph coordinate sytem of container fragment
      let frameOrigin = fragment.glyphOrigin.with(yDelta: -fragment.ascent)
      // convert to relative position to top-left corner of component fragment
      relPoint = point.relative(to: frameOrigin)
    }
    // append to trace
    trace.emplaceBack(self, .gridIndex(index))
    // recurse
    let modified =
      component.resolveTextLocation(
        with: relPoint, context: newContext, layoutOffset: 0,
        trace: &trace, affinity: &affinity)
    // fix accordingly
    if !modified { trace.emplaceBack(component, .index(0)) }
    return true
  }

  final override func rayshoot(
    from path: ArraySlice<RohanIndex>, affinity: SelectionAffinity,
    direction: TextSelectionNavigation.Direction, context: any LayoutContext,
    layoutOffset: Int
  ) -> RayshootResult? {
    precondition(
      context is MathListLayoutContext || context is MathReflowLayoutContext
        || context is TextLayoutContext)

    guard path.count >= 2,
      let index: GridIndex = path.first?.gridIndex(),
      let component = getCell(index),
      let fragment = getFragment(index)
    else { return nil }

    // create sub-context
    let newContext =
      LayoutUtils.safeInitMathListLayoutContext(for: component, fragment, parent: context)
    // rayshoot in the component with layout offset reset to "0"
    guard
      let componentResult = component.rayshoot(
        from: path.dropFirst(), affinity: affinity, direction: direction,
        context: newContext, layoutOffset: 0)
    else { return nil }

    // query with affinity=downstream.
    guard let superFrame = self.getSegmentFrame(context, layoutOffset, .downstream)
    else { return nil }

    // if resolved, return origin-corrected result
    if componentResult.isResolved {
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
    assert(componentResult.isResolved == false)

    // convert to position relative to glyph origin of the fragment of the node
    let relPosition =
      componentResult.position
      // relative to glyph origin of the fragment of the component
      .with(yDelta: -fragment.ascent)
      // relative to glyph origin of the fragment of the node
      .translated(by: fragment.glyphOrigin)

    guard let nodeResult = self.rayshoot(from: relPosition, index, in: direction)
    else { return nil }

    // if resolved or not equation node, return corrected result.
    if nodeResult.isResolved || !shouldRelayRayshoot(context) {
      // compute origin correction
      let originCorrection: CGPoint =
        superFrame.frame.origin
        // relative to glyph origin of super frame
        .with(yDelta: superFrame.baselinePosition)

      let corrected = nodeResult.position.translated(by: originCorrection)
      return nodeResult.with(position: corrected)
    }
    // otherwise, return top/bottom position of the super frame.
    else {
      let x = nodeResult.position.x + superFrame.frame.origin.x
      let y = direction == .up ? superFrame.frame.minY : superFrame.frame.maxY
      // The resolved flag is set to false to ensure that rayshot relay
      // is performed below.
      let result = RayshootResult(CGPoint(x: x, y: y), false)
      // query with "downstream" affinity.
      return LayoutUtils.relayRayshoot(
        layoutOffset, .downstream, direction, result, context)
    }
  }

  // MARK: - ArrayNode

  typealias Cell = ContentNode
  typealias Row = GridRow<Cell>

  internal enum _ArrayEvent {
    case insertRow(at: Int)
    case insertColumn(at: Int)
    case removeRow(at: Int)
    case removeColumn(at: Int)
  }

  let subtype: MathArray
  internal var _rows: Array<Row> = []

  /// True if any of the cells is dirty.
  internal var _isCellDirty: Bool = false

  internal var _nodeFragment: MathArrayLayoutFragment? = nil
  final var layoutFragment: MathLayoutFragment? { _nodeFragment }

  final var rowCount: Int { _rows.count }
  final var columnCount: Int { _rows.first?.count ?? 0 }
  final var isMultiColumnEnabled: Bool { subtype.isMultiColumnEnabled }

  /// Returns the row at given index.
  final func getRow(at index: Int) -> Row { _rows[index] }

  /// Returns the element at the specified row and column.
  /// - Precondition: `row` and `column` must be within bounds.
  final func getElement(_ row: Int, _ column: Int) -> Cell {
    _rows[row][column]
  }

  init(_ subtype: MathArray, _ rows: Array<Row>) {
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

  private static func validate(rows: Array<Row>) -> Bool {
    guard rows.isEmpty == false,
      rows[0].isEmpty == false
    else { return false }

    let columnCount = rows[0].count

    guard rows.dropFirst().allSatisfy({ $0.count == columnCount })
    else { return false }

    return true
  }

  static func validate(rows: Array<Row>, subtype: MathArray) -> Bool {
    validate(rows: rows)
      && (subtype.isMultiColumnEnabled || rows[0].count == 1)
  }

  // MARK: - Content

  final func getCell(_ index: GridIndex) -> Cell? {
    guard index.row < rowCount,
      index.column < columnCount
    else { return nil }
    return _rows[index.row][index.column]
  }

  internal var _editLog: Array<_ArrayEvent> = []
  internal var _addedNodes: Set<NodeIdentifier> = []

  final func insertRow(at index: Int, inStorage: Bool) {
    precondition(index >= 0 && index <= rowCount)

    let elements = (0..<columnCount).map { _ in Cell() }

    if inStorage {
      _editLog.append(.insertRow(at: index))
      elements.forEach { _addedNodes.insert($0.id) }
    }

    elements.forEach { $0.setParent(self) }
    _rows.insert(Row(elements), at: index)

    if inStorage { contentDidChange() }
  }

  final func removeRow(at index: Int, inStorage: Bool) {
    precondition(index >= 0 && index < rowCount)

    if inStorage { _editLog.append(.removeRow(at: index)) }

    _rows.remove(at: index)

    if inStorage { contentDidChange() }
  }

  func insertColumn(at index: Int, inStorage: Bool) {
    precondition(index >= 0 && index <= columnCount && subtype.isMultiColumnEnabled)

    let elements = (0..<rowCount).map { _ in Cell() }

    if inStorage {
      _editLog.append(.insertColumn(at: index))
      elements.forEach { _addedNodes.insert($0.id) }
    }

    elements.forEach { $0.setParent(self) }

    for i in (0..<rowCount) {
      _rows[i].insert(elements[i], at: index)
    }

    if inStorage { contentDidChange() }
  }

  func removeColumn(at index: Int, inStorage: Bool) {
    precondition(index >= 0 && index < columnCount)

    if inStorage { _editLog.append(.removeColumn(at: index)) }

    for i in (0..<rowCount) {
      _ = _rows[i].remove(at: index)
    }

    if inStorage { contentDidChange() }
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

  private func getFragment(_ index: GridIndex) -> MathListLayoutFragment? {
    guard let matrixFragment = _nodeFragment,
      index.row < rowCount,
      index.column < columnCount
    else { return nil }
    return matrixFragment.getElement(index.row, index.column)
  }

  internal func getGridIndex(interactingAt point: CGPoint) -> GridIndex? {
    preconditionFailure("overriding required")
  }

  private func rayshoot(
    from point: CGPoint, _ index: GridIndex,
    in direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    _nodeFragment?.rayshoot(from: point, index, in: direction)
  }

  /// Applies the edit log to the given node fragment.
  /// - Returns: `true` if the edit log is applied, `false` if the edit log is empty.
  final func _applyEditLogToFragment(_ nodeFragment: MathArrayLayoutFragment) -> Bool {
    guard _editLog.isEmpty == false else { return false }

    for event in _editLog {
      switch event {
      case let .insertRow(at: index):
        nodeFragment.insertRow(at: index)
      case let .removeRow(at: index):
        nodeFragment.removeRow(at: index)
      case let .insertColumn(at: index):
        nodeFragment.insertColumn(at: index)
      case let .removeColumn(at: index):
        nodeFragment.removeColumn(at: index)
      }
    }
    return true
  }

  // MARK: - Overriding Required

  /// Creates layout fragment for the array node.
  internal func _createMathArrayLayoutFragment(
    _ context: LayoutContext, _ mathContext: MathContext
  ) -> MathArrayLayoutFragment {
    // default implementation.
    MathArrayLayoutFragment(
      rowCount: rowCount, columnCount: columnCount, subtype: subtype, mathContext, 0)
  }

  /// Returns the math class to **virtually precede** the first fragment of the
  /// math list for the cell at the given row and column index.
  internal func _previousClass(_ rowIndex: Int, _ columnIndex: Int) -> MathClass? {
    nil  // default implementation
  }

  /// - Parameters:
  ///   - previousClass: the math class to precede the first fragment of the layout.
  internal func _reconcileMathListLayoutFragment(
    _ element: ContentNode, _ fragment: MathListLayoutFragment,
    parent context: LayoutContext,
    fromScratch: Bool, previousClass: MathClass? = nil
  ) {
    preconditionFailure("overriding required")
  }

  final func _createMathContext(_ parentContext: LayoutContext) -> MathContext {
    switch parentContext {
    case let context as TextLayoutContext:
      let mathContext = MathUtils.resolveMathContext(for: self, context.styleSheet)
      return mathContext

    case let context as MathListLayoutContext:
      return context.mathContext

    default:
      preconditionFailure("unsupported context type: \(Swift.type(of: parentContext))")
    }
  }
}
