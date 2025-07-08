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
      @inline(__always)
      func resolveValue(_ key: PropertyKey) -> PropertyValue {
        key.resolveValue(current, styleSheet)
      }

      if subtype.isMultline {
        let fontSize = resolveValue(TextProperty.size).fontSize()!.floatValue
        let headIndent = resolveValue(ParagraphProperty.headIndent).float()!
        let newHeadIndent = headIndent + fontSize  // +1em space.
        current[ParagraphProperty.firstLineHeadIndent] = .float(newHeadIndent)
        current[ParagraphProperty.headIndent] = .float(newHeadIndent)

        current[ParagraphProperty.textAlignment] = .textAlignment(.left)
      }
      else {
        current[ParagraphProperty.textAlignment] = .textAlignment(.center)
      }

      _cachedProperties = current
    }
    return _cachedProperties!
  }

  // MARK: - Node(Layout)

  final override var isDirty: Bool {
    super.isDirty || _countProviderState?.isCounterDirty == true
  }
  final override var isBlock: Bool { true }

  final override func performLayout(
    _ context: any LayoutContext, fromScratch: Bool
  ) -> Int {
    precondition(context is TextLayoutContext)
    defer { assert(self.isDirty == false) }

    if fromScratch {
      _setupNodeProperties(context)

      let sum = super.performLayout(context, fromScratch: true)
      _addAttributesBackwards(1, context)
      _countProviderState?.isCounterDirty = false
      return sum
    }
    else {
      _updateNodeProperties()
      if _countProviderState != nil {
        assert(subtype.shouldProvideCounter)
        if _countProviderState!.isCounterDirty {
          let containerWidth =
            _countProviderState!.computeContainerWidth(_constantContainerWidth)
          _nodeFragment?.setContainerWidth(containerWidth)

          let sum = super.performLayout(context, fromScratch: false)
          _addAttributesBackwards(1, context)
          _countProviderState!.isCounterDirty = false
          return sum
        }
        else {
          return super.performLayout(context, fromScratch: false)
        }
      }
      else {
        return super.performLayout(context, fromScratch: false)
      }
    }
  }

  /// Add paragraph attributes backwards for the equation node.
  private final func _addAttributesBackwards(
    _ segment: Int, _ context: some LayoutContext
  ) {
    if let countHolder = countHolder,
      let cachedAttributes = _cachedAttributes
    {
      let equationNumber = EquationNode.composeEquationNumber(
        countHolder, cachedAttributes)
      EquationNode.addAttributesBackwards(
        segment, context, &_cachedAttributes, equationNumber)
    }
    else {
      EquationNode.addAttributesBackwards(segment, context, &_cachedAttributes, nil)
    }
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

  // MARK: - Node(Tree API)

  final override var needsTrailingCursorCorrection: Bool { subtype.shouldProvideCounter }
  final override func trailingCursorPosition() -> Double? {
    _countProviderState?.trailingCursorPosition
  }

  final override func resolveTextLocation(
    with point: CGPoint, context: any LayoutContext, layoutOffset: Int,
    trace: inout Trace, affinity: inout SelectionAffinity
  ) -> Bool {
    if subtype.shouldProvideCounter {
      if let trailingCursorPosition = _countProviderState?.trailingCursorPosition,
        point.x >= trailingCursorPosition - 0.5  // allow small tolerance
      {
        // cursor position is after the equation, no need to resolve.
        return false
      }
      else {
        return super.resolveTextLocation(
          with: point, context: context, layoutOffset: layoutOffset, trace: &trace,
          affinity: &affinity)
      }
    }
    else {
      return super.resolveTextLocation(
        with: point, context: context, layoutOffset: layoutOffset, trace: &trace,
        affinity: &affinity)
    }
  }

  // MARK: - Node(Counter)

  final override var counterSegment: CounterSegment? {
    _countProviderState?.counterSegment
  }
  /// Count holder provided by the heading node.
  private final var countHolder: CountHolder? {
    _countProviderState?.counterSegment.begin
  }

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

  private final var _cachedAttributes: Dictionary<NSAttributedString.Key, Any>? = nil
  private final var _countProviderState: _CountProviderState? = nil
  private final var _constantContainerWidth: Double = 0

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
      _countProviderState = _CountProviderState(countHolder)
    }
    else {
      _countProviderState = nil
    }
  }

  private final func _setupNodeProperties(_ context: some LayoutContext) {
    let styleSheet = context.styleSheet

    _constantContainerWidth = _computeContainerWidth(styleSheet)

    if subtype.shouldProvideCounter {
      let (attributes, trailingCursorPosition) =
        EquationNode.computeAttributesForCounterProvider(self, styleSheet)
      _cachedAttributes = attributes
      _countProviderState?.trailingCursorPosition = trailingCursorPosition
      let countHolder = countHolder!
      _countProviderState?.equationNumber =
        EquationNode.composeEquationNumber(countHolder, _cachedAttributes!)
    }
    else {
      let paragraphProperty: ParagraphProperty = resolveAggregate(styleSheet)
      _cachedAttributes = paragraphProperty.getAttributes()
    }
  }

  private final func _updateNodeProperties() {
    if subtype.shouldProvideCounter {
      let countHolder = countHolder!
      _countProviderState?.equationNumber =
        EquationNode.composeEquationNumber(countHolder, _cachedAttributes!)
    }
    else {
      return
    }
  }

  private final func _computeContainerWidth(_ styleSheet: StyleSheet) -> Double {
    guard subtype.isMultline else { return 0 }

    let properties = self.getProperties(styleSheet)
    @inline(__always)
    func resolveValue(_ key: PropertyKey) -> PropertyValue {
      key.resolveValue(properties, styleSheet)
    }
    let globalContainerWidth =
      PageProperty.resolveContentContainerWidth(styleSheet).ptValue
    let headIndent = resolveValue(ParagraphProperty.headIndent).float()!
    return globalContainerWidth - headIndent - Rohan.fragmentPadding * 2
  }

  internal static func selector(isMultline: Bool) -> TargetSelector {
    TargetSelector(.multiline, PropertyMatcher(.isMultline, .bool(isMultline)))
  }

  final override func contentDidChange(nonCell: Void) {
    super.contentDidChange(nonCell: ())
    // due to early stop mechanism, we have to mark dirty after propagation.
    _countProviderState?.isCounterDirty = true
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
    let containerWidth =
      _countProviderState?.computeContainerWidth(_constantContainerWidth)
      ?? _constantContainerWidth

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

  struct _CountProviderState {
    let counterSegment: CounterSegment
    var isCounterDirty: Bool = false
    var trailingCursorPosition: Double = 0
    var equationNumber: NSAttributedString = NSAttributedString()

    init(_ countHolder: CountHolder) {
      self.counterSegment = CounterSegment(countHolder)
    }

    /// Get the width of the content container for this array node.
    func computeContainerWidth(_ containerWidth: Double) -> Double {
      containerWidth - equationNumber.size().width - 10  // 10pt padding.
    }
  }
}
