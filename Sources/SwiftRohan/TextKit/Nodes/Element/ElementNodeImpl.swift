// Copyright 2024-2025 Lie Yan

/// ElementNode subclass that provides default layout implementation.
internal class ElementNodeImpl: ElementNode {
  // MARK: - Node(Positioning)

  // Override `getLayoutOffset(_ index: Int)` instead of this method.
  final override func getLayoutOffset(_ index: RohanIndex) -> Int? {
    guard let index = index.index() else { return nil }
    return getLayoutOffset(index)
  }

  internal override func getPosition(_ layoutOffset: Int) -> PositionResult<RohanIndex> {
    guard 0..._layoutLength ~= layoutOffset else {
      return .failure(SatzError(.InvalidLayoutOffset))
    }
    guard !_children.isEmpty else {
      return .terminal(value: .index(0), target: 0)
    }

    let s0 = _newlines.value(before: 0, atBlockEdge: _atBlockEdge).intValue
    guard s0 <= layoutOffset else {
      return .terminal(value: .index(0), target: s0)
    }

    assert(isPlaceholderActive == false)

    var (k, s) = (0, s0)
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

  /// True if the **previous** layout of the node was performed at a block edge,
  /// that is, immediately after a newline is emitted.
  private final var _atBlockEdge: Bool = true

  internal override func performLayout(
    _ context: any LayoutContext, fromScratch: Bool, atBlockEdge: Bool
  ) -> Int {
    // Maintenance: (a) save `_atBlockEdge`; (b) clear `_snapshotRecords` and `_isDirty`;
    // (c) compute `_layoutLength`.

    if fromScratch {
      _layoutLength = _performLayoutFromScratch(context, atBlockEdge: atBlockEdge)
      _snapshotRecords = nil
    }
    else if _snapshotRecords == nil {
      _layoutLength = _performLayoutSimple(context, atBlockEdge: atBlockEdge)
    }
    else {
      _layoutLength = _performLayoutFull(context, atBlockEdge: atBlockEdge)
      _snapshotRecords = nil
    }

    _atBlockEdge = atBlockEdge
    _isDirty = false
    return _layoutLength
  }

  // MARK: - ElementNode

  internal override func getLayoutOffset(_ index: Int) -> Int? {
    guard index <= childCount else { return nil }
    guard !_children.isEmpty else { return 0 }  // "0" whether placeholder is active or not.

    assert(isPlaceholderActive == false)
    let range = 0..<index
    let s0 = _newlines.value(before: 0, atBlockEdge: _atBlockEdge).intValue
    let s1 = _children[range].lazy.map { $0.layoutLength() }.reduce(0, +)
    let s2 = _newlines.asBitArray[range].lazy.map(\.intValue).reduce(0, +)
    return s0 + s1 + s2
  }

  // MARK: - Impl(Layout)

  private final var _snapshotRecords: Array<SnapshotRecord>? = nil

  final override func snapshotDescription() -> Array<String>? {
    _snapshotRecords.map { $0.map(\.description) }
  }

  /// Make snapshot once if not already made
  /// - Invariant: Call to method `performLayout(_:fromScratch:)` will clear the snapshot.
  final override func makeSnapshotOnce() {
    guard _snapshotRecords == nil else { return }
    assert(_children.count == _newlines.count)

    if isPlaceholderActive {
      _snapshotRecords = [SnapshotRecord.placeholder(1)]
    }
    else {
      _snapshotRecords = _children.indices.map { i in
        SnapshotRecord(
          _children[i], _newlines[i],
          leadingNewline: _newlines.value(before: i, atBlockEdge: _atBlockEdge))
      }
    }
  }

  /// Layout empty node from scratch.
  @inline(__always)
  private final func _performLayoutEmpty(
    _ context: LayoutContext, atBlockEdge: Bool
  ) -> Int {
    precondition(_children.isEmpty && _newlines.isEmpty)
    if self.isPlaceholderActive {
      let placeholder = String(NodePolicy.placeholder(for: self.type).char)
      let sum = StringReconciler.insertForward(new: placeholder, context: context, self)
      if self.layoutType.mayEmitBlock {
        context.addParagraphStyleBackward(sum, self)
      }
      return sum
    }
    else {
      return 0
    }
  }

  /// Perform layout from scratch.
  @inline(__always)
  private final func _performLayoutFromScratch(
    _ context: LayoutContext, atBlockEdge: Bool
  ) -> Int {
    precondition(_children.count == _newlines.count)

    if _children.isEmpty {
      return _performLayoutEmpty(context, atBlockEdge: atBlockEdge)
    }

    assert(_children.isEmpty == false)

    let mayEmitBlock = self.layoutType.mayEmitBlock

    var sum = 0
    var segmentLength = 0
    var isCandidate = false

    /*
     Invariant:
     (a) segmentLength maintains accumulated length since entry or previous newline.
     (b) isCandidate is true if the segment is candidate for paragraph style.
     (c) sum maintains the total length inserted so far.
     (d) every segment (separated by leading newlines) is applied with paragraph
         style when downstream edge is reached with the exception of (e).
     (e) block child nodes are skipped for paragraph style.
     */
    for i in _children.indices {
      let leadingNewline = _newlines.value(before: i, atBlockEdge: atBlockEdge)
      let runningBlockEdge = i == 0 ? (leadingNewline || atBlockEdge) : leadingNewline

      // apply paragraph style when segment edge is reached.
      if mayEmitBlock, leadingNewline, isCandidate && segmentLength > 0 {
        context.addParagraphStyleBackward(segmentLength, self)
        // reset
        segmentLength = 0
        isCandidate = false
      }

      // insert newline and child content.
      let nl =
        NewlineReconciler.insertForward(new: leadingNewline, context: context, self)
      let nc = NodeReconciler.insertForward(
        new: _children[i], context: context, atBlockEdge: runningBlockEdge)
      sum += nl + nc

      // update segment length and dirty flag.
      if _children[i].layoutType == .block {
        segmentLength = 0
        isCandidate = false
      }
      else {
        segmentLength += nc
        isCandidate = true
      }
    }
    if mayEmitBlock, isCandidate && segmentLength > 0 {
      context.addParagraphStyleBackward(segmentLength, self)
    }
    sum += NewlineReconciler.insertForward(new: _newlines.last!, context: context, self)
    return sum
  }

  /// Perform layout incrementally when snapshot was not made.
  @inline(__always)
  private final func _performLayoutSimple(
    _ context: LayoutContext, atBlockEdge: Bool
  ) -> Int {
    precondition(_snapshotRecords == nil && _children.count == _newlines.count)

    if _children.isEmpty {
      if self.isPlaceholderActive {
        let placeholder = String(NodePolicy.placeholder(for: self.type).char)
        return StringReconciler.skipForward(current: placeholder, context: context)
      }
      else {
        return 0
      }
    }

    assert(_children.isEmpty == false)

    let mayEmitBlock = self.layoutType.mayEmitBlock

    var sum = 0
    var segmentLength = 0
    var isCandidate = false

    /*
     Invariant:
     (a) segmentLength maintains accumulated length since entry or previous newline.
     (b) isCandidate is true if the segment is candidate for paragraph style.
     (c) sum maintains the total length inserted so far.
     (d) every segment (separated by leading newlines) is applied with paragraph
     style when downstream edge is reached with the exception of (e).
     (e) block child nodes are skipped for paragraph style.
     */

    for i in _children.indices {
      let leadingNewline = _newlines.value(before: i, atBlockEdge: atBlockEdge)
      let runningBlockEdge = i == 0 ? (leadingNewline || atBlockEdge) : leadingNewline

      // apply paragraph style when segment edge is reached.
      if mayEmitBlock, leadingNewline, isCandidate && segmentLength > 0 {
        context.addParagraphStyleBackward(segmentLength, self)
        // reset
        segmentLength = 0
        isCandidate = false
      }

      // process newline and child content.
      let childWasDirty = _children[i].isDirty
      let nl = NewlineReconciler.skipForward(current: leadingNewline, context: context)
      let nc =
        _children[i].isDirty
        ? NodeReconciler.reconcileForward(
          dirty: _children[i], context: context, atBlockEdge: runningBlockEdge)
        : NodeReconciler.skipForward(current: _children[i], context: context)
      sum += nl + nc

      // update segment length and dirty flag.
      if _children[i].layoutType == .block {
        segmentLength = 0
        isCandidate = false
      }
      else {
        segmentLength += nc
        isCandidate = isCandidate || childWasDirty
      }
    }
    if mayEmitBlock, isCandidate && segmentLength > 0 {
      context.addParagraphStyleBackward(segmentLength, self)
    }
    sum += NewlineReconciler.skipForward(current: _newlines.last!, context: context)
    return sum
  }

  /// Perform layout incrementally when snapshot has been made.
  @inline(__always)
  private final func _performLayoutFull(
    _ context: LayoutContext, atBlockEdge: Bool
  ) -> Int {
    precondition(_snapshotRecords != nil && _children.count == _newlines.count)

    if _children.isEmpty {
      context.deleteForward(_layoutLength)
      return _performLayoutEmpty(context, atBlockEdge: atBlockEdge)
    }

    assert(_children.isEmpty == false)

    let mayEmitBlock = self.layoutType.mayEmitBlock

    let (current, original) = _computeExtendedRecords(atBlockEdge: atBlockEdge)

    var sum = 0
    var segmentLength = 0
    var isCandidate = false
    var j = 0
    let originalCount = original.count

    /*
     Invariant:
     (a) segmentLength maintains accumulated length since entry or previous newline.
     (b) isCandidate is true if the segment is candidate for paragraph style.
     (c) sum maintains the total length inserted so far.
     (d) every segment (separated by leading newlines) is applied with paragraph
     style when downstream edge is reached with the exception of (e).
     (e) block child nodes are skipped for paragraph style.
     */
    for i in _children.indices {
      // process deleted in a batch if any.
      while j < originalCount && original[j].mark == .deleted {
        NewlineReconciler.deleteForward(
          old: original[j].leadingNewline, context: context)
        NodeReconciler.deleteForward(old: original[j].layoutLength, context: context)
        j += 1
      }

      let leadingNewline = _newlines.value(before: i, atBlockEdge: atBlockEdge)
      let runningBlockEdge = i == 0 ? (leadingNewline || atBlockEdge) : leadingNewline

      // apply paragraph style when segment edge is reached.
      if mayEmitBlock, leadingNewline, isCandidate && segmentLength > 0 {
        context.addParagraphStyleBackward(segmentLength, self)
        // reset
        segmentLength = 0
        isCandidate = false
      }

      let nc: Int
      let nl: Int

      // process added.
      if current[i].mark == .added {
        nl =
          NewlineReconciler.insertForward(new: leadingNewline, context: context, self)
        nc = NodeReconciler.insertForward(
          new: _children[i], context: context, atBlockEdge: runningBlockEdge)
        isCandidate = true
      }
      // skip none.
      else if current[i].mark == .none,
        j < originalCount && original[j].mark == .none
      {
        assert(current[i].nodeId == original[j].nodeId)
        let newlines = (original[j].leadingNewline, leadingNewline)
        nl = NewlineReconciler.reconcileForward(dirty: newlines, context: context, self)
        nc =
          NodeReconciler.skipForward(current: current[i].layoutLength, context: context)
        j += 1
      }
      // process dirty.
      else {
        assert(j < originalCount && current[i].nodeId == original[j].nodeId)
        assert(current[i].mark == .dirty && original[j].mark == .dirty)
        let newlines = (original[j].leadingNewline, leadingNewline)
        nl = NewlineReconciler.reconcileForward(dirty: newlines, context: context, self)
        nc = NodeReconciler.reconcileForward(
          dirty: _children[i], context: context, atBlockEdge: runningBlockEdge)
        isCandidate = true
        j += 1
      }
      sum += nc + nl

      // update segment length and dirty flag.
      if _children[i].layoutType == .block {
        segmentLength = 0
        isCandidate = false
      }
      else {
        segmentLength += nc
        // isCandidate is unchanged.
      }
    }
    // process deleted in a batch if any.
    while j < originalCount && original[j].mark == .deleted {
      NewlineReconciler.deleteForward(old: original[j].leadingNewline, context: context)
      NodeReconciler.deleteForward(old: original[j].layoutLength, context: context)
      j += 1
    }
    assert(j == originalCount)
    if mayEmitBlock, isCandidate, segmentLength > 0 {
      context.addParagraphStyleBackward(segmentLength, self)
    }
    do {
      let old = original.last?.trailingNewline ?? false
      let new = _newlines.last!
      let n = NewlineReconciler.reconcileForward(
        dirty: (old, new), context: context, self)
      sum += n
    }
    return sum
  }

  /// - Parameters:
  ///   - atBlockEdge: Current value of passed-in `atBlockEdge` parameter.
  private final func _computeExtendedRecords(
    atBlockEdge: Bool
  ) -> (current: Array<ExtendedRecord>, original: Array<ExtendedRecord>) {
    precondition(_snapshotRecords != nil)
    return ElementNodeImpl.computeExtendedRecords(
      _children, _newlines, atBlockEdge: atBlockEdge, _snapshotRecords!)
  }

  /// Compute the current and original records for layout.
  /// - Parameters:
  ///   - children: The current children of the element node.
  ///   - newlines: The newlines associated with the children.
  ///   - atBlockEdge: Whether the layout of the node starts at a block start.
  @inline(__always)
  static func computeExtendedRecords(
    _ children: ElementStore, _ newlines: NewlineArray, atBlockEdge: Bool,
    _ snapshotRecords: Array<SnapshotRecord>
  ) -> (current: Array<ExtendedRecord>, original: Array<ExtendedRecord>) {
    // ID's of current children
    let currentIds = Set(children.map(\.id))
    // ID's of the dirty part of current children
    let dirtyIds = Set(children.lazy.filter(\.isDirty).map(\.id))
    // ID's of original children
    let originalIds = Set(snapshotRecords.map(\.nodeId))

    let current =
      children.indices.map { i in
        let node = children[i]
        let insertNewline = newlines[i]
        let newlineBefore = newlines.value(before: i, atBlockEdge: atBlockEdge)
        let mark: LayoutMark =
          !originalIds.contains(node.id)
          ? .added
          : (node.isDirty ? .dirty : .none)
        return ExtendedRecord(mark, node, insertNewline, leadingNewline: newlineBefore)
      }

    let original =
      snapshotRecords.map { record in
        !currentIds.contains(record.nodeId)
          ? ExtendedRecord(.deleted, record)
          : dirtyIds.contains(record.nodeId)
            ? ExtendedRecord(.dirty, record)
            : ExtendedRecord(.none, record)
      }
    return (current, original)
  }

  // MARK: - Facilities for Layout

  internal struct SnapshotRecord: CustomStringConvertible {
    let nodeId: NodeIdentifier
    let trailingNewline: Bool
    let leadingNewline: Bool
    let layoutLength: Int

    init(_ node: Node, _ trailingNewline: Bool, leadingNewline: Bool) {
      self.nodeId = node.id
      self.trailingNewline = trailingNewline
      self.leadingNewline = leadingNewline
      self.layoutLength = node.layoutLength()
    }

    private init(
      _ nodeId: NodeIdentifier,
      _ trailingNewline: Bool,
      leadingNewline: Bool,
      _ layoutLength: Int
    ) {
      self.nodeId = nodeId
      self.trailingNewline = trailingNewline
      self.leadingNewline = leadingNewline
      self.layoutLength = layoutLength
    }

    /// Create a placeholder record with given layout length.
    static func placeholder(_ layoutLength: Int) -> SnapshotRecord {
      SnapshotRecord(
        NodeIdAllocator.allocate(), false, leadingNewline: false, layoutLength)
    }

    var description: String {
      "(\(nodeId),\(layoutLength)+\(trailingNewline.intValue))"
    }
  }

  internal struct ExtendedRecord {
    let mark: LayoutMark
    let nodeId: NodeIdentifier
    let trailingNewline: Bool
    let leadingNewline: Bool
    let layoutLength: Int

    init(_ mark: LayoutMark, _ record: SnapshotRecord) {
      self.mark = mark
      self.nodeId = record.nodeId
      self.trailingNewline = record.trailingNewline
      self.leadingNewline = record.leadingNewline
      self.layoutLength = record.layoutLength
    }

    init(_ mark: LayoutMark, _ node: Node, _ trailingNewline: Bool, leadingNewline: Bool)
    {
      self.mark = mark
      self.nodeId = node.id
      self.trailingNewline = trailingNewline
      self.leadingNewline = leadingNewline
      self.layoutLength = node.layoutLength()
    }
  }
}
