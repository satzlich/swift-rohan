// Copyright 2024-2025 Lie Yan

import Algorithms
import BitCollections
import CoreGraphics
import DequeModule
import _RopeModule

public class ElementNode: Node {
  public typealias Store = Deque<Node>
  private final var _children: Store

  /// - Warning: It's important to sync with the other `init` method.
  public init(_ children: Store) {
    // children and newlines
    self._children = children
    self._newlines = NewlineArray(children.lazy.map(\.isBlock))
    // length
    let summary = children.lazy.map(\.lengthSummary).reduce(.zero, +)
    self._layoutLength = summary.layoutLength
    // flags
    self._isDirty = false

    super.init()
    self._setUp()
  }

  /// - Warning: It's important to sync with the other `init` method.
  public init(_ children: [Node] = []) {
    // children and newlines
    self._children = Store(children)
    self._newlines = NewlineArray(children.lazy.map(\.isBlock))
    // length
    let summary = children.lazy.map(\.lengthSummary).reduce(.zero, +)
    self._layoutLength = summary.layoutLength
    // flags
    self._isDirty = false

    super.init()
    self._setUp()
  }

  internal init(deepCopyOf elementNode: ElementNode) {
    // children and newlines
    self._children = Store(elementNode._children.lazy.map { $0.deepCopy() })
    self._newlines = elementNode._newlines
    // length
    self._layoutLength = elementNode._layoutLength
    // flags
    self._isDirty = false

    super.init()
    self._setUp()
  }

  private final func _setUp() {
    for child in _children {
      child.setParent(self)
    }
  }

  func cloneEmpty() -> ElementNode {
    preconditionFailure("overriding required")
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case children }

  public required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    var childrenContainer = try container.nestedUnkeyedContainer(forKey: .children)
    // children and newlines
    self._children = try NodeSerdeUtils.decodeListOfNodes(from: &childrenContainer)
    self._newlines = NewlineArray(_children.lazy.map(\.isBlock))
    // length
    let summary = _children.lazy.map(\.lengthSummary).reduce(.zero, +)
    self._layoutLength = summary.layoutLength
    // flags
    self._isDirty = false

    try super.init(from: decoder)
    self._setUp()
  }

  public override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self._children, forKey: .children)
    try super.encode(to: encoder)
  }

  /// Encode this node but with children replaced with given children.
  ///
  /// Helper function for encoding partial nodes. Override this method to encode
  /// extra properties.
  internal func encode<S>(to encoder: any Encoder, withChildren children: S) throws
  where S: Collection, S.Element == PartialNode, S: Encodable {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(children, forKey: .children)
    try super.encode(to: encoder)
  }

  // This is used for serialization.
  final func getChildren_readonly() -> Store { _children }

  // MARK: - Content

  /// Returns true if node is allowed to be empty.
  final var isVoidable: Bool { NodePolicy.isVoidableElement(type) }

  final var isParagraphContainer: Bool { NodePolicy.isParagraphContainer(type) }

  final func isMergeable(with other: ElementNode) -> Bool {
    NodePolicy.isMergeableElements(self.type, other.type)
  }

  /// Create a node for splitting at the end.
  func createSuccessor() -> ElementNode? { nil }

  override final func getChild(_ index: RohanIndex) -> Node? {
    guard let index = index.index(),
      index < _children.count
    else { return nil }
    return _children[index]
  }

  override final func contentDidChange(delta: LengthSummary, inStorage: Bool) {
    // apply delta
    _layoutLength += delta.layoutLength

    // content change implies dirty
    if inStorage { _isDirty = true }

    // propagate to parent
    parent?.contentDidChange(delta: delta, inStorage: inStorage)
  }

  private final func contentDidChangeLocally(
    childrenDelta: LengthSummary,
    placeholderDelta: Int,
    newlinesDelta: Int,
    inStorage: Bool
  ) {
    // apply delta excluding placeholder and newlines
    _layoutLength += childrenDelta.layoutLength

    // content change implies dirty
    if inStorage { _isDirty = true }

    var delta = childrenDelta
    // change to newlines should be added to propagated delta
    delta.layoutLength += placeholderDelta + newlinesDelta
    // propagate to parent
    parent?.contentDidChange(delta: delta, inStorage: inStorage)
  }

  // MARK: - Location

  override final func firstIndex() -> RohanIndex? { .index(0) }

  override final func lastIndex() -> RohanIndex? { .index(_children.count) }

  // MARK: - Styles

  override final func resetCachedProperties(recursive: Bool) {
    super.resetCachedProperties(recursive: recursive)
    if recursive {
      _children.forEach { $0.resetCachedProperties(recursive: true) }
    }
  }

  // MARK: - Layout

  /// layout length excluding additional units added by `isBlock`, `newlines`,
  /// `showPlaceholder`
  private final var _layoutLength: Int
  /// true if a newline should be added after i-th child
  private final var _newlines: NewlineArray

  override final func layoutLength() -> Int {
    needsLeadingZWSP.intValue + isPlaceholderActive.intValue + _layoutLength
      + _newlines.newlineCount
  }

  override final var isBlock: Bool { NodePolicy.isBlockElement(type) }

  private final var _isDirty: Bool
  override final var isDirty: Bool { _isDirty }

  /// true if a leading ZWSP should be added
  final var needsLeadingZWSP: Bool { NodePolicy.needsLeadingZWSP(type) }

  /// true if placeholder should be shown when the node is empty
  final var isPlaceholderEnabled: Bool { NodePolicy.isPlaceholderEnabled(type) }

  /// true if placeholder should be shown
  final var isPlaceholderActive: Bool { isPlaceholderEnabled && _children.isEmpty }

  /// lossy snapshot of original children
  private final var _snapshotRecords: [SnapshotRecord]? = nil
  /// lossy snapshot of original children (for debug only)
  final var snapshotRecords: [SnapshotRecord]? { _snapshotRecords }

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

  override final func performLayout(_ context: LayoutContext, fromScratch: Bool) {
    if fromScratch {
      _performLayoutFromScratch(context)
    }
    else if _snapshotRecords == nil {
      _performLayoutSimple(context)
    }
    else {
      _performLayoutFull(context)
    }

    // clear
    _isDirty = false
    _snapshotRecords = nil
  }

  /// Perform layout for fromScratch=true.
  private final func _performLayoutFromScratch(_ context: LayoutContext) {
    precondition(_children.count == _newlines.count)

    // reconcile content
    for (node, insertNewline) in zip(_children, _newlines.asBitArray).reversed() {
      if insertNewline { context.insertNewline(self) }
      node.performLayout(context, fromScratch: true)
    }

    // add paragraph style
    if self.isParagraphContainer {
      var location = context.layoutCursor
      for i in 0..<childCount {
        let end = location + _children[i].layoutLength() + _newlines[i].intValue
        context.addParagraphStyle(_children[i], location..<end)
        location = end
      }
    }

    if self.isPlaceholderActive { context.insertText(Strings.dottedSquare, self) }
    if self.needsLeadingZWSP { context.insertText(Strings.ZWSP, self) }
  }

  /// Perform layout for fromScratch=false when snapshot was not made.
  private final func _performLayoutSimple(_ context: LayoutContext) {
    precondition(_snapshotRecords == nil && _children.count == _newlines.count)

    var i = _children.count - 1

    while true {
      if i < 0 { break }

      // skip clean
      while i >= 0 && !_children[i].isDirty {
        if _newlines[i] { context.skipBackwards(1) }
        context.skipBackwards(_children[i].layoutLength())
        i -= 1
      }
      assert(i < 0 || _children[i].isDirty)

      // process dirty
      if i >= 0 {
        if _newlines[i] { context.skipBackwards(1) }
        _children[i].performLayout(context, fromScratch: false)
        i -= 1
      }
    }

    // Since _performLayoutSimple() is called only when the set of child nodes
    // are not added/deleted, and `isPlaceholderActive==true` implies
    // `_children.isEmpty`, we can safely assume that the placeholder is not
    // active.
    assert(self.isPlaceholderActive == false)
    // For robustness, we still process the case when `isPlaceholderActive==true`.
    if self.isPlaceholderActive { context.insertText(Strings.dottedSquare, self) }

    if self.needsLeadingZWSP { context.skipBackwards(1) }
  }

  /// Perform layout for fromScratch=false when snapshot has been made.
  private final func _performLayoutFull(_ context: LayoutContext) {
    precondition(_snapshotRecords != nil && _children.count == _newlines.count)

    // ID's of current children
    let currentIds = Set(_children.map(\.id))
    // ID's of dirty (current) children
    let dirtyIds = Set(_children.lazy.filter(\.isDirty).map(\.id))
    // ID's of original children
    let originalIds = Set(_snapshotRecords!.map(\.nodeId))

    // records of current children
    let current: [ExtendedRecord] = zip(_children, _newlines.asBitArray)
      .map { (node, insertNewline) in
        let mark: LayoutMark =
          !originalIds.contains(node.id)
          ? .added
          : (node.isDirty ? .dirty : .none)
        return ExtendedRecord(mark, node, insertNewline)
      }
    // records of original children
    let original: [ExtendedRecord] = _snapshotRecords!.map { record in
      !currentIds.contains(record.nodeId)
        ? ExtendedRecord(.deleted, record)
        : dirtyIds.contains(record.nodeId)
          ? ExtendedRecord(.dirty, record)
          : ExtendedRecord(.none, record)
    }

    func processInsertNewline(_ original: ExtendedRecord, _ current: ExtendedRecord) {
      precondition(original.nodeId == current.nodeId)
      switch (original.insertNewline, current.insertNewline) {
      case (false, false):
        break
      case (false, true):
        context.insertNewline(self)
      case (true, false):
        context.deleteBackwards(1)
      case (true, true):
        context.skipBackwards(1)
      }
    }

    // current range covering deleted parts with padding
    var deletedRange: Range<Int>?

    var i = current.count - 1
    var j = original.count - 1

    // invariant:
    //  [cursor, ...) is consistent with (i, ...)
    //  [0, cursor) is consistent with [0, j]
    while true {
      if i < 0 && j < 0 { break }

      // process added and deleted
      // (It doesn't matter whether to process add or delete first.)
      do {
        if j >= 0 && original[j].mark == .deleted {
          switch (deletedRange, i >= 0) {
          case (.none, false):
            deletedRange = 0..<1
          case (.none, true):
            deletedRange = max(0, i - 1)..<min(childCount, i + 2)
          case (.some(let range), false):
            deletedRange = 0..<range.upperBound
          case (.some(let range), true):
            deletedRange = max(0, i - 1)..<range.upperBound
          }
        }
        while j >= 0 && original[j].mark == .deleted {
          if original[j].insertNewline { context.deleteBackwards(1) }
          context.deleteBackwards(original[j].layoutLength)
          j -= 1
        }
        assert(j < 0 || [.none, .dirty].contains(original[j].mark))
      }

      while i >= 0 && current[i].mark == .added {
        if current[i].insertNewline { context.insertNewline(self) }
        _children[i].performLayout(context, fromScratch: true)
        i -= 1
      }
      assert(i < 0 || [.none, .dirty].contains(current[i].mark))

      // skip none
      while i >= 0 && current[i].mark == .none,
        j >= 0 && original[j].mark == .none
      {
        assert(current[i].nodeId == original[j].nodeId)
        processInsertNewline(original[j], current[i])
        context.skipBackwards(current[i].layoutLength)
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
        processInsertNewline(original[j], current[i])
        _children[i].performLayout(context, fromScratch: false)
        i -= 1
        j -= 1
      }
    }

    // add paragraph style
    if self.isParagraphContainer {
      var location = context.layoutCursor
      for i in 0..<childCount {
        let end = location + _children[i].layoutLength() + _newlines[i].intValue
        if current[i].isAddedOrDirty || deletedRange?.contains(i) == true {
          context.addParagraphStyle(_children[i], location..<end)
        }
        location = end
      }
    }

    if self.isPlaceholderActive { context.insertText(Strings.dottedSquare, self) }
    if self.needsLeadingZWSP { context.skipBackwards(1) }
  }

  override final func getLayoutOffset(_ index: RohanIndex) -> Int? {
    guard let index = index.index() else { return nil }
    return getLayoutOffset(index)
  }

  final func getLayoutOffset(_ index: Int) -> Int? {
    guard index <= childCount else { return nil }
    let range = 0..<index
    let zwsp = needsLeadingZWSP.intValue
    let placeholder = isPlaceholderActive.intValue
    let s1 = _children[range].lazy.map { $0.layoutLength() }.reduce(0, +)
    let s2 = _newlines.asBitArray[range].lazy.map(\.intValue).reduce(0, +)
    return zwsp + placeholder + s1 + s2
  }

  override final func getRohanIndex(_ layoutOffset: Int) -> (RohanIndex, consumed: Int)? {
    guard let (i, consumed) = getChildIndex(layoutOffset) else { return nil }
    return (.index(i), consumed)
  }

  /// Returns the index of the child picked by `[layoutOffset, _ + 1)` together
  /// with the layout offset of the child.
  /// - Returns: nil if layout offset is out of bounds. Otherwise, returns (k, s)
  ///     where k is the index of the child containing the layout offset and s is
  ///     the layout offset of the child.
  private final func getChildIndex(_ layoutOffset: Int) -> (Int, childOffset: Int)? {
    guard 0..<layoutLength() ~= layoutOffset else { return nil }

    var (k, s) = (0, needsLeadingZWSP.intValue + isPlaceholderActive.intValue)
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

  override final func enumerateTextSegments(
    _ path: ArraySlice<RohanIndex>, _ endPath: ArraySlice<RohanIndex>,
    _ context: any LayoutContext, layoutOffset: Int, originCorrection: CGPoint,
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
        path.dropFirst(), endPath.dropFirst(), context,
        layoutOffset: layoutOffset + offset, originCorrection: originCorrection,
        type: type, options: options, using: block)
    }
  }

  /// Resolve the text location at the given point.
  /// - Returns: true if trace is modified.
  override final func resolveTextLocation(
    with point: CGPoint, _ context: any LayoutContext,
    _ trace: inout Trace, _ affinity: inout RhTextSelection.Affinity
  ) -> Bool {
    guard let result = context.getLayoutRange(interactingAt: point)
    else { return false }

    let contextRange = result.layoutRange
    let layoutRange = LayoutRange(contextRange, contextRange, result.fraction)

    affinity = result.affinity

    return resolveTextLocation(with: point, context, &trace, &affinity, layoutRange)
  }

  /**
   Resolve the text location at the given point and (layoutRange, fraction) pair.
  
   - Returns: true if trace is modified.
   - Note: For TextLayoutContext, the point is relative to the __top-left corner__ of
   the container. For MathLayoutContext, the point is relative to the __top-left corner__
   of the math list.
   */
  final func resolveTextLocation(
    with point: CGPoint, _ context: any LayoutContext,
    _ trace: inout Trace, _ affinity: inout RhTextSelection.Affinity,
    _ layoutRange: LayoutRange
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
        guard !isTextNode(childOfLast), overConsumed == 0 else { return }

        let location = {
          let lowerBound = Double(localOffset - consumed)
          return Double(layoutRange.count) * layoutRange.fraction + lowerBound
        }()
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
      case let matNode as MathNode:
        // MathNode uses coordinate relative to glyph origin to resolve text location
        let contextOffset = adjusted(layoutRange.contextRange.lowerBound)
        guard
          let segmentFrame = context.getSegmentFrame(
            for: contextOffset, .upstream, matNode)
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
          matNode.resolveTextLocation(with: newPoint, context, &trace, &affinity)
        if !modified { resolveLastIndex(childOfLast: matNode) }
        return true

      // COPY VERBATIM from MathNode
      case let matNode as ArrayNode:
        // _MatrixNode uses coordinate relative to glyph origin to resolve text location
        let contextOffset = adjusted(layoutRange.contextRange.lowerBound)
        guard
          let segmentFrame = context.getSegmentFrame(
            for: contextOffset, .upstream, matNode)
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
          matNode.resolveTextLocation(with: newPoint, context, &trace, &affinity)
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
          elementNode.resolveTextLocation(with: newPoint, context, &trace, &affinity)
        if !modified { resolveLastIndex(childOfLast: elementNode) }
        return true

      case let applyNode as ApplyNode:
        // The content of ApplyNode is treated as being expanded in-place.
        // So keep the original point.
        let modified = applyNode.resolveTextLocation(
          with: point, context, &trace, &affinity, layoutRange.deducted(with: consumed))
        if !modified { resolveLastIndex(childOfLast: applyNode) }
        return true

      case is _SimpleNode, is TextNode:
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

  override final func rayshoot(
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

  public final var childCount: Int { _children.count }

  public final func getChild(_ index: Int) -> Node { _children[index] }

  /// Take all children from the node.
  public final func takeChildren(inStorage: Bool) -> Store {
    // pre update
    if inStorage { makeSnapshotOnce() }

    var delta = LengthSummary.zero
    _children.forEach { child in
      child.clearParent()
      delta -= child.lengthSummary
    }

    // perform remove
    var placeholderDelta = -isPlaceholderActive.intValue
    let children = exchange(&_children, with: [])
    placeholderDelta += isPlaceholderActive.intValue

    // update newlines
    var newlinesDelta = -_newlines.newlineCount
    _newlines.removeAll()
    newlinesDelta += _newlines.newlineCount

    // post update
    contentDidChangeLocally(
      childrenDelta: delta, placeholderDelta: placeholderDelta,
      newlinesDelta: newlinesDelta,
      inStorage: inStorage)
    return children
  }

  public final func takeSubrange(_ range: Range<Int>, inStorage: Bool) -> Store {
    if 0..<childCount == range { return takeChildren(inStorage: inStorage) }

    // pre update
    if inStorage { makeSnapshotOnce() }

    var delta = LengthSummary.zero
    _children[range].forEach { child in
      child.clearParent()
      delta -= child.lengthSummary
    }

    // perform remove
    var placeholderDelta = -isPlaceholderActive.intValue
    let children = Store(_children[range])
    _children.removeSubrange(range)
    placeholderDelta += isPlaceholderActive.intValue

    // update newlines
    var newlinesDelta = -_newlines.newlineCount
    _newlines.removeSubrange(range)
    newlinesDelta += _newlines.newlineCount

    // post update
    contentDidChangeLocally(
      childrenDelta: delta, placeholderDelta: placeholderDelta,
      newlinesDelta: newlinesDelta,
      inStorage: inStorage)
    return children
  }

  public final func insertChild(_ node: Node, at index: Int, inStorage: Bool) {
    insertChildren(contentsOf: CollectionOfOne(node), at: index, inStorage: inStorage)
  }

  public final func insertChildren<S: Collection<Node>>(
    contentsOf nodes: S, at index: Int, inStorage: Bool
  ) {
    guard !nodes.isEmpty else { return }

    // pre update
    if inStorage { makeSnapshotOnce() }

    let delta = nodes.lazy.map(\.lengthSummary).reduce(.zero, +)

    // perform insert
    var placeholderDelta = -isPlaceholderActive.intValue
    _children.insert(contentsOf: nodes, at: index)
    placeholderDelta += isPlaceholderActive.intValue

    // update newlines
    var newlinesDelta = -_newlines.newlineCount
    _newlines.insert(contentsOf: nodes.lazy.map(\.isBlock), at: index)
    newlinesDelta += _newlines.newlineCount

    // post update
    nodes.forEach { $0.setParent(self) }

    contentDidChangeLocally(
      childrenDelta: delta, placeholderDelta: placeholderDelta,
      newlinesDelta: newlinesDelta,
      inStorage: inStorage)
  }

  public final func removeChild(at index: Int, inStorage: Bool) {
    removeSubrange(index..<index + 1, inStorage: inStorage)
  }

  public final func removeSubrange(_ range: Range<Int>, inStorage: Bool) {
    // pre update
    if inStorage { makeSnapshotOnce() }

    var delta = LengthSummary.zero
    _children[range].forEach { child in
      child.clearParent()
      delta -= child.lengthSummary
    }

    // perform remove
    var placeholderDelta = -isPlaceholderActive.intValue
    _children.removeSubrange(range)
    placeholderDelta += isPlaceholderActive.intValue

    // update newlines
    var newlinesDelta = -_newlines.newlineCount
    _newlines.removeSubrange(range)
    newlinesDelta += _newlines.newlineCount

    // post update
    contentDidChangeLocally(
      childrenDelta: delta, placeholderDelta: placeholderDelta,
      newlinesDelta: newlinesDelta,
      inStorage: inStorage)
  }

  internal final func replaceChild(_ node: Node, at index: Int, inStorage: Bool) {
    precondition(_children[index] !== node && node.parent == nil)
    // pre update
    if inStorage { makeSnapshotOnce() }

    // compute delta
    let delta = node.lengthSummary - _children[index].lengthSummary
    // perform replace
    _children[index].clearParent()
    _children[index] = node
    _children[index].setParent(self)

    // update newlines
    var newlinesDelta = -_newlines.newlineCount
    _newlines.setValue(isBlock: node.isBlock, at: index)
    newlinesDelta += _newlines.newlineCount

    // post update
    contentDidChangeLocally(
      childrenDelta: delta, placeholderDelta: 0, newlinesDelta: newlinesDelta,
      inStorage: inStorage)
  }

  /// Compact mergeable nodes in a range.
  /// - Returns: true if compacted
  internal final func compactSubrange(_ range: Range<Int>, inStorage: Bool) -> Bool {
    guard range.count > 1 else { return false }

    // pre update
    if inStorage { makeSnapshotOnce() }

    // perform compact
    guard let newRange = ElementNode.compactSubrange(&_children, range, self)
    else { return false }
    assert(range.lowerBound == newRange.lowerBound)

    // update newlines
    var newlinesDelta = -_newlines.newlineCount
    _newlines.replaceSubrange(range, with: _children[newRange].lazy.map(\.isBlock))
    newlinesDelta += _newlines.newlineCount
    assert(newlinesDelta == 0)

    // post update

    // compact doesn't affect _layout length_, so delta = 0.
    // Theorectically newlinesDelta = 0, but it doesn't harm to update it.
    contentDidChangeLocally(
      childrenDelta: .zero, placeholderDelta: 0, newlinesDelta: newlinesDelta,
      inStorage: inStorage)

    return true
  }

  /// Compact nodes in a range so that there are no neighbouring mergeable nodes.
  /// - Note: Each merged node is set with parent.
  /// - Returns: the range of compacted nodes, or nil if no compact
  private static func compactSubrange(
    _ nodes: inout Store, _ range: Range<Int>, _ parent: Node
  ) -> Range<Int>? {
    precondition(range.lowerBound >= 0 && range.upperBound <= nodes.count)

    func isCandidate(_ i: Int) -> Bool { nodes[i].type == .text }

    func isMergeable(_ i: Int, _ j: Int) -> Bool {
      nodes[i].type == .text && nodes[j].type == .text
    }

    func mergeSubrange(_ range: Range<Int>) -> Node {
      let string: BigString = nodes[range]
        .lazy.map { ($0 as! TextNode).string }
        .reduce(into: BigString(), +=)
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
}

// MARK: - Implementation Facilities for Layout

internal struct SnapshotRecord: CustomStringConvertible {
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
