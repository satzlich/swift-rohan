// Copyright 2024-2025 Lie Yan

import Foundation
import UnicodeMathClass

final class MultilineNode: ArrayNode {
  // MARK: - Node

  final override func deepCopy() -> Self { Self(deepCopyOf: self) }

  final override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(multiline: self, context)
  }

  final override class var type: NodeType { .multiline }

  final override func selector() -> TargetSelector {
    MultilineNode.selector(isMultline: subtype.isMultline)
  }

  final override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      var current = super.getProperties(styleSheet)
      current[ParagraphProperty.textAlignment] =
        subtype.isMultline ? .textAlignment(.right) : .textAlignment(.center)
      _cachedProperties = current
    }
    return _cachedProperties!
  }

  // MARK: - Node(Layout)

  final override var isDirty: Bool { _isCounterDirty || super.isDirty }
  final override var isBlock: Bool { true }

  final override func performLayout(
    _ context: any LayoutContext, fromScratch: Bool
  ) -> Int {
    precondition(context is TextLayoutContext)
    return super.performLayout(context, fromScratch: fromScratch)
  }

  // MARK: - Node(Codable)

  required init(from decoder: any Decoder) throws {
    try super.init(from: decoder)
    _setUp()
  }

  // MARK: - Node(Storage)

  final override class var storageTags: Array<String> {
    MathArray.blockMathCommands.map(\.command)
  }

  final override class func load(from json: JSONValue) -> NodeLoaded<Node> {
    loadSelf(from: json).cast()
  }

  final override func store() -> JSONValue {
    let rows: Array<JSONValue> = _rows.map { row in
      let children: Array<JSONValue> = row.map { $0.store() }
      return JSONValue.array(children)
    }
    let json = JSONValue.array([.string(subtype.command), .array(rows)])
    return json
  }

  // MARK: - Node(Counter)

  final override var counterSegment: CounterSegment? { _counterSegment }
  /// Count holder provided by the heading node.
  @inline(__always)
  private final var countHolder: CountHolder? { _counterSegment?.begin }

  // MARK: - ArrayNode

  final override func getGridIndex(interactingAt point: CGPoint) -> GridIndex? {
    _nodeFragment?.getGridIndex(interactingAt: point, shouldClamp: true)
  }

  // MARK: - Storage

  final class func loadSelf(from json: JSONValue) -> NodeLoaded<MultilineNode> {
    guard case let .array(array) = json,
      array.count == 2,
      case let .string(tag) = array[0],
      let subtype = MathArray.lookup(tag),
      case let .array(rows) = array[1]
    else { return .failure(UnknownNode(json)) }

    let resultRows = NodeStoreUtils.loadRows(rows)
    switch resultRows {
    case .success(let rows):
      let node = Self(subtype, rows)
      return .success(node)
    case .corrupted(let rows):
      let node = Self(subtype, rows)
      return .corrupted(node)
    case .failure:
      return .failure(UnknownNode(json))
    }
  }

  // MARK: - MultilineNode

  private final var _counterSegment: CounterSegment?
  private final var _isCounterDirty: Bool = false

  override init(_ subtype: MathArray, _ rows: Array<Row>) {
    super.init(subtype, rows)
    _setUp()
  }

  init(_ subtype: MathArray, _ rows: Array<Array<Cell>>) {
    let rows = rows.map { Row($0) }
    super.init(subtype, rows)
    _setUp()
  }

  private init(deepCopyOf multilineNode: MultilineNode) {
    super.init(deepCopyOf: multilineNode)
    _setUp()
  }

  private final func _setUp() {
    if subtype.shouldProvideCounter {
      let countHolder = CountHolder(.equation)
      // Register the count holder as an observer.
      countHolder.registerObserver(self)
      _counterSegment = CounterSegment(countHolder)
    }
    else {
      _counterSegment = nil
    }
  }

  internal static func selector(isMultline: Bool) -> TargetSelector {
    TargetSelector(.multiline, PropertyMatcher(.isMultline, .bool(isMultline)))
  }

  final override func contentDidChange(nonCell: Void) {
    _isCounterDirty = true
    super.contentDidChange(nonCell: ())
  }

  /// Get the width of the content container for this array node.
  private func _getContainerWidth(_ styleSheet: StyleSheet) -> Double {
    guard subtype.isMultline else { return 0 }

    let properties = self.getProperties(styleSheet)

    @inline(__always)
    func resolveValue(_ key: PropertyKey) -> PropertyValue {
      key.resolveValue(properties, styleSheet)
    }
    let fontSize = resolveValue(TextProperty.size).fontSize()!.floatValue
    let headIndent = resolveValue(ParagraphProperty.headIndent).float()!
    let globalContainerWidth =
      PageProperty.resolveContentContainerWidth(styleSheet).ptValue
    let containerWidth = globalContainerWidth - headIndent
    // 10pt for text container inset, 1em for leading padding.
    return containerWidth - Rohan.fragmentPadding * 2 - fontSize
  }

  final override func _reconcileMathListLayoutFragment(
    _ element: ContentNode, _ fragment: MathListLayoutFragment,
    parent context: any LayoutContext, fromScratch: Bool,
    previousClass: MathClass? = nil
  ) {
    let context = context as! TextLayoutContext
    return LayoutUtils.reconcileMathListLayoutFragment(
      element, fragment, parent: context,
      fromScratch: fromScratch, previousClass: previousClass)
  }

  final override func _createMathArrayLayoutFragment(
    _ context: LayoutContext, _ mathContext: MathContext
  ) -> MathArrayLayoutFragment {
    let containerWidth = _getContainerWidth(context.styleSheet)
    return MathArrayLayoutFragment(
      rowCount: rowCount, columnCount: columnCount, subtype: subtype,
      mathContext, containerWidth)
  }

  final override func _previousClass(_ rowIndex: Int, _ columnIndex: Int) -> MathClass? {
    subtype.isMultline ? (rowIndex > 0 ? MathClass.Normal : nil) : nil
  }
}

extension MultilineNode: CountObserver {
  final func countObserver(markAsDirty: Void) {
    self.contentDidChange(nonCell: ())
  }
}
