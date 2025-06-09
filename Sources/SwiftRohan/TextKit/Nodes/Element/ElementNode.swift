// Copyright 2024-2025 Lie Yan

import Algorithms
import BitCollections
import CoreGraphics
import DequeModule
import _RopeModule

/// Storage for `ElementNode` children.
internal typealias ElementStore = Deque<Node>

internal class ElementNode: Node {
  // MARK: - Node

  final override func resetCachedProperties() {
    super.resetCachedProperties()
    for child in _children {
      child.resetCachedProperties()
    }
  }

  // MARK: - Node(Positioning)

  final override func getChild(_ index: RohanIndex) -> Node? {
    guard let index = index.index(),
      index < _children.count
    else { return nil }
    return _children[index]
  }

  final override func firstIndex() -> RohanIndex? { .index(0) }
  final override func lastIndex() -> RohanIndex? { .index(_children.count) }

  final override func getLayoutOffset(_ index: RohanIndex) -> Int? {
    guard let index = index.index() else { return nil }
    return getLayoutOffset(index)
  }

  final override func getRohanIndex(_ layoutOffset: Int) -> (RohanIndex, consumed: Int)? {
    guard let (i, consumed) = getChildIndex(layoutOffset) else { return nil }
    // assert(consumed <= layoutOffset)
    return (.index(i), consumed)
  }

  final override func getPosition(_ layoutOffset: Int) -> PositionResult<RohanIndex> {
    guard 0...layoutLength() ~= layoutOffset else {
      return .failure(error: SatzError(.InvalidLayoutOffset))
    }

    if _children.isEmpty {
      return .terminal(value: .index(0), target: 0)
    }
    assert(isPlaceholderActive == false)

    var (k, s) = (0, 0)
    // notations: ell(i):= children[i].layoutLength + _newlines[i].intValue
    // invariant: s(k) = sum:i∈[0,k):ell(i)
    //            s(k) ≤ layoutOffset
    //      goal: find k st. s(k) ≤ layoutOffset < s(k) + ell(k)
    while k < _children.count {
      let ss = s + _children[k].layoutLength() + _newlines[k].intValue
      if ss > layoutOffset { break }
      (k, s) = (k + 1, ss)
    }
    return k == _children.count
      ? .terminal(value: .index(k), target: s)
      : .halfway(value: .index(k), consumed: s)
  }

  // MARK: - Node(Layout)

  final override func contentDidChange() {
    _isDirty = true
    parent?.contentDidChange()
  }

  final override func layoutLength() -> Int { _layoutLength }

  final override var isBlock: Bool { NodePolicy.isBlockElement(type) }
  final override var isDirty: Bool { _isDirty }

  final override func performLayout(_ context: LayoutContext, fromScratch: Bool) -> Int {

    if fromScratch {
      _layoutLength = _performLayoutFromScratch(context)
      _snapshotRecords = nil
    }
    else if _snapshotRecords == nil {
      _layoutLength = _performLayoutSimple(context)
    }
    else {
      _layoutLength = _performLayoutFull(context)
      _snapshotRecords = nil
    }
    _isDirty = false

    return _layoutLength
  }

  // MARK: - Node(Codable)

  private enum CodingKeys: CodingKey { case children }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    var childrenContainer = try container.nestedUnkeyedContainer(forKey: .children)

    // children and newlines
    self._children = try NodeSerdeUtils.decodeListOfNodes(from: &childrenContainer)
    self._newlines = NewlineArray(_children.lazy.map(\.isBlock))

    self._layoutLength = 0
    self._isDirty = false

    try super.init(from: decoder)
    self._setUp()
  }

  internal override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self._children, forKey: .children)
    try super.encode(to: encoder)
  }

  // MARK: - ElementNode

  /// Visit the children in the manner of this node.
  internal func accept<R, C, V: NodeVisitor<R, C>, T: GenNode, S: Collection<T>>(
    _ visitor: V, _ context: C, withChildren children: S
  ) -> R {
    preconditionFailure("overriding required")
  }

  /// Create a node for splitting at the end.
  internal func createSuccessor() -> ElementNode? { nil }  // default to nil.

  /// Create an empty clone of this node.
  internal func cloneEmpty() -> Self { preconditionFailure("overriding required") }

  /// Encode this node but with children replaced with given children.
  ///
  /// Helper function for encoding partial nodes. Override this method to encode
  /// extra properties.
  internal func encode<S: Collection<PartialNode> & Encodable>(
    to encoder: any Encoder, withChildren children: S
  ) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(children, forKey: .children)
    try super.encode(to: encoder)
  }

  // MARK: - Implementation

  private final var _children: ElementStore

  final func childrenReadonly() -> ElementStore { _children }

  private class func newlineArrayMask() -> Bool { self.type == .root }

  /// - Warning: Sync with other init() method.
  internal init(_ children: ElementStore) {
    self._children = children
    self._newlines =
      NewlineArray(children.lazy.map(\.isBlock), mask: Self.newlineArrayMask())
    self._layoutLength = 0
    self._isDirty = false

    super.init()
    self._setUp()
  }

  /// - Warning: Sync with other init() method.
  internal override init() {
    self._children = ElementStore()
    self._newlines = NewlineArray(mask: Self.newlineArrayMask())
    self._layoutLength = 0
    self._isDirty = false

    super.init()
    self._setUp()
  }

  /// - Warning: Sync with other init() method.
  internal init(deepCopyOf elementNode: ElementNode) {
    self._children = ElementStore(elementNode._children.lazy.map { $0.deepCopy() })
    self._newlines = elementNode._newlines
    self._layoutLength = elementNode._layoutLength
    self._isDirty = false

    super.init()
    self._setUp()
  }

  private final func _setUp() {
    for child in _children {
      child.setParent(self)
    }
  }

  /// Returns true if node is allowed to be empty.
  final var isVoidable: Bool { NodePolicy.isVoidableElement(type) }

  final var isParagraphContainer: Bool { NodePolicy.isParagraphContainer(type) }

  final func isMergeable(with other: ElementNode) -> Bool {
    NodePolicy.isMergeableElements(self.type, other.type)
  }

  // MARK: - Layout Impl.

  /// layout length contributed by the node.
  private final var _layoutLength: Int
  /// true if a newline should be added after i-th child.
  private final var _newlines: NewlineArray
  private final var _isDirty: Bool

  /// true if placeholder should be shown when the node is empty.
  final var isPlaceholderEnabled: Bool { NodePolicy.isPlaceholderEnabled(type) }

  /// true if placeholder should be shown.
  final var isPlaceholderActive: Bool { isPlaceholderEnabled && _children.isEmpty }

  /// lossy snapshot of original children
  private final var _snapshotRecords: Array<SnapshotRecord>? = nil

  internal func snapshotDescription() -> Array<String>? {
    _snapshotRecords.map { $0.map(\.description) }
  }

  /// Make snapshot once if not already made
  /// - Note: Call to method `performLayout(_:fromScratch:)` will clear the snapshot.
  final func makeSnapshotOnce() {
    guard _snapshotRecords == nil else { return }
    assert(_children.count == _newlines.count)

    if isPlaceholderActive {
      _snapshotRecords = [SnapshotRecord.placeholder(1)]
    }
    else {
      _snapshotRecords = zip(_children, _newlines.asBitArray)
        .map { SnapshotRecord($0, $1) }
    }
  }

  /// Perform layout for fromScratch=true.
  private final func _performLayoutFromScratch(_ context: LayoutContext) -> Int {
    precondition(_children.count == _newlines.count)

    var sum = 0

    if _children.isEmpty {
      if self.isPlaceholderActive {
        context.insertText("⬚", self)
        sum += 1
      }
      return sum
    }

    assert(_children.isEmpty == false)

    // reconcile content backwards
    for (node, insertNewline) in zip(_children, _newlines.asBitArray).reversed() {
      if insertNewline {
        context.insertNewline(self)
        sum += 1
      }
      sum += node.performLayout(context, fromScratch: true)
    }

    // add paragraph style forwards
    if self.isParagraphContainer {
      var location = context.layoutCursor
      for i in 0..<childCount {
        let end = location + _children[i].layoutLength() + _newlines[i].intValue
        context.addParagraphStyle(_children[i], location..<end)
        location = end
      }
    }
    return sum
  }

  /// Perform layout for fromScratch=false when snapshot was not made.
  private final func _performLayoutSimple(_ context: LayoutContext) -> Int {
    precondition(_snapshotRecords == nil && _children.count == _newlines.count)

    // _performLayoutSimple() is called only when the node is marked dirty and
    // the set of child nodes is not added/deleted, so we can safely assume that
    // the placeholder is not active.
    assert(self.isPlaceholderActive == false)

    var sum = 0
    var i = _children.count - 1

    while true {
      if i < 0 { break }

      // skip clean
      while i >= 0 && !_children[i].isDirty {
        if _newlines[i] {
          context.skipBackwards(1)
          sum += 1
        }
        do {
          let length = _children[i].layoutLength()
          context.skipBackwards(length)
          sum += length
        }
        i -= 1
      }
      assert(i < 0 || _children[i].isDirty)

      // process dirty
      if i >= 0 {
        if _newlines[i] {
          context.skipBackwards(1)
          sum += 1
        }
        sum += _children[i].performLayout(context, fromScratch: false)
        i -= 1
      }
    }

    if self.isParagraphContainer {
      var end = context.layoutCursor + sum
      for i in _children.indices.suffix(2).reversed() {
        let location = end - _children[i].layoutLength() - _newlines[i].intValue
        context.addParagraphStyle(_children[i], location..<end)
        end = location
      }
    }
    return sum
  }

  /// Perform layout for fromScratch=false when snapshot has been made.
  private final func _performLayoutFull(_ context: LayoutContext) -> Int {
    precondition(_snapshotRecords != nil && _children.count == _newlines.count)

    var sum = 0

    if _children.isEmpty {
      context.deleteBackwards(_layoutLength)
      if self.isPlaceholderActive {
        context.insertText("⬚", self)
        sum += 1
      }
      return sum
    }

    assert(_children.isEmpty == false)

    // records of current children
    let current: Array<ExtendedRecord>
    // records of original children
    let original: Array<ExtendedRecord>

    do {
      // ID's of current children
      let currentIds = Set(_children.map(\.id))
      // ID's of the dirty part of current children
      let dirtyIds = Set(_children.lazy.filter(\.isDirty).map(\.id))
      // ID's of original children
      let originalIds = Set(_snapshotRecords!.map(\.nodeId))

      current =
        zip(_children, _newlines.asBitArray).map { (node, insertNewline) in
          let mark: LayoutMark =
            !originalIds.contains(node.id)
            ? .added
            : (node.isDirty ? .dirty : .none)
          return ExtendedRecord(mark, node, insertNewline)
        }

      original =
        _snapshotRecords!.map { record in
          !currentIds.contains(record.nodeId)
            ? ExtendedRecord(.deleted, record)
            : dirtyIds.contains(record.nodeId)
              ? ExtendedRecord(.dirty, record)
              : ExtendedRecord(.none, record)
        }
    }

    func processNewline(
      _ original: ExtendedRecord, _ current: ExtendedRecord, _ sum: inout Int
    ) {
      precondition(original.nodeId == current.nodeId)
      switch (original.insertNewline, current.insertNewline) {
      case (false, false):
        break  // no-op
      case (false, true):
        context.insertNewline(self)
        sum += 1
      case (true, false):
        context.deleteBackwards(1)
      case (true, true):
        context.skipBackwards(1)
        sum += 1
      }
    }

    // current range that covers deleted nodes which should be vacuumed
    var vacuumRange: Range<Int>?

    var i = current.count - 1
    var j = original.count - 1

    func updateVacuumRange() {
      if j >= 0 && original[j].mark == .deleted {
        if i >= 0 {
          vacuumRange =
            if let range = vacuumRange {
              max(0, i - 1)..<range.upperBound
            }
            else {
              max(0, i - 1)..<min(childCount, i + 2)
            }
        }
        else {
          vacuumRange =
            if let range = vacuumRange {
              0..<range.upperBound
            }
            else {
              0..<1
            }
        }
      }
    }

    // reconcile content backwards
    // Invariant:
    //    [cursor, ...) is consistent with (i, ...)
    //    [0, cursor) is consistent with [0, j]
    while true {
      if i < 0 && j < 0 { break }

      // process added and deleted
      // (It doesn't matter whether to process add or delete first.)
      do {
        updateVacuumRange()
        while j >= 0 && original[j].mark == .deleted {
          if original[j].insertNewline { context.deleteBackwards(1) }
          context.deleteBackwards(original[j].layoutLength)
          j -= 1
        }
        assert(j < 0 || [.none, .dirty].contains(original[j].mark))
      }

      while i >= 0 && current[i].mark == .added {
        if current[i].insertNewline {
          context.insertNewline(self)
          sum += 1
        }
        sum += _children[i].performLayout(context, fromScratch: true)
        i -= 1
      }
      assert(i < 0 || [.none, .dirty].contains(current[i].mark))

      // skip none
      while i >= 0 && current[i].mark == .none,
        j >= 0 && original[j].mark == .none
      {
        assert(current[i].nodeId == original[j].nodeId)
        processNewline(original[j], current[i], &sum)
        context.skipBackwards(current[i].layoutLength)
        sum += current[i].layoutLength
        i -= 1
        j -= 1
      }

      // process added or deleted by iterating again
      if i >= 0 && current[i].mark == .added { continue }
      if j >= 0 && original[j].mark == .deleted { continue }

      // process dirty
      assert(i < 0 || current[i].mark == .dirty)
      assert(j < 0 || original[j].mark == .dirty)
      if i >= 0 {
        assert(j >= 0 && current[i].nodeId == original[j].nodeId)
        assert(current[i].mark == .dirty && original[j].mark == .dirty)
        processNewline(original[j], current[i], &sum)
        sum += _children[i].performLayout(context, fromScratch: false)
        i -= 1
        j -= 1
      }
    }

    // add paragraph style forwards
    if self.isParagraphContainer {
      var location = context.layoutCursor
      let vacuumRange = vacuumRange ?? 0..<0
      for i in 0..<_children.count {
        let end = location + _children[i].layoutLength() + _newlines[i].intValue
        if current[i].isAddedOrDirty || vacuumRange.contains(i) {
          context.addParagraphStyle(_children[i], location..<end)
        }
        location = end
      }
    }
    return sum
  }

  private final func getLayoutOffset(_ index: Int) -> Int? {
    guard index <= childCount else { return nil }
    let range = 0..<index

    if _children.isEmpty {
      return isPlaceholderActive.intValue
    }
    else {
      assert(isPlaceholderActive == false)
      let s1 = _children[range].lazy.map { $0.layoutLength() }.reduce(0, +)
      let s2 = _newlines.asBitArray[range].lazy.map(\.intValue).reduce(0, +)
      return s1 + s2
    }
  }

  /// Returns the index of the child picked by `[layoutOffset, _ + 1)` together
  /// with the layout offset of the child.
  /// - Returns: nil if layout offset is out of bounds. Otherwise, returns (k, s)
  ///     where k is the index of the child containing the layout offset and s is
  ///     the layout offset of the child.
  /// - Invariant: `consumed <= layoutOffset`.
  private final func getChildIndex(_ layoutOffset: Int) -> (Int, consumed: Int)? {
    let layoutLength = self.layoutLength()
    guard layoutOffset >= 0,
      layoutOffset < layoutLength || (isBlock && layoutOffset == layoutLength)
    else { return nil }

    // Invariant: isPlaceholderActive => _children.isEmpty

    var (k, s) = (0, isPlaceholderActive.intValue)
    // notations: LO:= layoutOffset
    //            ell(i):= children[i].layoutLength + _newlines[i].intValue
    //            b:= isBlock.intValue
    // invariant: s(k) = b + sum:i∈[0,k):ell(i)
    //            s(k) ≤ LO
    //      goal: find k st. s(k) ≤ LO < s(k) + ell(k)
    while k < _children.count {
      let ss = s + _children[k].layoutLength() + _newlines[k].intValue
      if ss > layoutOffset { break }
      (k, s) = (k + 1, ss)
    }
    return (k, s)
  }

  final override func enumerateTextSegments(
    _ path: ArraySlice<RohanIndex>, _ endPath: ArraySlice<RohanIndex>,
    context: any LayoutContext, layoutOffset: Int, originCorrection: CGPoint,
    type: DocumentManager.SegmentType, options: DocumentManager.SegmentOptions,
    using block: DocumentManager.EnumerateTextSegmentsBlock
  ) -> Bool {

    func basicBlock(
      _ range: Range<Int>?, _ segmentFrame: CGRect, _ baselinePosition: CGFloat
    ) -> Bool {
      let correctedFrame = segmentFrame.offsetBy(originCorrection)
      return block(nil, correctedFrame, baselinePosition)
    }

    func placeholderBlock(
      _ range: Range<Int>?, _ segmentFrame: CGRect, _ baselinePosition: CGFloat
    ) -> Bool {
      var correctedFrame = segmentFrame.offsetBy(originCorrection)
      correctedFrame.origin.x = correctedFrame.midX
      correctedFrame.size.width = 0
      return block(nil, correctedFrame, baselinePosition)
    }

    guard let index = path.first?.index(),
      let endIndex = endPath.first?.index()
    else { assertionFailure("Invalid path"); return false }

    if self.isPlaceholderActive {
      assert(path.count == 1 && endPath.count == 1 && index == endIndex)
      guard let endOffset = TreeUtils.computeLayoutOffset(for: path, self)
      else { assertionFailure("Invalid path"); return false }
      let offset = endOffset - 1
      let layoutRange = layoutOffset + offset..<layoutOffset + endOffset
      return context.enumerateTextSegments(
        layoutRange, type: type, options: options, using: placeholderBlock(_:_:_:))
    }
    else if path.count == 1 || endPath.count == 1 || index != endIndex {
      guard let offset = TreeUtils.computeLayoutOffset(for: path, self),
        let endOffset = TreeUtils.computeLayoutOffset(for: endPath, self)
      else { assertionFailure("Invalid path"); return false }
      let layoutRange = layoutOffset + offset..<layoutOffset + endOffset
      return context.enumerateTextSegments(
        layoutRange, type: type, options: options, using: basicBlock(_:_:_:))
    }
    // ASSERT: path.count > 1 && endPath.count > 1 && index == endIndex
    else {  // if paths don't branch, recurse
      guard index < self.childCount,
        let offset = getLayoutOffset(index)
      else { assertionFailure("Invalid path"); return false }
      return _children[index].enumerateTextSegments(
        path.dropFirst(), endPath.dropFirst(), context: context,
        layoutOffset: layoutOffset + offset, originCorrection: originCorrection,
        type: type, options: options, using: block)
    }
  }

  /// Resolve the text location at the given point.
  /// - Returns: true if trace is modified.
  final override func resolveTextLocation(
    with point: CGPoint, context: any LayoutContext,
    trace: inout Trace, affinity: inout RhTextSelection.Affinity
  ) -> Bool {
    guard let result = context.getLayoutRange(interactingAt: point)
    else { return false }

    let contextRange = result.layoutRange
    let layoutRange = LayoutRange(contextRange, contextRange, result.fraction)

    affinity = result.affinity

    return resolveTextLocation(
      with: point, context: context, trace: &trace, affinity: &affinity,
      layoutRange: layoutRange)
  }

  /// Resolve the text location at the given point and layout range.
  /// - Returns: true if trace is modified.
  /// - Note: For TextLayoutContext, the point is relative to the **top-left corner**
  ///     of the container. For MathLayoutContext, the point is relative to the
  ///     **top-left corner** of the math list.
  final func resolveTextLocation(
    with point: CGPoint, context: any LayoutContext,
    trace: inout Trace, affinity: inout RhTextSelection.Affinity,
    layoutRange: LayoutRange
  ) -> Bool {
    if layoutRange.isEmpty {
      let localOffset = layoutRange.localRange.lowerBound

      // if local offset is at or beyond the end of layout length, resolve to
      // the end of the node
      if localOffset >= self.layoutLength() {
        trace.emplaceBack(self, .index(self.childCount))
        return true
      }
      // otherwise, go on
      else {
        // trace with local offset
        guard let (tail, consumed) = Trace.tryFrom(localOffset, self),
          let lastPair = tail.last
        else { return false }
        trace.append(contentsOf: tail)

        // if the child of last trace element is ApplyNode, give special treatment
        if let childOfLast = lastPair.getChild(),
          let applyNode = childOfLast as? ApplyNode
        {
          // The content of ApplyNode is treated as being expanded in-place.
          // So keep the original point.
          _ = applyNode.resolveTextLocation(
            with: point, context, &trace, &affinity, layoutRange.deducted(with: consumed))
          return true
        }
        // otherwise, stop with current trace
        else {
          return true
        }
      }
    }
    else {
      let localOffset = layoutRange.localRange.lowerBound
      // trace nodes with [localOffset, _ + 1)
      guard let (tail, consumed) = Trace.tryFrom(localOffset, self),
        let lastPair = tail.last  // tail is non-empty
      else { return false }
      // append to trace
      trace.append(contentsOf: tail)

      let overConsumed = max(consumed - localOffset, 0)
      func adjusted(_ offset: Int) -> Int { offset + overConsumed }

      /// Resolve the last index of the trace.
      func resolveLastIndex() {
        precondition(lastPair.index.index() != nil)
        guard isTextNode(lastPair.node) else { return }
        assert(overConsumed == 0)  // for text node, over-consume never occurs
        let fraction = layoutRange.fraction
        let index = lastPair.index.index()! + (fraction > 0.5 ? layoutRange.count : 0)
        trace.moveTo(.index(index))
      }

      /// Resolve the last index of the trace.
      /// - Parameter childOfLast: The child of the last node in the trace
      func resolveLastIndex(childOfLast: Node) {
        precondition(lastPair.index.index() != nil)

        // in case of text node or over-consume, it's done
        guard !isTextNode(childOfLast),
          overConsumed == 0
        else { return }

        let location: Double
        do {
          let lowerBound = Double(localOffset - consumed)
          location = Double(layoutRange.count) * layoutRange.fraction + lowerBound
        }
        let fraction = location / Double(childOfLast.layoutLength())

        // resolve index with fraction
        let index = lastPair.index.index()! + (fraction > 0.5 ? 1 : 0)
        trace.moveTo(.index(index))
      }

      guard let childOfLast = lastPair.getChild()
      else {
        resolveLastIndex()
        return true
      }

      switch childOfLast {
      case let matNode where isMathNode(matNode) || isArrayNode(matNode):
        // MathNode uses coordinate relative to glyph origin to resolve text location
        let contextOffset = adjusted(layoutRange.contextRange.lowerBound)
        guard
          let segmentFrame =
            context.getSegmentFrame(for: contextOffset, .upstream, matNode)
        else {
          resolveLastIndex(childOfLast: matNode)
          return true
        }

        let newPoint = point.relative(to: segmentFrame.frame.origin)
          // The origin of the segment frame may be incorrect for MathNode due to
          // the discrepancy between TextKit and our math layout system.
          // We obtain the coorindate relative to glyph origin by subtracting the
          // baseline position which is aligned across the two systems.
          .with(yDelta: -segmentFrame.baselinePosition)
        // recurse and fix on need
        let modified =
          matNode.resolveTextLocation(
            with: newPoint, context: context, trace: &trace, affinity: &affinity)
        if !modified { resolveLastIndex(childOfLast: matNode) }
        return true

      case let elementNode as ElementNode:
        // ElementNode uses coordinate relative to top-left corner to resolve text location
        let contextOffset = adjusted(layoutRange.contextRange.lowerBound)
        guard
          let segmentFrame = context.getSegmentFrame(for: contextOffset, affinity, self)
        else {
          resolveLastIndex(childOfLast: elementNode)
          return true
        }
        let newPoint = point.relative(to: segmentFrame.frame.origin)
        // recurse and fix on need
        let modified =
          elementNode.resolveTextLocation(
            with: newPoint, context: context, trace: &trace, affinity: &affinity)
        if !modified { resolveLastIndex(childOfLast: elementNode) }
        return true

      case let applyNode as ApplyNode:
        // The content of ApplyNode is treated as being expanded in-place.
        // So keep the original point.
        let modified = applyNode.resolveTextLocation(
          with: point, context, &trace, &affinity, layoutRange.deducted(with: consumed))
        if !modified { resolveLastIndex(childOfLast: applyNode) }
        return true

      case is SimpleNode, is TextNode:
        // fallback and return
        resolveLastIndex(childOfLast: childOfLast)
        return true

      default:
        // UNEXPECTED for current node types. May change in the future.
        assertionFailure("unexpected node type: \(Swift.type(of: childOfLast))")
        // fallback and return
        resolveLastIndex(childOfLast: childOfLast)
        return true
      }
    }
  }

  final override func rayshoot(
    from path: ArraySlice<RohanIndex>,
    affinity: RhTextSelection.Affinity,
    direction: TextSelectionNavigation.Direction,
    context: LayoutContext, layoutOffset: Int
  ) -> RayshootResult? {
    guard let index = path.first?.index(),
      let localOffset = getLayoutOffset(index)
    else { return nil }

    if path.count == 1 {
      assert(index <= self.childCount)
      let newLayoutOffset = layoutOffset + localOffset
      guard
        let result = context.rayshoot(
          from: newLayoutOffset, affinity: affinity, direction: direction)
      else {
        return nil
      }
      return LayoutUtils.rayshootFurther(
        newLayoutOffset, affinity, direction, result, context)
    }
    else {
      guard index < self.childCount else { return nil }
      return _children[index].rayshoot(
        from: path.dropFirst(), affinity: affinity,
        direction: direction, context: context,
        layoutOffset: layoutOffset + localOffset)
    }
  }

  // MARK: - Children

  final var childCount: Int { _children.count }

  final func getChild(_ index: Int) -> Node { _children[index] }

  /// Take all children from the node.
  final func takeChildren(inStorage: Bool) -> ElementStore {
    if inStorage { makeSnapshotOnce() }

    for child in _children {
      child.clearParent()
    }
    let children = exchange(&_children, with: [])
    _newlines.removeAll()

    if inStorage { contentDidChange() }
    return children
  }

  final func takeSubrange(_ range: Range<Int>, inStorage: Bool) -> ElementStore {
    if 0..<childCount == range { return takeChildren(inStorage: inStorage) }

    if inStorage { makeSnapshotOnce() }

    for child in _children[range] {
      child.clearParent()
    }
    let children = ElementStore(_children[range])
    _children.removeSubrange(range)
    _newlines.removeSubrange(range)

    if inStorage { contentDidChange() }
    return children
  }

  final func insertChild(_ node: Node, at index: Int, inStorage: Bool) {
    insertChildren(contentsOf: CollectionOfOne(node), at: index, inStorage: inStorage)
  }

  final func insertChildren<S: Collection<Node>>(
    contentsOf nodes: S, at index: Int, inStorage: Bool
  ) {
    guard !nodes.isEmpty else { return }

    if inStorage { makeSnapshotOnce() }

    _children.insert(contentsOf: nodes, at: index)
    _newlines.insert(contentsOf: nodes.lazy.map(\.isBlock), at: index)

    for node in nodes {
      node.setParent(self)
    }

    if inStorage { contentDidChange() }
  }

  final func removeChild(at index: Int, inStorage: Bool) {
    removeSubrange(index..<index + 1, inStorage: inStorage)
  }

  final func removeSubrange(_ range: Range<Int>, inStorage: Bool) {
    if inStorage { makeSnapshotOnce() }

    for child in _children[range] {
      child.clearParent()
    }
    _children.removeSubrange(range)
    _newlines.removeSubrange(range)

    if inStorage { contentDidChange() }
  }

  internal final func replaceChild(_ node: Node, at index: Int, inStorage: Bool) {
    precondition(_children[index] !== node && node.parent == nil)

    if inStorage { makeSnapshotOnce() }

    _children[index].clearParent()
    _children[index] = node
    _children[index].setParent(self)
    _newlines.setValue(isBlock: node.isBlock, at: index)

    if inStorage { contentDidChange() }
  }

  /// Compact mergeable nodes in a range.
  /// - Returns: true if compacted
  final func compactSubrange(_ range: Range<Int>, inStorage: Bool) -> Bool {
    guard range.count > 1 else { return false }

    if inStorage { makeSnapshotOnce() }

    // perform compact
    guard let newRange = ElementNode.compactSubrange(&_children, range, self)
    else { return false }
    assert(range.lowerBound == newRange.lowerBound)

    // update newlines
    _newlines.replaceSubrange(range, with: _children[newRange].lazy.map(\.isBlock))

    if inStorage { contentDidChange() }
    return true
  }

  /// Compact nodes in a range so that there are no neighbouring mergeable nodes.
  /// - Note: Each merged node is set with parent.
  /// - Returns: the range of compacted nodes, or nil if no compact
  private static func compactSubrange(
    _ nodes: inout ElementStore, _ range: Range<Int>, _ parent: Node
  ) -> Range<Int>? {
    precondition(range.lowerBound >= 0 && range.upperBound <= nodes.count)

    func isCandidate(_ i: Int) -> Bool { nodes[i].type == .text }

    func isMergeable(_ i: Int, _ j: Int) -> Bool {
      nodes[i].type == .text && nodes[j].type == .text
    }

    func mergeSubrange(_ range: Range<Int>) -> Node {
      let string: RhString = nodes[range]
        .lazy.map { ($0 as! TextNode).string }
        .reduce(into: RhString(), +=)
      let node = TextNode(string)
      node.setParent(parent)
      return node
    }

    var i = range.lowerBound
    var j = i
    // invariant:
    //  (a) j <= upperBound;
    //  (b) i <= j;
    //  (c) current[..< i] is the compact result of original[..< j];
    //  (d) current[i ..< j] is vacuum.
    while j < range.upperBound {
      if !isCandidate(j) {
        if i != j { nodes[i] = nodes[j] }
        i += 1
        j += 1
      }
      else {
        // merge as much as possible
        var k = j + 1
        // invariant: [j, k) is mergeable
        while k < range.upperBound && isMergeable(j, k) {
          k += 1
        }
        if j + 1 == k {  // only one node
          if i != j { nodes[i] = nodes[j] }
          i += 1
          j = k
        }
        else {  // multiple nodes
          nodes[i] = mergeSubrange(j..<k)
          i += 1
          j = k
        }
      }
    }
    assert(j == range.upperBound)
    // remove vacuum
    guard i != j else { return nil }
    nodes.removeSubrange(i..<j)
    return range.lowerBound..<i
  }

  // MARK: - Facilities for Layout

  private struct SnapshotRecord: CustomStringConvertible {
    let nodeId: NodeIdentifier
    let insertNewline: Bool
    let layoutLength: Int

    init(_ node: Node, _ insertNewline: Bool) {
      self.nodeId = node.id
      self.insertNewline = insertNewline
      self.layoutLength = node.layoutLength()
    }

    private init(_ nodeId: NodeIdentifier, _ insertNewline: Bool, _ layoutLength: Int) {
      self.nodeId = nodeId
      self.insertNewline = insertNewline
      self.layoutLength = layoutLength
    }

    /// Create a placeholder record with given layout length.
    static func placeholder(_ layoutLength: Int) -> SnapshotRecord {
      SnapshotRecord(NodeIdAllocator.allocate(), false, layoutLength)
    }

    var description: String {
      "(\(nodeId),\(layoutLength)+\(insertNewline.intValue))"
    }
  }

  private enum LayoutMark { case none; case dirty; case deleted; case added }

  private struct ExtendedRecord {
    let mark: LayoutMark
    let nodeId: NodeIdentifier
    let insertNewline: Bool
    let layoutLength: Int

    init(_ mark: LayoutMark, _ record: SnapshotRecord) {
      self.mark = mark
      self.nodeId = record.nodeId
      self.insertNewline = record.insertNewline
      self.layoutLength = record.layoutLength
    }

    init(_ mark: LayoutMark, _ node: Node, _ insertNewline: Bool) {
      self.mark = mark
      self.nodeId = node.id
      self.insertNewline = insertNewline
      self.layoutLength = node.layoutLength()
    }

    var isAddedOrDirty: Bool { mark == .added || mark == .deleted }
  }
}
