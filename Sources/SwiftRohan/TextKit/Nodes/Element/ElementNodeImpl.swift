// Copyright 2024-2025 Lie Yan

/// ElementNode subclass that provides default layout implementation.
internal class ElementNodeImpl: ElementNode {
  // MARK: - Node(Positioning)

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
    _performLayout(context, fromScratch: fromScratch)
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
  private final func _performLayout(_ context: LayoutContext, fromScratch: Bool) -> Int {
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

  @inline(__always)
  private final func _performLayoutEmpty(_ context: LayoutContext) -> Int {
    precondition(_children.isEmpty && _newlines.isEmpty)
    switch self.isBlock {
    case true:
      if self.isPlaceholderActive {
        let sum = StringReconciler.insert(new: "⬚", context: context, self)
        context.addParagraphStyle(forSegment: sum, self)
        return sum
      }
      else {
        let sum = 0
        context.addParagraphStyle(forSegment: sum, self)
        return sum
      }
    case false:
      if self.isPlaceholderActive {
        return StringReconciler.insert(new: "⬚", context: context, self)
      }
      else {
        return 0
      }
    }
  }

  /// Perform layout from scratch.
  @inline(__always)
  private final func _performLayoutFromScratch(_ context: LayoutContext) -> Int {
    precondition(_children.count == _newlines.count)

    switch (_children.isEmpty, self.isBlock) {
    case (true, _):
      return _performLayoutEmpty(context)

    case (false, true):
      var sum = 0
      var segment = 0  // accumulated segment length since entry or last newline.

      for i in _children.indices.reversed() {  // backwards insertion.
        if _newlines[i] && segment > 0 {
          context.addParagraphStyle(forSegment: segment, self)
          segment = 0
        }
        var n = NewlineReconciler.insert(new: _newlines[i], context: context, self)
        n += NodeReconciler.insert(new: _children[i], context: context)
        sum += n

        if _children[i].isBlock {
          segment = 0
        }
        else {
          segment += n
        }
      }
      if segment > 0 { context.addParagraphStyle(forSegment: segment, self) }
      return sum

    case (false, false):
      var sum = 0
      for i in _children.indices.reversed() {
        assert(_newlines[i] == false)  // inline nodes should not contain newlines.
        sum += NodeReconciler.insert(new: _children[i], context: context)
      }
      return sum
    }
  }

  /// Perform layout for fromScratch=false when snapshot was not made.
  @inline(__always)
  private final func _performLayoutSimple(_ context: LayoutContext) -> Int {
    precondition(_snapshotRecords == nil && _children.count == _newlines.count)
    precondition(_children.isEmpty == false)

    switch self.isBlock {
    case true:
      var sum = 0
      var segment = 0  // accumulated segment length since entry or last newline.
      var dirty = false  // true if the segment is dirty.

      // Invariant: for every maximum non-block segment which is dirty, add
      //  paragraph style is called.
      for i in _children.indices.reversed() {
        if _newlines[i] && segment > 0 && dirty {
          context.addParagraphStyle(forSegment: segment, self)
          segment = 0
          dirty = false
        }
        var n: Int = 0
        if _children[i].isDirty == false {
          n += NewlineReconciler.skip(currrent: _newlines[i], context: context)
          n += NodeReconciler.skip(current: _children[i], context: context)
        }
        else {
          n += NewlineReconciler.skip(currrent: _newlines[i], context: context)
          n += NodeReconciler.reconcile(dirty: _children[i], context: context)
          dirty = true
        }
        sum += n
        if _children[i].isBlock {
          segment = 0
          dirty = false  // block nodes take care of their own paragraph style.
        }
        else {
          segment += n
        }
      }
      if segment > 0 && dirty {
        context.addParagraphStyle(forSegment: segment, self)
      }
      return sum

    case false:
      var sum = 0
      for i in _children.indices.reversed() {
        assert(_newlines[i] == false)
        if _children[i].isDirty == false {
          sum += NodeReconciler.skip(current: _children[i], context: context)
        }
        else {
          sum += NodeReconciler.reconcile(dirty: _children[i], context: context)
        }
      }
      return sum
    }
  }

  /// Perform layout for fromScratch=false when snapshot has been made.
  @inline(__always)
  private final func _performLayoutFull(_ context: LayoutContext) -> Int {
    precondition(_snapshotRecords != nil && _children.count == _newlines.count)

    switch (_children.isEmpty, self.isBlock) {
    case (true, _):
      context.deleteBackwards(_layoutLength)
      return _performLayoutEmpty(context)

    case (false, true):
      let (current, original) = _computeExtendedRecords()

      var sum = 0
      var segment = 0  // accumulated segment length since entry or last newline.
      var dirty = false  // true if the segment is dirty.
      var j = original.count - 1

      for i in _children.indices.reversed() {
        // process deleted in a batch if any.
        while j >= 0 && original[j].mark == .deleted {
          NewlineReconciler.delete(old: original[j].insertNewline, context: context)
          NodeReconciler.delete(old: original[j].layoutLength, context: context)
          j -= 1
        }

        if _newlines[i] && segment > 0 && dirty {
          context.addParagraphStyle(forSegment: segment, self)
          segment = 0
          dirty = false
        }

        // process added.
        var n: Int = 0
        if current[i].mark == .added {
          let newline = current[i].insertNewline
          n += NewlineReconciler.insert(new: newline, context: context, self)
          n += NodeReconciler.insert(new: _children[i], context: context)
          dirty = true
        }
        // skip none.
        else if current[i].mark == .none,
          j >= 0 && original[j].mark == .none
        {
          assert(current[i].nodeId == original[j].nodeId)
          let newlines = (original[j].insertNewline, current[i].insertNewline)
          n += NewlineReconciler.reconcile(dirty: newlines, context: context, self)
          n += NodeReconciler.skip(current: current[i].layoutLength, context: context)
          j -= 1
        }
        // process dirty.
        else {
          assert(j >= 0 && current[i].nodeId == original[j].nodeId)
          assert(current[i].mark == .dirty && original[j].mark == .dirty)

          let newlines = (original[j].insertNewline, current[i].insertNewline)
          n += NewlineReconciler.reconcile(dirty: newlines, context: context, self)
          n += NodeReconciler.reconcile(dirty: _children[i], context: context)
          dirty = true
          j -= 1
        }
        sum += n
        if _children[i].isBlock {
          segment = 0
          dirty = false  // block nodes take care of their own paragraph style.
        }
        else {
          segment += n
        }
      }
      // process deleted in a batch if any.
      while j >= 0 && original[j].mark == .deleted {
        NewlineReconciler.delete(old: original[j].insertNewline, context: context)
        NodeReconciler.delete(old: original[j].layoutLength, context: context)
        j -= 1
      }
      assert(j < 0)

      if segment > 0 && dirty {
        context.addParagraphStyle(forSegment: segment, self)
      }
      return sum

    case (false, false):
      let (current, original) = _computeExtendedRecords()

      var sum = 0
      var j = original.count - 1

      for i in _children.indices.reversed() {
        // process deleted in a batch if any.
        while j >= 0 && original[j].mark == .deleted {
          assert(original[j].insertNewline == false)
          NodeReconciler.delete(old: original[j].layoutLength, context: context)
          j -= 1
        }

        // process added.
        if current[i].mark == .added {
          assert(current[i].insertNewline == false)
          sum += NodeReconciler.insert(new: _children[i], context: context)
        }
        // skip none.
        else if current[i].mark == .none,
          j >= 0 && original[j].mark == .none
        {
          assert(current[i].nodeId == original[j].nodeId)
          assert(current[i].insertNewline == false)
          assert(original[j].insertNewline == false)
          sum += NodeReconciler.skip(current: current[i].layoutLength, context: context)
          j -= 1
        }
        // process dirty.
        else {
          assert(j >= 0 && current[i].nodeId == original[j].nodeId)
          assert(current[i].mark == .dirty && original[j].mark == .dirty)
          assert(current[i].insertNewline == false)
          assert(original[j].insertNewline == false)
          sum += NodeReconciler.reconcile(dirty: _children[i], context: context)
          j -= 1
        }
      }
      // process deleted in a batch if any.
      while j >= 0 && original[j].mark == .deleted {
        assert(original[j].insertNewline == false)
        NodeReconciler.delete(old: original[j].layoutLength, context: context)
        j -= 1
      }
      assert(j < 0)
      return sum
    }
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
