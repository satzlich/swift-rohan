// Copyright 2024-2025 Lie Yan

import AppKit

final class ItemListNode: ElementNode {
  final override class var type: NodeType { .itemList }

  final override func deepCopy() -> Self { Self(deepCopyOf: self) }

  final override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(itemList: self, context)
  }

  final override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    switch subtype {
    case .itemize: return _getProperties(styleSheet, itemize: ())
    case .enumerate: return _getProperties(styleSheet, enumerate: ())
    }
  }

  private final func _getProperties(
    _ styleSheet: StyleSheet, itemize: Void
  ) -> PropertyDictionary {
    if _cachedProperties == nil {
      var current = super.getProperties(styleSheet)
      let key = ParagraphProperty.listLevel
      let level = key.resolveValue(current, styleSheet).integer()!
      current[key] = .integer(level + 1)
      _cachedProperties = current
    }
    return _cachedProperties!
  }

  private final func _getProperties(
    _ styleSheet: StyleSheet, enumerate: Void
  ) -> PropertyDictionary {
    if _cachedProperties == nil {
      var current = super.getProperties(styleSheet)
      let key = ParagraphProperty.listLevel
      let level = key.resolveValue(current, styleSheet).integer()!
      current[key] = .integer(level + 1)
      _cachedProperties = current
    }
    return _cachedProperties!
  }

  // MARK: - Node(Positioning)

  final override func getLayoutOffset(_ index: RohanIndex) -> Int? {
    guard let index = index.index() else { return nil }
    return getLayoutOffset(index)
  }

  final override func getPosition(_ layoutOffset: Int) -> PositionResult<RohanIndex> {
    guard 0..._layoutLength ~= layoutOffset,
      let textList = _textList
    else {
      return .failure(SatzError(.InvalidLayoutOffset))
    }

    assert(isPlaceholderActive == false)

    if _children.isEmpty {
      let target = textList.marker(forIndex: 0).length
      return .terminal(value: .index(0), target: target)
    }

    var (k, s) = (0, 0)
    /// determine the child whose node content
    while k < _children.count {
      let ss =
        s + _formattedMarker(forIndex: k, textList).length + _children[k].layoutLength()
        + _newlines[k].intValue
      if ss > layoutOffset { break }
      (k, s) = (k + 1, ss)
    }

    if k == _children.count {
      return .terminal(value: .index(k), target: s)
    }
    else {
      // consume the item marker as well.
      let corrected = s + _formattedMarker(forIndex: k, textList).length
      if corrected >= layoutOffset {
        return .terminal(value: .index(k), target: corrected)
      }
      else {
        return .halfway(value: .index(k), consumed: corrected)
      }
    }
  }

  // MARK: - Node(Layout)

  final override func performLayout(_ context: LayoutContext, fromScratch: Bool) -> Int {
    assert(self.isBlockContainer)
    return _performLayout(context, fromScratch: fromScratch)
  }

  // MARK: - Node(Codable)

  private enum CodingKeys: String, CodingKey { case subtype }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.subtype = try container.decode(ItemListSubtype.self, forKey: .subtype)
    try super.init(from: decoder)
  }

  final override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(subtype, forKey: .subtype)
    try super.encode(to: encoder)
  }

  // MARK: - Node(Storage)

  final override class var storageTags: Array<String> {
    ItemListSubtype.allCases.map(\.rawValue)
  }

  final override class func load(from json: JSONValue) -> NodeLoaded<Node> {
    loadSelf(from: json).cast()
  }

  final override func store() -> JSONValue {
    let children: Array<JSONValue> = childrenReadonly().map { $0.store() }
    let json = JSONValue.array([.string(subtype.rawValue), .array(children)])
    return json
  }

  // MARK: - ElementNode

  final override func accept<R, C, V: NodeVisitor<R, C>, T: GenNode, S: Collection<T>>(
    _ visitor: V, _ context: C, withChildren children: S
  ) -> R {
    visitor.visit(itemList: self, context, withChildren: children)
  }

  final override func cloneEmpty() -> Self { Self(subtype, []) }

  final override func encode<S: Collection<PartialNode>>(
    to encoder: any Encoder, withChildren children: S
  ) throws where S: Encodable {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(subtype, forKey: .subtype)
    try super.encode(to: encoder, withChildren: children)
  }

  // MARK: - Storage

  final class func loadSelf(from json: JSONValue) -> NodeLoaded<ItemListNode> {
    guard case let .array(array) = json,
      array.count == 2,
      case let .string(tag) = array[0],
      let subtype = ItemListSubtype(rawValue: tag),
      case let .array(children) = array[1]
    else { return .failure(UnknownNode(json)) }
    let (nodes, corrupted) = NodeStoreUtils.loadChildren(children)
    let result = Self(subtype, nodes)
    return corrupted ? .corrupted(result) : .success(result)
  }

  // MARK: - Layout Impl.

  typealias SnapshotRecord = ElementNodeImpl.SnapshotRecord
  typealias ExtendedRecord = ElementNodeImpl.ExtendedRecord

  private final var _snapshotRecords: Array<SnapshotRecord>? = nil

  final override func snapshotDescription() -> Array<String>? {
    if let snapshotRecords = _snapshotRecords {
      return snapshotRecords.map(\.description)
    }
    return nil
  }

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

  /// Perform layout for fromScratch=true.
  @inline(__always)
  private final func _performLayoutFromScratch(_ context: LayoutContext) -> Int {
    precondition(_children.count == _newlines.count)

    let textList = self._setupTextList(context.styleSheet)
    assert(_textList != nil)

    if _children.isEmpty {
      let marker = _formattedMarker(forIndex: 0, textList)
      return StringReconciler.insert(new: marker, context: context, self)
    }

    assert(_children.isEmpty == false)

    var sum = 0
    // insert content backwards
    for i in (0..<_children.count).reversed() {
      sum += NewlineReconciler.insert(new: _newlines[i], context: context, self)
      sum += NodeReconciler.insert(new: _children[i], context: context)
      let marker = _formattedMarker(forIndex: i, textList)
      sum += StringReconciler.insert(new: marker, context: context, self)
    }

    // add paragraph style forwards
    _refreshParagraphStyle(context, { _ in true })

    return sum
  }

  /// Perform layout for fromScratch=false when snapshot was not made.
  @inline(__always)
  private final func _performLayoutSimple(_ context: LayoutContext) -> Int {
    precondition(_snapshotRecords == nil && _children.count == _newlines.count)
    assert(_children.isEmpty == false)
    assert(_textList != nil)
    let textList = _textList!
    let paragraphAttributes = _bakeParagraphAttributes(context.styleSheet, textList)

    var sum = 0
    var forceParagraphStyle = false
    for i in (0..<_children.count).reversed() {
      // skip clean.
      if _children[i].isDirty == false {
        let sum0 = sum
        sum += NewlineReconciler.skip(currrent: _newlines[i], context: context)
        sum += NodeReconciler.skip(current: _children[i], context: context)

        let marker = _formattedMarker(forIndex: i, textList)
        sum += StringReconciler.skip(current: marker, context: context)

        if forceParagraphStyle {
          _addParagraphAttributes(paragraphAttributes, marker, sum - sum0)
          forceParagraphStyle = false
        }
      }
      // process dirty.
      else {
        let sum0 = sum
        sum += NewlineReconciler.skip(currrent: _newlines[i], context: context)
        sum += NodeReconciler.reconcile(dirty: _children[i], context: context)
        let marker = _formattedMarker(forIndex: i, textList)
        sum += StringReconciler.skip(current: marker, context: context)

        _addParagraphAttributes(paragraphAttributes, marker, sum - sum0)
        forceParagraphStyle = true
      }
    }

    return sum

    // Helper
    func _addParagraphAttributes(
      _ paragraphAttributes: Dictionary<NSAttributedString.Key, Any>,
      _ itemMarker: String, _ rangeSize: Int
    ) {
      var paragraphAttributesCopy = paragraphAttributes
      let itemMarker = NSAttributedString(string: itemMarker)
      paragraphAttributesCopy[.itemMarker] = itemMarker

      let begin = context.layoutCursor
      context.addParagraphAttributes(paragraphAttributesCopy, begin..<begin + rangeSize)
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

  /// Perform layout for fromScratch=false when snapshot has been made.
  @inline(__always)
  private final func _performLayoutFull(_ context: LayoutContext) -> Int {
    precondition(_snapshotRecords != nil && _children.count == _newlines.count)
    assert(_textList != nil)
    let textList = _textList!

    if _children.isEmpty {
      // remove previous layout
      context.deleteBackwards(_layoutLength)
      let marker = _formattedMarker(forIndex: 0, textList)
      return StringReconciler.insert(new: marker, context: context, self)
    }
    assert(_children.isEmpty == false)

    let (current, original) = _computeExtendedRecords()
    if original.isEmpty {
      // remove previous layout
      context.deleteBackwards(_layoutLength)
    }

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
        updateVacuumRange()
        while j >= 0 && original[j].mark == .deleted {
          NewlineReconciler.delete(old: original[j].insertNewline, context: context)
          NodeReconciler.delete(old: original[j].layoutLength, context: context)
          let marker = _formattedMarker(forIndex: j, textList)
          StringReconciler.delete(old: marker, context: context)
          j -= 1
        }
        assert(j < 0 || [.none, .dirty].contains(original[j].mark))
      }

      while i >= 0 && current[i].mark == .added {
        let newline = current[i].insertNewline
        sum += NewlineReconciler.insert(new: newline, context: context, self)
        //
        sum += NodeReconciler.insert(new: _children[i], context: context)
        //
        let marker = _formattedMarker(forIndex: i, textList)
        sum += StringReconciler.insert(new: marker, context: context, self)
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
        //
        sum += NodeReconciler.skip(current: current[i].layoutLength, context: context)
        //
        let oldMarker = _formattedMarker(forIndex: j, textList)
        let newMarker = _formattedMarker(forIndex: i, textList)
        let markers = (oldMarker, newMarker)
        sum += StringReconciler.reconcile(dirty: markers, context: context, self)

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
        //
        sum += NodeReconciler.reconcile(dirty: _children[i], context: context)
        //
        let oldMarker = _formattedMarker(forIndex: j, textList)
        let newMarker = _formattedMarker(forIndex: i, textList)
        let markers = (oldMarker, newMarker)
        sum += StringReconciler.reconcile(dirty: markers, context: context, self)

        i -= 1
        j -= 1
      }
    }

    do {
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
    assert(_textList != nil)
    let textList = _textList!
    let paragraphAttributes = _bakeParagraphAttributes(context.styleSheet, textList)

    var location = context.layoutCursor
    for i in 0..<_children.count {
      let child = _children[i]
      let itemMarker = _formattedMarker(forIndex: i, textList)
      let end =
        location + itemMarker.length + child.layoutLength() + _newlines[i].intValue
      if predicate(i) {
        var paragraphAttributesCopy = paragraphAttributes
        let itemMarker = NSAttributedString(string: itemMarker)
        paragraphAttributesCopy[.itemMarker] = itemMarker
        context.addParagraphAttributes(paragraphAttributesCopy, location..<end)
      }
      location = end
    }
  }

  final override func getLayoutOffset(_ index: Int) -> Int? {
    guard index <= childCount,
      let textList = _textList
    else { return nil }

    if _children.isEmpty {
      return _formattedMarker(forIndex: 0, textList).length
    }
    else {
      assert(isPlaceholderActive == false)
      let range = 0..<index
      let s0 = range.lazy
        .map { self._formattedMarker(forIndex: $0, textList).length }
        .reduce(0, +)
      let s1 = _children[range].lazy.map { $0.layoutLength() }.reduce(0, +)
      let s2 = _newlines.asBitArray[range].lazy.map(\.intValue).reduce(0, +)
      let sum = s0 + s1 + s2
      return index < childCount
        ? sum + _formattedMarker(forIndex: index, textList).length
        : sum
    }
  }

  // MARK: - ItemListNode

  let subtype: ItemListSubtype
  private var _textList: RhTextList?

  init(_ subtype: ItemListSubtype, _ children: ElementStore) {
    self.subtype = subtype
    super.init(children)
  }

  private init(deepCopyOf node: ItemListNode) {
    self.subtype = node.subtype
    super.init(deepCopyOf: node)
  }

  /// Compute list level of this list node.
  private func _getListLevel(_ styleSheet: StyleSheet) -> Int {
    let key = ParagraphProperty.listLevel
    let properties = self.getProperties(styleSheet)
    return key.resolveValue(properties, styleSheet).integer()!
  }

  /// Set up `self._textList`.
  private func _setupTextList(_ styleSheet: StyleSheet) -> RhTextList {
    let listLevel = self._getListLevel(styleSheet)
    let textList = self.subtype.textList(forLevel: listLevel)
    self._textList = textList
    return textList
  }

  private func _formattedMarker(forIndex index: Int, _ textList: RhTextList) -> String {
    textList.marker(forIndex: index) + "\u{2000}"
  }

  private func _bakeParagraphAttributes(
    _ styleSheet: StyleSheet, _ textList: RhTextList
  ) -> Dictionary<NSAttributedString.Key, Any> {
    let properties = getProperties(styleSheet)

    // prepare paragraph style
    let paragraphProperty = ParagraphProperty.resolveAggregate(properties, styleSheet)
    let paragraphStyle =
      paragraphProperty.getParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
    let fontSize = TextProperty.size.resolveValue(properties, styleSheet).fontSize()!
    let indent = Self.indent(forLevel: textList.level).floatValue * fontSize.floatValue
    paragraphStyle.firstLineHeadIndent = indent
    paragraphStyle.headIndent = indent

    // add list level as well.
    let attributes: Dictionary<NSAttributedString.Key, Any> = [
      .paragraphStyle: paragraphStyle,
      .listLevel: textList.level,
      .listIndent: indent,
    ]
    return attributes
  }

  static var commandRecords: Array<CommandRecord> {
    ItemListSubtype.allCases.map { subtype in
      let expr = ItemListExpr(subtype)
      return CommandRecord(subtype.command, CommandBody(expr, 1))
    }
  }

  /// Distance from text container edge to paragraph beginning for given list
  /// level (1-based).
  /// - Note: There is a 0.5em gap between item marker and paragraph beginning.
  internal static func indent(forLevel level: Int) -> Em {
    precondition(level >= 1)
    return Em(2.5 + 2 * Double(level - 1))
  }
}
