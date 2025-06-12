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

  final override func getPosition(_ layoutOffset: Int) -> PositionResult<RohanIndex> {
    guard 0..._layoutLength ~= layoutOffset else {
      return .failure(SatzError(.InvalidLayoutOffset))
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

  /// **workaround for unexpected behaviour** around the end of the layout,
  /// including: a) the last paragraph with no text occasionally uses the
  /// alignment of the previous paragraph, b) the block equation in position
  /// of the second last paragraph have a wrong horizontal shift.
  private class func newlineArrayMask() -> Bool { self.type == .root }

  /// Returns true if node is allowed to be empty.
  final var isVoidable: Bool { NodePolicy.isVoidableElement(type) }

  final var isParagraphContainer: Bool { NodePolicy.isParagraphContainer(type) }

  final func isMergeable(with other: ElementNode) -> Bool {
    NodePolicy.isMergeableElements(self.type, other.type)
  }

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
    if let snapshotRecords = _snapshotRecords {
      return snapshotRecords.map(\.description)
    }
    return nil
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
      _snapshotRecords =
        zip(_children, _newlines.asBitArray).map { SnapshotRecord($0, $1) }
    }
  }

  /// Perform layout for fromScratch=true.
  private final func _performLayoutFromScratch(_ context: LayoutContext) -> Int {
    precondition(_children.count == _newlines.count)

    if _children.isEmpty {
      if self.isPlaceholderActive {
        context.insertText("⬚", self)
        return 1
      }
      return 0
    }

    assert(_children.isEmpty == false)

    var sum = 0

    // reconcile content backwards
    for (node, insertNewline) in zip(_children, _newlines.asBitArray).reversed() {
      if insertNewline {
        context.insertNewline(self)
        sum += 1
      }
      sum += node.performLayout(context, fromScratch: true)
    }

    refreshParagraphStyle(context, { _ in true })

    return sum
  }

  /// Perform layout for fromScratch=false when snapshot was not made.
  private final func _performLayoutSimple(_ context: LayoutContext) -> Int {
    precondition(_snapshotRecords == nil && _children.count == _newlines.count)

    // _performLayoutSimple() is called only when the node is marked dirty and
    // the set of child nodes is not added/deleted, so we can safely assume that
    // the children are not empty.

    assert(_children.isEmpty == false)

    if _children.isEmpty {
      if self.isPlaceholderActive {
        context.insertText("⬚", self)
        return 1
      }
      return 0
    }

    var dirtyNodes: Set<Int> = []
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
        dirtyNodes.insert(i)
        if _newlines[i] {
          context.skipBackwards(1)
          sum += 1
        }
        sum += _children[i].performLayout(context, fromScratch: false)
        i -= 1
      }
    }

    if self.isParagraphContainer {
      refreshParagraphStyle(context, { dirtyNodes.contains($0) })
    }

    return sum
  }

  /// Perform layout for fromScratch=false when snapshot has been made.
  private final func _performLayoutFull(_ context: LayoutContext) -> Int {
    precondition(_snapshotRecords != nil && _children.count == _newlines.count)

    if _children.isEmpty {
      // remove previous layout
      context.deleteBackwards(_layoutLength)
      // insert placeholder if needed
      if self.isPlaceholderActive {
        context.insertText("⬚", self)
        return 1
      }
      return 0
    }

    assert(_children.isEmpty == false)

    var sum = 0

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
    do {
      let vacuumRange = vacuumRange ?? 0..<0
      refreshParagraphStyle(
        context, { i in current[i].isAddedOrDirty || vacuumRange.contains(i) })
    }

    return sum
  }

  /// Refresh paragraph style for children that match the predicate.
  /// - Precondition: layout cursor is at the start of the node.
  /// - Postcondition: the cursor is unchanged.
  @inline(__always)
  private final func refreshParagraphStyle(
    _ context: LayoutContext, _ predicate: (Int) -> Bool
  ) {
    guard self.isParagraphContainer else { return }

    var location = context.layoutCursor
    for i in 0..<_children.count {
      let end = location + _children[i].layoutLength()
      if predicate(i) { context.addParagraphStyle(_children[i], location..<end) }
      location = end + _newlines[i].intValue
    }
    if _newlines.last == true { context.addParagraphStyle(self, location - 1..<location) }
  }

  private final func getLayoutOffset(_ index: Int) -> Int? {
    guard index <= childCount else { return nil }
    let range = 0..<index

    if _children.isEmpty {
      // "0" whether placeholder is active or not.
      return 0
    }
    else {
      assert(isPlaceholderActive == false)
      let s1 = _children[range].lazy.map { $0.layoutLength() }.reduce(0, +)
      let s2 = _newlines.asBitArray[range].lazy.map(\.intValue).reduce(0, +)
      return s1 + s2
    }
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
      assert(path.count == 1 && endPath.count == 1)
      assert(index == endIndex && index == 0)
      let layoutRange = layoutOffset..<layoutOffset + 1
      return context.enumerateTextSegments(
        layoutRange, type: type, options: options,
        // use placeholderBlock
        using: placeholderBlock(_:_:_:))
    }
    else if path.count == 1 || endPath.count == 1 || index != endIndex {
      guard let offset = TreeUtils.computeLayoutOffset(for: path, self),
        let endOffset = TreeUtils.computeLayoutOffset(for: endPath, self)
      else { assertionFailure("Invalid path"); return false }
      let layoutRange = layoutOffset + offset..<layoutOffset + endOffset
      return context.enumerateTextSegments(
        layoutRange, type: type, options: options,
        // use basicBlock
        using: basicBlock(_:_:_:))
    }
    // ASSERT: path.count > 1 && endPath.count > 1 && index == endIndex
    else {  // if paths don't branch, recurse
      guard index < self.childCount,
        let offset = getLayoutOffset(index)
      else { assertionFailure("Invalid path"); return false }
      return _children[index].enumerateTextSegments(
        path.dropFirst(), endPath.dropFirst(), context: context,
        layoutOffset: layoutOffset + offset, originCorrection: originCorrection,
        type: type, options: options,
        // use block
        using: block)
    }
  }

  final override func resolveTextLocation(
    with point: CGPoint, context: any LayoutContext, layoutOffset: Int,
    trace: inout Trace, affinity: inout SelectionAffinity
  ) -> Bool {
    guard let result = context.getLayoutRange(interactingAt: point) else { return false }

    let layoutRange = LayoutRange(result.layoutRange, result.layoutRange, result.fraction)
    affinity = result.affinity

    return resolveTextLocation(
      with: point, context: context, layoutOffset: layoutOffset,
      trace: &trace, affinity: &affinity, layoutRange: layoutRange)
  }

  /// Resolve the text location at the given point and layout range.
  /// - Parameters:
  ///   - point: the point relative to the layout context, relative to the
  ///       **top-left corner** of the context. For TextKit, it's relative to
  ///       the **top-left corner** of the container. For MathListLayoutContext,
  ///       it's relative to the **top-left corner** of the math list, which is
  ///       usually different from the glyph origin.
  /// - Returns: true if trace is modified.
  final func resolveTextLocation(
    with point: CGPoint, context: any LayoutContext, layoutOffset: Int,
    trace: inout Trace, affinity: inout SelectionAffinity,
    layoutRange: LayoutRange
  ) -> Bool {
    if layoutRange.isEmpty {
      let localOffset = layoutRange.localRange.lowerBound
      guard localOffset <= _layoutLength else {
        trace.emplaceBack(self, .index(self.childCount))
        return true
      }
      let result = Trace.getTraceSegment(localOffset, self)

      switch result {
      case .terminal(let value, _):
        trace.append(contentsOf: value)
        return true

      case .halfway(let value, let consumed):
        assert(value.isEmpty == false)
        trace.append(contentsOf: value)

        // if the tip is ApplyNode, recurse into it.
        if let child = trace.last?.getChild(),
          let applyNode = child as? ApplyNode
        {
          // The content of ApplyNode is treated as being expanded in-place.
          // So keep the original point.
          _ = applyNode.resolveTextLocation(
            with: point, context: context,
            layoutOffset: layoutOffset + consumed,
            trace: &trace, affinity: &affinity,
            layoutRange: layoutRange.safeSubtracting(consumed))
          return true
        }
        else {
          return true
        }

      case .null:
        return false
      case .failure:
        return false
      }
    }
    else {
      let localOffset = layoutRange.localRange.lowerBound

      /// compute fraction from upstream of child.
      /// - Parameter startOffset: the offset of the child relative to the start
      ///     of this node.
      func computeFraction(_ startOffset: Int, _ child: Node) -> Double {
        let lowerBound = Double(localOffset - startOffset)
        let location = Double(layoutRange.count) * layoutRange.fraction + lowerBound
        let fraction = location / Double(child.layoutLength())
        return fraction
      }

      let result = Trace.getTraceSegment(localOffset, self)
      switch result {
      case .terminal(let value, let target):
        assert(value.isEmpty == false)
        guard let last = value.last else { return false }

        switch last.node {
        case _ as TextNode:
          trace.append(contentsOf: value)
          let fraction = layoutRange.fraction
          let resolved = last.index.index()! + (fraction > 0.5 ? layoutRange.count : 0)
          trace.moveTo(.index(resolved))
          return true

        case let node as ElementNode:
          let index = last.index.index()!
          if index == node.childCount {
            trace.append(contentsOf: value)
            return true
          }
          else {
            let child = node.getChild(index)
            if isSimpleNode(child) {
              trace.append(contentsOf: value)
              let fraction = computeFraction(target, child)
              let resolved = index + (fraction > 0.5 ? 1 : 0)
              trace.moveTo(.index(resolved))
              return true
            }
            else {
              assertionFailure("unexpected node type: \(Swift.type(of: child))")
              return false
            }
          }

        default:
          assertionFailure("unexpected node type: \(Swift.type(of: last.node))")
          return false
        }

      case .halfway(let value, let consumed):
        assert(value.isEmpty == false)
        guard let last = value.last,
          let child = last.getChild(),
          let index = last.index.index()
        else { return false }
        assert(child.isPivotal)

        func fallbackLastIndex() {
          let fraction = computeFraction(consumed, child)
          let resolved = index + (fraction > 0.5 ? 1 : 0)
          trace.moveTo(.index(resolved))
        }

        switch child {
        case let node as GenMathNode:
          trace.append(contentsOf: value)
          let modified = node.resolveTextLocation(
            with: point, context: context, layoutOffset: layoutOffset + consumed,
            trace: &trace, affinity: &affinity)
          if !modified { fallbackLastIndex() }
          return true

        case let applyNode as ApplyNode:
          // content of ApplyNode is effectively expanded in-place. Thus we recurse
          // with the original point and subtract consumed from the layout range.
          trace.append(contentsOf: value)
          let modified = applyNode.resolveTextLocation(
            with: point, context: context, layoutOffset: layoutOffset + consumed,
            trace: &trace, affinity: &affinity,
            // subtract consumed from the layout range
            layoutRange: layoutRange.safeSubtracting(consumed))
          if !modified { fallbackLastIndex() }
          return true

        default:
          assertionFailure("unexpected node type: \(Swift.type(of: child))")
          // fallback and return
          fallbackLastIndex()
          return true
        }
      case .null:
        return false
      case .failure:
        return false
      }
    }
  }

  final override func rayshoot(
    from path: ArraySlice<RohanIndex>,
    affinity: SelectionAffinity,
    direction: TextSelectionNavigation.Direction,
    context: LayoutContext, layoutOffset: Int
  ) -> RayshootResult? {
    guard let index = path.first?.index(),
      let localOffset = getLayoutOffset(index)
    else { return nil }

    if path.count == 1 {
      assert(index <= self.childCount)
      let newOffset = layoutOffset + localOffset
      guard
        var result = context.rayshoot(
          from: newOffset, affinity: affinity, direction: direction)
      else {
        return nil
      }

      // apply horizontal shift for placeholder.
      if isPlaceholderActive {
        assert(localOffset == 0)
        if let segmentFrame = context.getSegmentFrame(layoutOffset + 1, .upstream) {
          result.position.x = (result.position.x + segmentFrame.frame.origin.x) / 2
        }
      }

      return LayoutUtils.relayRayshoot(
        newOffset, affinity, direction, result, context)
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
