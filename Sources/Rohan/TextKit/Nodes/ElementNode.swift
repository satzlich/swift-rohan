// Copyright 2024-2025 Lie Yan

import Algorithms
import BitCollections
import CoreGraphics
import DequeModule
import _RopeModule

public class ElementNode: Node {
  typealias BackStore = Deque<Node>
  private final var _children: BackStore

  public init(_ children: [Node] = []) {
    // children and newlines
    self._children = BackStore(children)
    self._newlines = NewlineArray(children.lazy.map(\.isBlock))
    // length
    let summary = children.lazy.map(\.lengthSummary).reduce(.zero, +)
    self._layoutLength = summary.layoutLength
    // flags
    self._isDirty = false

    super.init()

    for child in _children {
      assert(child.parent == nil)
      child.parent = self
    }
  }

  internal init(deepCopyOf elementNode: ElementNode) {
    // children and newlines
    self._children = BackStore(elementNode._children.lazy.map { $0.deepCopy() })
    self._newlines = elementNode._newlines
    // length
    self._layoutLength = elementNode._layoutLength
    // flags
    self._isDirty = false

    super.init()

    for child in _children {
      child.parent = self
    }
  }

  /** Returns true if node is allowed to be empty. */
  final var isVoidable: Bool { NodeType.isVoidableElement(nodeType) }

  // MARK: - Content

  override final func getChild(_ index: RohanIndex) -> Node? {
    guard let index = index.index(),
      index < _children.count
    else { return nil }
    return _children[index]
  }

  override final func contentDidChange(delta: LengthSummary, inContentStorage: Bool) {
    // apply delta
    _layoutLength += delta.layoutLength

    // content change implies dirty
    if inContentStorage { _isDirty = true }

    // propagate to parent
    parent?.contentDidChange(delta: delta, inContentStorage: inContentStorage)
  }

  private final func contentDidChangeLocally(
    delta: LengthSummary, newlinesDelta: Int, inContentStorage: Bool
  ) {
    _layoutLength += delta.layoutLength

    // content change implies dirty
    if inContentStorage { _isDirty = true }

    var delta = delta
    // change to newlines should be added to propagated layout length
    delta.layoutLength += newlinesDelta
    // propagate to parent
    parent?.contentDidChange(delta: delta, inContentStorage: inContentStorage)
  }

  // MARK: - Layout

  /** layout length excluding newlines */
  private final var _layoutLength: Int
  /** true if a newline should be added after i-th child */
  private final var _newlines: NewlineArray

  override final var layoutLength: Int { _layoutLength + _newlines.trueValueCount }

  override final var isBlock: Bool { NodeType.isBlockElement(nodeType) }

  private final var _isDirty: Bool
  override final var isDirty: Bool { _isDirty }

  /** lossy snapshot of original children */
  private final var _original: [SnapshotRecord]? = nil

  /** make snapshot once */
  private final func _makeSnapshotOnce() {
    guard _original == nil else { return }
    assert(_children.count == _newlines.count)
    _original = zip(_children, _newlines.asBitArray).map { SnapshotRecord($0, $1) }
  }

  private final func _performLayoutSimple(_ context: LayoutContext) {
    precondition(_original == nil && _children.count == _newlines.count)

    var i = _children.count - 1

    while true {
      if i < 0 { break }

      // skip clean
      while i >= 0 && !_children[i].isDirty {
        if _newlines[i] { context.skipBackwards(1) }
        context.skipBackwards(_children[i].layoutLength)
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
  }

  private final func _performLayoutFull(_ context: LayoutContext) {
    precondition(_original != nil && _children.count == _newlines.count)

    // ID's of current children
    let currentIds = Set(_children.map(\.id))
    // ID's of dirty (current) children
    let dirtyIds = Set(_children.lazy.filter(\.isDirty).map(\.id))
    // ID's of original children
    let originalIds = Set(_original!.map(\.nodeId))

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
    let original: [ExtendedRecord] = _original!.map { record in
      !currentIds.contains(record.nodeId)
        ? ExtendedRecord(.deleted, record)
        : dirtyIds.contains(record.nodeId)
          ? ExtendedRecord(.dirty, record)
          : ExtendedRecord(.none, record)
    }

    var i = current.count - 1
    var j = original.count - 1

    /*  Process insert newline for the same node */
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

    // invariant:
    //  [cursor, ...) is consistent with (i, ...)
    //  [0, cursor) is consistent with [0, j]
    while true {
      if i < 0 && j < 0 { break }

      // process added and deleted
      // (It doesn't matter whether to process add or delete first.)
      while i >= 0 && current[i].mark == .added {
        if current[i].insertNewline { context.insertNewline(self) }
        _children[i].performLayout(context, fromScratch: true)
        i -= 1
      }
      assert(i < 0 || Meta.matches(current[i].mark, .none, .dirty))

      while j >= 0 && original[j].mark == .deleted {
        if original[j].insertNewline { context.deleteBackwards(1) }
        context.deleteBackwards(original[j].layoutLength)
        j -= 1
      }
      assert(j < 0 || Meta.matches(original[j].mark, .none, .dirty))

      // skip none
      while i >= 0 && current[i].mark == .none {
        assert(j >= 0 && original[j].mark == .none)
        assert(current[i].nodeId == original[j].nodeId)
        processInsertNewline(original[j], current[i])
        context.skipBackwards(current[i].layoutLength)
        i -= 1
        j -= 1
      }
      assert(i < 0 || Meta.matches(current[i].mark, .added, .dirty))
      assert(j < 0 || Meta.matches(original[j].mark, .deleted, .dirty))

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
  }

  private final func _performLayoutFromScratch(_ context: LayoutContext) {
    precondition(_children.count == _newlines.count)

    zip(_children, _newlines.asBitArray)
      .reversed()
      .forEach { (node, insertNewline) in
        if insertNewline { context.insertNewline(self) }
        node.performLayout(context, fromScratch: true)
      }
  }

  override final func performLayout(_ context: LayoutContext, fromScratch: Bool) {
    if fromScratch {
      _performLayoutFromScratch(context)
    }
    else if _original == nil {
      _performLayoutSimple(context)
    }
    else {
      _performLayoutFull(context)
    }

    // clear
    _isDirty = false
    _original = nil
  }

  override final func getLayoutOffset(_ index: RohanIndex) -> Int? {
    guard let index = index.index() else { return nil }
    return getLayoutOffset(index)
  }

  final func getLayoutOffset(_ index: Int) -> Int? {
    guard index <= childCount else { return nil }
    let range = 0..<index
    let s1 = _children[range].lazy.map(\.layoutLength).reduce(0, +)
    let s2 = _newlines.asBitArray[range].lazy.map(\.intValue).reduce(0, +)
    return s1 + s2
  }

  override final func getRohanIndex(_ layoutOffset: Int) -> (RohanIndex, consumed: Int)? {
    guard let (i, consumed) = getChildIndex(layoutOffset) else { return nil }
    return (.index(i), consumed)
  }

  /** Returns the index of the child containing `[layoutOffset, _ + 1)` together
   with the value of ``getLayoutOffset(_:)`` over that index.
   - Invariant: If return value is non-nil, then access child/character with the
   returned index must succeed.
   */
  final func getChildIndex(_ layoutOffset: Int) -> (Int, layoutOffset: Int)? {
    guard 0..<layoutLength ~= layoutOffset else { return nil }
    var i = 0
    var s = 0
    // invariant:
    //  s(i) = sum { children[j].layoutLength | j in [0, i) }
    // result:
    //  i st. layoutOffset ∈ [s(i), _ + children[i].layoutLength)
    while i < _children.count {
      let n = s + _children[i].layoutLength + _newlines[i].intValue
      if s..<n ~= layoutOffset {
        return (i, s)
      }
      i += 1
      s = n
    }
    assertionFailure("Impossible to reach here")
    return nil
  }

  override func enumerateTextSegments(
    _ context: any LayoutContext,
    _ path: ArraySlice<RohanIndex>, _ endPath: ArraySlice<RohanIndex>,
    layoutOffset: Int, originCorrection: CGPoint,
    type: DocumentManager.SegmentType, options: DocumentManager.SegmentOptions,
    using block: (RhTextRange?, CGRect, CGFloat) -> Bool
  ) -> Bool {
    guard let index = path.first?.index(),
      let endIndex = endPath.first?.index()
    else { return false }
    // create new block
    func newBlock(_ range: Range<Int>?, _ segmentFrame: CGRect, _ baselinePosition: CGFloat) -> Bool
    {
      let segmentFrame = segmentFrame.offsetBy(dx: originCorrection.x, dy: originCorrection.y)
      return block(nil, segmentFrame, baselinePosition)
    }
    // compute tail offset
    func computeTailOffset(_ tail: ArraySlice<RohanIndex>) -> Int? {
      precondition(!tail.isEmpty)
      var s = 0
      var node: Node = self
      for index in tail.dropLast() {
        guard let n = node.getLayoutOffset(index),
          let child = node.getChild(index)
        else { return nil }
        s += n
        node = child
      }
      guard let n = node.getLayoutOffset(tail.last!) else { return nil }
      s += n
      return s
    }

    if path.count == 1 || endPath.count == 1 || index != endIndex {
      guard let first = computeTailOffset(path),
        let last = computeTailOffset(endPath)
      else { return false }
      let layoutRange = layoutOffset + first..<layoutOffset + last
      return context.enumerateTextSegments(
        layoutRange, type: type, options: options, using: newBlock(_:_:_:))
    }
    // ASSERT: path.count > 1 && endPath.count > 1 && index == endIndex
    else {  // if paths don't branch, recurse
      guard index < self.childCount,
        let first = getLayoutOffset(index)
      else { return false }
      return _children[index].enumerateTextSegments(
        context, path.dropFirst(), endPath.dropFirst(),
        layoutOffset: layoutOffset + first, originCorrection: originCorrection,
        type: type, options: options, using: block)
    }
  }

  /**
   Resolve text location with given point.
   - Returns: true if trace is modified.
   */
  override final func resolveTextLocation(
    interactingAt point: CGPoint, _ context: any LayoutContext, _ trace: inout [TraceElement]
  ) -> Bool {
    guard let (contextRange, fraction) = context.getLayoutRange(interactingAt: point)
    else { return false }
    let layoutRange = LayoutRange(contextRange, contextRange, fraction)
    return resolveTextLocation(interactingAt: point, context, &trace, layoutRange)
  }

  /**
   Resolve the text location at the given point and (layoutRange, fraction) pair.

   - Returns: true if trace is modified.
   - Note: For TextLayoutContext, the point is relative to the __top-left corner__ of
   the container. For MathLayoutContext, the point is relative to the __top-left corner__
   of the math list.
   */
  final func resolveTextLocation(
    interactingAt point: CGPoint, _ context: any LayoutContext, _ trace: inout [TraceElement],
    _ layoutRange: LayoutRange
  ) -> Bool {
    // local alias for convenience
    let localRange = layoutRange.localRange

    if localRange.isEmpty {
      let localOffset = localRange.lowerBound

      // layout range is empty, we should stop early
      if localOffset >= self.layoutLength {
        trace.append(TraceElement(self, .index(self.childCount)))
        return true
      }
      else {
        guard let (tail, consumed) = NodeUtils.traceNodes(localOffset, self),
          let last = tail.last
        else { return false }
        trace.append(contentsOf: tail)

        // recurse if we are at an apply node
        guard !(last.node is TextNode),  // stop if last node is TextNode
          let child = last.getChild(),
          let applyNode = child as? ApplyNode
        else { return true }

        // The content of ApplyNode is treated as being expanded in-place.
        // So keep the original point.
        let newLocalOffset = localOffset - consumed
        _ = applyNode.resolveTextLocation(
          interactingAt: point, context, &trace,
          layoutRange.with(localRange: newLocalOffset..<newLocalOffset))
        return true
      }
    }
    else {
      // trace nodes that contain [layoutOffset, _ + 1)
      guard let (tail, consumed) = NodeUtils.traceNodes(localRange.lowerBound, self),
        let last = tail.last  // trace is non-empty
      else { return false }

      func fixLastIndex() {
        precondition(last.index.index() != nil)
        let index = last.index.index()! + (layoutRange.fraction > 0.5 ? localRange.count : 0)
        trace[trace.count - 1] = last.with(index: .index(index))
      }
      func fixLastIndex(for applyNode: ApplyNode, _ localRange: Range<Int>) {
        precondition(last.index.index() != nil)
        let newFraction = {
          let location =
            Double(localRange.lowerBound) + Double(localRange.count) * layoutRange.fraction
          return location / Double(applyNode.layoutLength)
        }()
        let index = last.index.index()! + (newFraction > 0.5 ? 1 : 0)
        trace[trace.count - 1] = last.with(index: .index(index))
      }

      // append to trace
      trace.append(contentsOf: tail)

      guard !(last.node is TextNode),  // stop if last node is TextNode
        let child = last.node.getChild(last.index)
        // ASSERT: child.isPivotal
      else { fixLastIndex(); return true }

      switch child {
      case _ as MathNode:
        // MathNode uses coordinate relative to glyph origin to resolve text location
        let contextOffset = layoutRange.contextRange.lowerBound
        guard let segmentFrame = context.getSegmentFrame(for: contextOffset)
        else { fixLastIndex(); return true }
        let newPoint = point.relative(to: segmentFrame.frame.origin)
          // The origin of the segment frame may be incorrect for MathNode due to
          // the discrepancy between TextKit and our math layout system.
          // We obtain the coorindate relative to glyph origin by subtracting the
          // baseline position which is aligned across the two systems.
          .with(yDelta: -segmentFrame.baselinePosition)
        // recurse and fix on need
        let modified = child.resolveTextLocation(interactingAt: newPoint, context, &trace)
        if !modified { fixLastIndex() }
        return true
      case _ as ElementNode:
        // ElementNode uses coordinate relative to top-left corner to resolve text location
        let contextOffset = layoutRange.contextRange.lowerBound
        guard let segmentFrame = context.getSegmentFrame(for: contextOffset)
        else { fixLastIndex(); return true }
        let newPoint = point.relative(to: segmentFrame.frame.origin)
        // recurse and fix on need
        let modified = child.resolveTextLocation(interactingAt: newPoint, context, &trace)
        if !modified { fixLastIndex() }
        return true
      case let applyNode as ApplyNode:
        // The content of ApplyNode is treated as being expanded in-place.
        // So keep the original point.
        let newLocalRange = localRange.lowerBound - consumed..<localRange.upperBound - consumed
        let modified = applyNode.resolveTextLocation(
          interactingAt: point, context, &trace, layoutRange.with(localRange: newLocalRange))
        if !modified { fixLastIndex(for: applyNode, newLocalRange) }
        return true
      default:
        // UNEXPECTED for current node types. May change in the future.
        Rohan.logger.error("unexpected node type: \(type(of: child))")
        // fallback and return
        fixLastIndex()
        return true
      }
    }
  }

  // MARK: - Children

  public final var childCount: Int { _children.count }

  public final func getChild(_ index: Int) -> Node { _children[index] }

  public final func takeChildren(inContentStorage: Bool = false) -> [Node] {
    // pre update
    if inContentStorage { _makeSnapshotOnce() }

    var delta = LengthSummary.zero
    _children.forEach {
      $0.parent = nil
      delta -= $0.lengthSummary
    }

    // perform remove
    let children = exchange(&_children, with: [])

    // update newlines
    var newlinesDelta = -_newlines.trueValueCount
    _newlines.removeAll()
    newlinesDelta += _newlines.trueValueCount

    // post update
    contentDidChangeLocally(
      delta: delta, newlinesDelta: newlinesDelta, inContentStorage: inContentStorage)

    return Array(children)
  }

  public final func insertChild(
    _ node: Node, at index: Int, inContentStorage: Bool = false
  ) {
    insertChildren(contentsOf: CollectionOfOne(node), at: index, inContentStorage: inContentStorage)
  }

  public final func insertChildren<S>(
    contentsOf nodes: S, at index: Int, inContentStorage: Bool = false
  ) where S: Collection, S.Element == Node {
    guard !nodes.isEmpty else { return }

    // pre update
    if inContentStorage { _makeSnapshotOnce() }

    let delta = nodes.lazy.map(\.lengthSummary).reduce(.zero, +)

    // perform insert
    _children.insert(contentsOf: nodes, at: index)

    // update newlines
    var newlinesDelta = -_newlines.trueValueCount
    _newlines.insert(contentsOf: nodes.lazy.map(\.isBlock), at: index)
    newlinesDelta += _newlines.trueValueCount

    // post update
    nodes.forEach {
      assert($0.parent == nil)
      $0.parent = self
    }

    contentDidChangeLocally(
      delta: delta, newlinesDelta: newlinesDelta, inContentStorage: inContentStorage)
  }

  public final func removeChild(at index: Int, inContentStorage: Bool = false) {
    removeSubrange(index..<index + 1, inContentStorage: inContentStorage)
  }

  public final func removeSubrange(_ range: Range<Int>, inContentStorage: Bool = false) {
    // pre update
    if inContentStorage { _makeSnapshotOnce() }

    var delta = LengthSummary.zero
    _children[range].forEach {
      $0.parent = nil
      delta -= $0.lengthSummary
    }

    // perform remove
    _children.removeSubrange(range)

    // update newlines
    var newlinesDelta = -_newlines.trueValueCount
    _newlines.removeSubrange(range)
    newlinesDelta += _newlines.trueValueCount

    // post update
    contentDidChangeLocally(
      delta: delta, newlinesDelta: newlinesDelta, inContentStorage: inContentStorage)
  }

  internal final func replaceChild(
    _ node: Node, at index: Int, inContentStorage: Bool = false
  ) {
    precondition(_children[index] !== node && node.parent == nil)
    // pre update
    if inContentStorage { _makeSnapshotOnce() }

    // compute delta
    let delta = node.lengthSummary - _children[index].lengthSummary
    // perform replace
    _children[index].parent = nil
    _children[index] = node
    node.parent = self

    // update newlines
    var newlinesDelta = -_newlines.trueValueCount
    _newlines.setValue(isBlock: node.isBlock, at: index)
    newlinesDelta += _newlines.trueValueCount

    // post update
    contentDidChangeLocally(
      delta: delta, newlinesDelta: newlinesDelta, inContentStorage: inContentStorage)
  }

  /**
   Compact mergeable nodes in a range
   - Returns: true if compacted
   */
  internal final func compactSubrange(
    _ range: Range<Int>, inContentStorage: Bool = false
  ) -> Bool {
    guard range.count > 1 else { return false }

    // pre update
    if inContentStorage { _makeSnapshotOnce() }

    // perform compact
    guard let newRange = ElementNode.compactSubrange(&_children, range, self)
    else { return false }
    assert(range.lowerBound == newRange.lowerBound)

    // update newlines
    var newlinesDelta = -_newlines.trueValueCount
    _newlines.replaceSubrange(range, with: _children[newRange].lazy.map(\.isBlock))
    newlinesDelta += _newlines.trueValueCount
    assert(newlinesDelta == 0)

    // post update

    // compact doesn't affect _layout length_, so delta = 0.
    // Theorectically newlinesDelta = 0, but it doesn't harm to update it.
    contentDidChangeLocally(
      delta: .zero, newlinesDelta: newlinesDelta, inContentStorage: inContentStorage)

    return true
  }

  /**
   Compact nodes in a range so that there are no neighbouring mergeable nodes.
   - Note: Each merged node is set with `parent`.
   - Returns: the new range
   */
  private static func compactSubrange(
    _ nodes: inout BackStore, _ range: Range<Int>, _ parent: Node?
  ) -> Range<Int>? {
    precondition(range.lowerBound >= 0 && range.upperBound <= nodes.count)

    func isCandidate(_ i: Int) -> Bool { nodes[i].nodeType == .text }

    func isMergeable(_ i: Int, _ j: Int) -> Bool {
      nodes[i].nodeType == .text && nodes[j].nodeType == .text
    }

    func mergeSubrange(_ range: Range<Int>) -> Node {
      let string: BigString = nodes[range]
        .lazy.map { ($0 as! TextNode).bigString }
        .reduce(into: BigString(), +=)
      let node = TextNode(string)
      node.parent = parent
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

private struct SnapshotRecord {
  let nodeId: NodeIdentifier
  let insertNewline: Bool
  let layoutLength: Int

  init(_ node: Node, _ insertNewline: Bool) {
    self.nodeId = node.id
    self.insertNewline = insertNewline
    self.layoutLength = node.layoutLength
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

  init(_ node: Node, _ insertNewline: Bool) {
    self.mark = node.isDirty ? .dirty : .none
    self.nodeId = node.id
    self.insertNewline = insertNewline
    self.layoutLength = node.layoutLength
  }

  init(_ mark: LayoutMark, _ node: Node, _ insertNewline: Bool) {
    self.mark = mark
    self.nodeId = node.id
    self.insertNewline = insertNewline
    self.layoutLength = node.layoutLength
  }
}
