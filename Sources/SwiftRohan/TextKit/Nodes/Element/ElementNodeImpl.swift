// Copyright 2024-2025 Lie Yan

/// ElementNode subclass that provides default layout implementation.
internal class ElementNodeImpl: ElementNode {
  // MARK: - Node(Positioning)

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

  final override func performLayout(_ context: LayoutContext, fromScratch: Bool) -> Int {
    if isBlockContainer {
      return _performLayout(context, fromScratch: fromScratch, isBlockContainer: true)
    }
    else {
      return _performLayout(context, fromScratch: fromScratch, isBlockContainer: false)
    }
  }

  // MARK: - Layout Impl.

  private final var _snapshotRecords: Array<SnapshotRecord>? = nil

  final override func snapshotDescription() -> Array<String>? {
    if let snapshotRecords = _snapshotRecords {
      return snapshotRecords.map(\.description)
    }
    return nil
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
      _snapshotRecords =
        zip(_children, _newlines.asBitArray).map { SnapshotRecord($0, $1) }
    }
  }

  @inline(__always)
  private final func _performLayout(
    _ context: LayoutContext, fromScratch: Bool, isBlockContainer: Bool
  ) -> Int {
    if fromScratch {
      _layoutLength =
        _performLayoutFromScratch(context, isBlockContainer: isBlockContainer)
      _snapshotRecords = nil
    }
    else if _snapshotRecords == nil {
      _layoutLength = _performLayoutSimple(context, isBlockContainer: isBlockContainer)
    }
    else {
      _layoutLength = _performLayoutFull(context, isBlockContainer: isBlockContainer)
      _snapshotRecords = nil
    }
    _isDirty = false
    return _layoutLength
  }

  /// Perform layout for fromScratch=true.
  @inline(__always)
  private final func _performLayoutFromScratch(
    _ context: LayoutContext, isBlockContainer: Bool
  ) -> Int {
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

    // insert content backwards
    for i in (0..<_children.count).reversed() {
      sum += NewlineReconciler.insert(new: _newlines[i], context: context, self)
      sum += NodeReconciler.insert(new: _children[i], context: context)
    }

    if isBlockContainer {
      _refreshParagraphStyle(context, { _ in true })
    }

    return sum
  }

  /// Perform layout for fromScratch=false when snapshot was not made.
  @inline(__always)
  private final func _performLayoutSimple(
    _ context: LayoutContext, isBlockContainer: Bool
  ) -> Int {
    precondition(_snapshotRecords == nil && _children.count == _newlines.count)

    assert(_children.isEmpty == false)

    var sum = 0
    var forceParagraphStyle = false
    for i in (0..<_children.count).reversed() {
      // skip clean.
      if _children[i].isDirty == false {
        let sum0 = sum
        sum += NewlineReconciler.skip(currrent: _newlines[i], context: context)
        sum += NodeReconciler.skip(current: _children[i], context: context)
        if isBlockContainer && forceParagraphStyle {
          let begin = context.layoutCursor
          let n = sum - sum0
          context.addParagraphStyle(_children[i], begin..<begin + n)
          forceParagraphStyle = false
        }
      }
      // process dirty.
      else {
        let sum0 = sum
        sum += NewlineReconciler.skip(currrent: _newlines[i], context: context)
        sum += NodeReconciler.reconcile(dirty: _children[i], context: context)
        // update paragraph style if needed
        if isBlockContainer {
          let begin = context.layoutCursor
          let n = sum - sum0
          context.addParagraphStyle(_children[i], begin..<begin + n)
          forceParagraphStyle = true
        }
      }
    }

    return sum
  }

  @inline(__always)
  private final func _computeExtendedRecords() -> (
    current: Array<ExtendedRecord>, original: Array<ExtendedRecord>
  ) {
    // ID's of current children
    let currentIds = Set(_children.map(\.id))
    // ID's of the dirty part of current children
    let dirtyIds = Set(_children.lazy.filter(\.isDirty).map(\.id))
    // ID's of original children
    let originalIds = Set(_snapshotRecords!.map(\.nodeId))

    let current =
      zip(_children, _newlines.asBitArray).map { (node, insertNewline) in
        let mark: LayoutMark =
          !originalIds.contains(node.id)
          ? .added
          : (node.isDirty ? .dirty : .none)
        return ExtendedRecord(mark, node, insertNewline)
      }

    let original =
      _snapshotRecords!.map { record in
        !currentIds.contains(record.nodeId)
          ? ExtendedRecord(.deleted, record)
          : dirtyIds.contains(record.nodeId)
            ? ExtendedRecord(.dirty, record)
            : ExtendedRecord(.none, record)
      }
    return (current, original)
  }

  /// Perform layout for fromScratch=false when snapshot has been made.
  @inline(__always)
  private final func _performLayoutFull(
    _ context: LayoutContext, isBlockContainer: Bool
  ) -> Int {
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

    let (current, original) = _computeExtendedRecords()

    var sum = 0
    var i = current.count - 1
    var j = original.count - 1

    // current range that covers deleted nodes which should be vacuumed
    var vacuumRange: Range<Int>?

    func updateVacuumRange() {
      precondition(isBlockContainer)

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
        if isBlockContainer { updateVacuumRange() }

        while j >= 0 && original[j].mark == .deleted {
          NewlineReconciler.delete(old: original[j].insertNewline, context: context)
          NodeReconciler.delete(old: original[j].layoutLength, context: context)
          j -= 1
        }
        assert(j < 0 || [.none, .dirty].contains(original[j].mark))
      }

      while i >= 0 && current[i].mark == .added {
        let newline = current[i].insertNewline
        sum += NewlineReconciler.insert(new: newline, context: context, self)
        sum += NodeReconciler.insert(new: _children[i], context: context)
        i -= 1
      }
      assert(i < 0 || [.none, .dirty].contains(current[i].mark))

      // skip none
      while i >= 0 && current[i].mark == .none,
        j >= 0 && original[j].mark == .none
      {
        assert(current[i].nodeId == original[j].nodeId)

        let newlines = (original[j].insertNewline, current[i].insertNewline)
        sum += NewlineReconciler.reconcile(dirty: newlines, context: context, self)
        sum += NodeReconciler.skip(current: current[i].layoutLength, context: context)

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

        let newlines = (original[j].insertNewline, current[i].insertNewline)
        sum += NewlineReconciler.reconcile(dirty: newlines, context: context, self)
        sum += NodeReconciler.reconcile(dirty: _children[i], context: context)
        i -= 1
        j -= 1
      }
    }

    // add paragraph style forwards
    if isBlockContainer {
      let vacuumRange = vacuumRange ?? 0..<0
      _refreshParagraphStyle(
        context,
        { i in
          current[i].mark == .added || current[i].mark == .dirty
            || vacuumRange.contains(i)
        })
    }

    return sum
  }

  /// Refresh paragraph style for those children that match the predicate and are not
  /// themselves paragraph containers.
  ///
  /// If `self` is **not** a paragraph container, this method does nothing.
  ///
  /// - Precondition: layout cursor is at the start of the node.
  /// - Postcondition: the cursor is unchanged.
  @inline(__always)
  private final func _refreshParagraphStyle(
    _ context: LayoutContext, _ predicate: (Int) -> Bool
  ) {
    precondition(self.isBlockContainer)

    var location = context.layoutCursor
    for i in 0..<_children.count {
      let child = _children[i]
      let end = location + child.layoutLength() + _newlines[i].intValue
      // paragraph containers are styled by themselves, so we skip them.
      if child.isBlockContainer == false && predicate(i) {
        context.addParagraphStyle(child, location..<end)
      }
      location = end
    }
  }

  final override func getLayoutOffset(_ index: Int) -> Int? {
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

  // MARK: - Facilities for Layout

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

  internal struct ExtendedRecord {
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
  }
}
