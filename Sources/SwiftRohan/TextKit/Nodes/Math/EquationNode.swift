// Copyright 2024-2025 Lie Yan

import AppKit
import _RopeModule

final class EquationNode: MathNode {
  // MARK: - Node

  final override func deepCopy() -> Self { Self(deepCopyOf: self) }

  final override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(equation: self, context)
  }

  final override class var type: NodeType { .equation }

  final override func selector() -> TargetSelector {
    EquationNode.selector(isBlock: isBlock)
  }

  final override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      var current = super.getProperties(styleSheet)

      // if there is no math style, compute and set
      let key = MathProperty.style
      if current[key] == nil {
        current[key] = .mathStyle(isBlock ? .display : .text)
      }

      _cachedProperties = current
    }
    return _cachedProperties!
  }

  // MARK: - Node(Layout)

  final override var isBlock: Bool { subtype.isBlock }
  final override var isDirty: Bool { nucleus.isDirty || _isCounterDirty }

  final override func layoutLength() -> Int { _layoutLength }

  final override func performLayout(
    _ context: LayoutContext, fromScratch: Bool
  ) -> Int {
    precondition(context is TextLayoutContext)
    let context = context as! TextLayoutContext
    return !isReflowActive
      ? _performLayout(context, fromScratch: fromScratch)
      : _performLayoutReflow(context, fromScratch: fromScratch)
  }

  private final func _performLayout(
    _ context: TextLayoutContext, fromScratch: Bool
  ) -> Int {
    // Invariant Maintenance: (a) layout length; (b) _isCounterDirty.

    if fromScratch {
      // set up properties before layout.
      _setupNodeProperties(context)
      // block => fixed attributes is not nil
      assert(subtype == .inline || _cachedAttributes != nil)
      let nodeFragment = LayoutUtils.buildMathListLayoutFragment(nucleus, parent: context)
      _nodeFragment = nodeFragment
      // insert the node fragment into the context
      context.insertFragment(nodeFragment, self)
      if self.isBlock {
        _addAttributesBackwards(1, context)
        _isCounterDirty = false
      }
      _layoutLength = 1
    }
    else {
      guard let nodeFragment = _nodeFragment else {
        assertionFailure("expected _nodeFragment to be non-nil")
        return _layoutLength
      }

      if nucleus.isDirty {
        LayoutUtils.reconcileMathListLayoutFragment(
          nucleus, nodeFragment, parent: context)
      }
      context.invalidateForward(1)

      if _isCounterDirty {
        assert(subtype == .equation)
        _addAttributesBackwards(1, context)
        _isCounterDirty = false
      }
      _layoutLength = 1
    }
    return _layoutLength
  }

  private final func _performLayoutReflow(
    _ context: TextLayoutContext, fromScratch: Bool
  ) -> Int {
    precondition(isReflowActive)

    if fromScratch {
      // set up properties before layout.
      _setupNodeProperties(context)
      let nodeFragment = LayoutUtils.buildMathListLayoutFragment(nucleus, parent: context)
      _nodeFragment = nodeFragment
      _layoutLength = emitReflowSegments(nodeFragment)
    }
    else {
      guard let nodeFragment = _nodeFragment else {
        assertionFailure("expected _nodeFragment to be non-nil")
        return _layoutLength
      }

      LayoutUtils.reconcileMathListLayoutFragment(nucleus, nodeFragment, parent: context)

      // delete segments emitted in previous layout, and emit new segments
      context.deleteForward(_layoutLength)
      _layoutLength = emitReflowSegments(nodeFragment)
    }

    return _layoutLength

    /// Returns the number of segments emitted.
    @inline(__always)
    func emitReflowSegments(_ nodeFragment: MathListLayoutFragment) -> Int {
      precondition(self.isReflowActive)
      nodeFragment.performReflow()
      context.insertFragments(contentsOf: nodeFragment.reflowSegments, self)
      return nodeFragment.reflowSegments.count
    }
  }

  /// Add paragraph attributes backwards for the equation node.
  private final func _addAttributesBackwards(
    _ segment: Int, _ context: some LayoutContext
  ) {
    switch subtype {
    case .inline:
      break
    case .display:
      EquationNode.addAttributesBackwards(
        shouldProvideCounter: false, segment, context, &_cachedAttributes, countHolder)
    case .equation:
      EquationNode.addAttributesBackwards(
        shouldProvideCounter: true, segment, context, &_cachedAttributes, countHolder)
    }
  }

  private final func _setupNodeProperties(_ context: some LayoutContext) {
    switch subtype {
    case .inline:
      break

    case .display:
      let styleSheet = context.styleSheet
      let paragraphProperty: ParagraphProperty = resolveAggregate(styleSheet)
      _cachedAttributes = paragraphProperty.getAttributes()

    case .equation:
      let styleSheet = context.styleSheet
      _cachedAttributes =
        EquationNode.computeAttributesForCounterProvider(
          self, styleSheet, trailingCursorPosition: &_trailingCursorPosition)
    }
  }

  // MARK: - Node(Codable)

  private enum CodingKeys: CodingKey { case subtype, nuc }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.subtype = try container.decode(EquationSubtype.self, forKey: .subtype)
    self.nucleus = try container.decode(ContentNode.self, forKey: .nuc)
    super.init()
    self._setUp()
  }

  final override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(subtype, forKey: .subtype)
    try container.encode(nucleus, forKey: .nuc)
    try super.encode(to: encoder)
  }

  // MARK: - Node(Storage)

  private enum Tag: String, Codable, CaseIterable {
    case displaymath, inlinemath, equation

    var subtype: EquationSubtype {
      switch self {
      case .displaymath: return .display
      case .inlinemath: return .inline
      case .equation: return .equation
      }
    }
  }

  final override class var storageTags: Array<String> { Tag.allCases.map(\.rawValue) }

  final override class func load(from json: JSONValue) -> NodeLoaded<Node> {
    loadSelf(from: json).cast()
  }

  final override func store() -> JSONValue {
    let nucleus = nucleus.store()
    switch subtype {
    case .inline:
      return JSONValue.array([.string(Tag.inlinemath.rawValue), nucleus])
    case .display:
      return JSONValue.array([.string(Tag.displaymath.rawValue), nucleus])
    case .equation:
      return JSONValue.array([.string(Tag.equation.rawValue), nucleus])
    }
  }

  // MARK: - Node(Tree API)

  final override func enumerateTextSegments(
    _ path: ArraySlice<RohanIndex>, _ endPath: ArraySlice<RohanIndex>,
    context: any LayoutContext, layoutOffset: Int, originCorrection: CGPoint,
    type: DocumentManager.SegmentType, options: DocumentManager.SegmentOptions,
    using block: (RhTextRange?, CGRect, CGFloat) -> Bool
  ) -> Bool {
    precondition(context is TextLayoutContext)
    let context = context as! TextLayoutContext

    guard isReflowActive else {
      return super.enumerateTextSegments(
        path, endPath, context: context, layoutOffset: layoutOffset,
        originCorrection: originCorrection, type: type, options: options, using: block)
    }

    guard path.count >= 2,
      endPath.count >= 2,
      let index: MathIndex = path.first?.mathIndex(),
      let endIndex: MathIndex = endPath.first?.mathIndex(),
      // must not fork
      index == endIndex,
      let component = getComponent(index),
      let fragment = getFragment(index) as? MathListLayoutFragment
    else { return false }

    let newContext: MathReflowLayoutContext =
      createReflowContext(
        component, fragment, parent: context, layoutOffset: layoutOffset)

    return component.enumerateTextSegments(
      path.dropFirst(), endPath.dropFirst(), context: newContext,
      // reset layoutOffset to "0".
      layoutOffset: 0,
      // use the original originCorrection.
      originCorrection: originCorrection,
      type: type, options: options, using: block)
  }

  final override func resolveTextLocation(
    with point: CGPoint, context: any LayoutContext, layoutOffset: Int,
    trace: inout Trace, affinity: inout SelectionAffinity
  ) -> Bool {
    precondition(context is TextLayoutContext)
    let context = context as! TextLayoutContext

    switch subtype {
    case .inline:
      if isReflowActive {
        // set component, fragment, and index
        let index = MathIndex.nuc
        let component = nucleus
        guard let fragment = _nodeFragment else { return false }
        // append to trace
        trace.emplaceBack(self, .mathIndex(index))

        let newContext =
          createReflowContext(
            component, fragment, parent: context, layoutOffset: layoutOffset)

        // recurse
        let modified = component.resolveTextLocation(
          with: point, context: newContext,
          // reset layoutOffset to "0".
          layoutOffset: 0, trace: &trace, affinity: &affinity)
        // fix accordingly
        if !modified { trace.emplaceBack(component, .index(0)) }
        return true
      }
      else {
        return super.resolveTextLocation(
          with: point, context: context, layoutOffset: layoutOffset, trace: &trace,
          affinity: &affinity)
      }

    case .equation:
      if let trailingCursorPosition = _trailingCursorPosition,
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

    case .display:
      return super.resolveTextLocation(
        with: point, context: context, layoutOffset: layoutOffset, trace: &trace,
        affinity: &affinity)
    }
  }

  final override func rayshoot(
    from path: ArraySlice<RohanIndex>, affinity: SelectionAffinity,
    direction: TextSelectionNavigation.Direction, context: any LayoutContext,
    layoutOffset: Int
  ) -> RayshootResult? {
    precondition(context is TextLayoutContext)
    let context = context as! TextLayoutContext

    guard isReflowActive else {
      return super.rayshoot(
        from: path, affinity: affinity, direction: direction, context: context,
        layoutOffset: layoutOffset)
    }

    guard path.count >= 2,
      let index: MathIndex = path.first?.mathIndex(),
      let component = getComponent(index),
      let fragment = getFragment(index) as? MathListLayoutFragment
    else { return nil }

    // create sub-context
    let newContext =
      createReflowContext(
        component, fragment, parent: context, layoutOffset: layoutOffset)

    return component.rayshoot(
      from: path.dropFirst(), affinity: affinity, direction: direction,
      context: newContext,
      // reset layoutOffset to "0"
      layoutOffset: 0)
  }

  final override var needsTrailingCursorCorrection: Bool {
    switch subtype {
    case .inline: return false
    case .display: return false
    case .equation: return true
    }
  }

  final override func trailingCursorPosition() -> Double? { _trailingCursorPosition }

  // MARK: - MathNode(Component)

  final override func enumerateComponents() -> Array<MathNode.Component> {
    [(MathIndex.nuc, nucleus)]
  }

  // MARK: - MathNode(Layout)

  final override var layoutFragment: MathLayoutFragment? { _nodeFragment }

  final override func getFragment(_ index: MathIndex) -> LayoutFragment? {
    guard index == .nuc else { return nil }
    return _nodeFragment
  }

  final override func getMathIndex(interactingAt point: CGPoint) -> MathIndex? {
    _nodeFragment != nil ? .nuc : nil
  }

  final override func rayshoot(
    from point: CGPoint, _ component: MathIndex,
    in direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    guard let fragment = _nodeFragment,
      component == .nuc
    else { return nil }

    switch direction {
    case .up:
      return RayshootResult(point.with(y: -fragment.ascent), false)
    case .down:
      return RayshootResult(point.with(y: fragment.descent), false)
    default:
      assertionFailure("Unsupported direction")
      return nil
    }
  }

  // MARK: - Storage

  final class func loadSelf(from json: JSONValue) -> NodeLoaded<EquationNode> {
    guard case let .array(array) = json,
      array.count == 2,
      case let .string(tag) = array[0],
      let tag = Tag(rawValue: tag)
    else {
      return .failure(UnknownNode(json))
    }

    let subtype = tag.subtype
    let nucleus = ContentNode.loadSelfGeneric(from: array[1]) as NodeLoaded<ContentNode>

    switch nucleus {
    case let .success(nucleus):
      let equation = EquationNode(subtype, nucleus)
      return .success(equation)
    case let .corrupted(nucleus):
      let equation = EquationNode(subtype, nucleus)
      return .corrupted(equation)
    case .failure:
      return .failure(UnknownNode(json))
    }
  }

  // MARK: - EquationNode

  internal let subtype: EquationSubtype
  internal let nucleus: ContentNode
  private var _layoutLength: Int = 1
  private var _nodeFragment: MathListLayoutFragment? = nil

  private var _isCounterDirty: Bool = false

  private var _counterSegment: CounterSegment?
  final override var counterSegment: CounterSegment? { _counterSegment }
  /// Count holder provided by the heading node.
  @inline(__always)
  private final var countHolder: CountHolder? { _counterSegment?.begin }

  /// attributes that can be cached.
  private var _cachedAttributes: Dictionary<NSAttributedString.Key, Any>? = nil

  private var _trailingCursorPosition: Double? = nil

  /// True if the layout of the equation should be reflowed.
  final var isReflowActive: Bool {
    NodePolicy.isInlineMathReflowEnabled && subtype == .inline
  }

  init(_ subtype: EquationSubtype, _ nucleus: ElementStore = []) {
    self.subtype = subtype
    self.nucleus = ContentNode(nucleus)
    super.init()
    self._setUp()
  }

  private init(_ subtype: EquationSubtype, _ nucleus: ContentNode) {
    self.subtype = subtype
    self.nucleus = nucleus
    super.init()
    self._setUp()
  }

  private init(deepCopyOf equationNode: EquationNode) {
    self.subtype = equationNode.subtype
    self.nucleus = equationNode.nucleus.deepCopy()
    super.init()
    self._setUp()
  }

  final func with(nucleus: ContentNode) -> EquationNode {
    EquationNode(subtype, nucleus)
  }

  @inline(__always)
  private final func _setUp() {
    self.nucleus.setParent(self)

    if subtype.shouldProvideCounter {
      let countHolder = CountHolder(.equation)
      // register the equation node as an observer of the count holder.
      countHolder.registerObserver(self)
      self._counterSegment = CounterSegment(countHolder)
    }
    else {
      self._counterSegment = nil
    }
  }

  internal static func selector(isBlock: Bool? = nil) -> TargetSelector {
    return isBlock != nil
      ? TargetSelector(.equation, PropertyMatcher(.isBlock, .bool(isBlock!)))
      : TargetSelector(.equation)
  }

  /// Create reflow context for the equation node.
  /// - Parameters:
  ///     - component: The content component of the equation node.
  ///     - fragment: The math list layout fragment of the content component.
  ///     - context: The parent text layout context.
  ///     - layoutOffset: The layout offset of the equation node.
  private final func createReflowContext(
    _ component: ContentNode, _ fragment: MathListLayoutFragment,
    parent context: TextLayoutContext, layoutOffset: Int
  ) -> MathReflowLayoutContext {
    precondition(self.isReflowActive)
    let mathContext =
      LayoutUtils.initMathListLayoutContext(for: component, fragment, parent: context)
    return MathReflowLayoutContext(context, mathContext, self, layoutOffset)
  }
}

extension EquationNode: CountObserver {
  final func countObserver(markAsDirty: Void) {
    self.contentDidChange()
    _isCounterDirty = true
  }

  /// Compute attributes for equation nodes that provide counter.
  static func computeAttributesForCounterProvider(
    _ node: Node, _ styleSheet: StyleSheet, trailingCursorPosition: inout Double?
  ) -> Dictionary<NSAttributedString.Key, Any> {
    let properties = node.getProperties(styleSheet)

    @inline(__always)
    func resolveValue(_ key: PropertyKey) -> PropertyValue {
      key.resolveValue(properties, styleSheet)
    }

    let containerWidth = PageProperty.resolveContentContainerWidth(styleSheet).ptValue
    trailingCursorPosition = containerWidth - Rohan.fragmentPadding

    // paragraph
    let paragraphProperty = ParagraphProperty.resolveAggregate(properties, styleSheet)
    var attributes = paragraphProperty.getAttributes()
    // horizontal bounds
    do {
      let x: CGFloat = paragraphProperty.headIndent
      let width: CGFloat = containerWidth - x - Rohan.fragmentPadding
      attributes[.rhHorizontalBounds] = HorizontalBounds(x, width)
    }
    // text property
    let textProperty = TextProperty.resolveAggregate(properties, styleSheet)
    attributes.merge(textProperty.getAttributes(), uniquingKeysWith: { $1 })

    return attributes
  }

  /// Add attributes backwards for the equation node.
  /// - Parameters:
  ///   - shouldProvideCounter: Whether the equation node should provide counter.
  ///   - segment: The segment length to add attributes backwards.
  ///   - context: The layout context to add attributes.
  ///   - cachedAttributes: The cached attributes to use.
  ///   - countHolder: The count holder to use, if any.
  static func addAttributesBackwards(
    shouldProvideCounter: Bool,
    _ segment: Int, _ context: some LayoutContext,
    _ cachedAttributes: inout Dictionary<NSAttributedString.Key, Any>?,
    _ countHolder: CountHolder?
  ) {
    if shouldProvideCounter {
      guard cachedAttributes != nil else {
        assertionFailure("expected cachedAttributes to be non-nil")
        return
      }
      if let countHolder = countHolder {
        let equationNumber = countHolder.value(forName: .equation)
        cachedAttributes![.rhEquationNumber] =
          NSAttributedString(
            string: "(\(equationNumber))", attributes: cachedAttributes!)
      }
      let begin = context.layoutCursor - segment
      let end = context.layoutCursor
      context.addAttributes(cachedAttributes!, begin..<end)
    }
    else {
      guard let cachedAttributes = cachedAttributes else {
        assertionFailure("expected cachedAttributes to be non-nil")
        return
      }
      let begin = context.layoutCursor - segment
      let end = context.layoutCursor
      context.addAttributes(cachedAttributes, begin..<end)
    }
  }
}
