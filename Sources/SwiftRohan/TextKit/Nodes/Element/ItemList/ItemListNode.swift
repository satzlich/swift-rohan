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
      // set list level
      var properties = super.getProperties(styleSheet)
      var listLevel =
        ParagraphProperty.listLevel.resolveValue(properties, styleSheet).integer()!
      listLevel += 1
      properties[ParagraphProperty.listLevel] = .integer(listLevel)

      // set first line head indent and head indent
      let textSize = TextProperty.size.resolveValue(properties, styleSheet).fontSize()!
      let indent = Self.indent(forLevel: listLevel).floatValue * textSize.floatValue
      properties[ParagraphProperty.firstLineHeadIndent] = .float(indent)
      properties[ParagraphProperty.headIndent] = .float(indent)

      _cachedProperties = properties
    }
    return _cachedProperties!
  }

  private final func _getProperties(
    _ styleSheet: StyleSheet, enumerate: Void
  ) -> PropertyDictionary {
    _getProperties(styleSheet, itemize: ())
  }

  // MARK: - Node(Positioning)

  final override func getLayoutOffset(_ index: RohanIndex) -> Int? {
    guard let index = index.index() else { return nil }
    return getLayoutOffset(index)
  }

  final override func getPosition(_ layoutOffset: Int) -> PositionResult<RohanIndex> {
    guard 0..._layoutLength ~= layoutOffset else {
      return .failure(SatzError(.InvalidLayoutOffset))
    }

    assert(isPlaceholderActive == false)

    if _children.isEmpty {
      let target = _initialFiller(forIndex: 0).length
      return .terminal(value: .index(0), target: target)
    }

    var (k, s) = (0, 0)
    /// determine the child whose node content
    while k < _children.count {
      let ss =
        s + _initialFiller(forIndex: k).length + _children[k].layoutLength()
        + _newlines[k].intValue
      if ss > layoutOffset { break }
      (k, s) = (k + 1, ss)
    }

    if k == _children.count {
      return .terminal(value: .index(k), target: s)
    }
    else {
      let consumed = s + _initialFiller(forIndex: k).length
      return consumed < layoutOffset
        ? .halfway(value: .index(k), consumed: consumed)
        : .terminal(value: .index(k), target: consumed)
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

  // MARK: - Node(Tree API)

  final override func leadingCursorCorrection() -> Double { -_listIndent }

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
      _snapshotRecords = _children.indices.map { i in
        SnapshotRecord(
          _children[i], _newlines[i], leadingNewline: _newlines.value(before: i))
      }
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

  private final func _performLayoutEmpty(_ context: LayoutContext) -> Int {
    precondition(_children.isEmpty)
    let itemAttributes = _bakeItemAttributes(context.styleSheet)
    let sum =
      StringReconciler.insert(new: _initialFiller(forIndex: 0), context: context, self)
    let location = context.layoutCursor
    let end = location + sum
    _addItemAttributes(
      context, itemAttributes, _attributedMarker(forIndex: 0), location..<end)
    return sum
  }

  /// Perform layout for fromScratch=true.
  @inline(__always)
  private final func _performLayoutFromScratch(_ context: LayoutContext) -> Int {
    precondition(_children.count == _newlines.count)

    // set up properties before layout.
    self._setupNodeProperties(context.styleSheet)

    switch _children.isEmpty {
    case true:
      return _performLayoutEmpty(context)

    case false:
      var sum = 0
      for i in _children.indices.reversed() {
        sum += NewlineReconciler.insert(new: _newlines[i], context: context, self)
        sum += NodeReconciler.insert(new: _children[i], context: context)
        sum += StringReconciler.insert(
          new: _initialFiller(forIndex: i), context: context, self)
      }
      _refreshParagraphStyle(context, { _ in true })
      return sum
    }
  }

  /// Perform layout for fromScratch=false when snapshot was not made.
  @inline(__always)
  private final func _performLayoutSimple(_ context: LayoutContext) -> Int {
    precondition(_snapshotRecords == nil && _children.count == _newlines.count)
    assert(_children.isEmpty == false)
    let itemAttributes = _bakeItemAttributes(context.styleSheet)

    var sum = 0
    for i in _children.indices.reversed() {
      // skip clean.
      if _children[i].isDirty == false {
        sum += NewlineReconciler.skip(currrent: _newlines[i], context: context)
        sum += NodeReconciler.skip(current: _children[i], context: context)
        sum += StringReconciler.skip(
          current: _initialFiller(forIndex: i), context: context)
      }
      // process dirty.
      else {
        let n0 = NewlineReconciler.skip(currrent: _newlines[i], context: context)
        let n1 = NodeReconciler.reconcile(dirty: _children[i], context: context)
        let n2 = StringReconciler.skip(
          current: _initialFiller(forIndex: i), context: context)
        sum += n0 + n1 + n2

        let location = context.layoutCursor
        let end = location + n2
        _addItemAttributes(
          context, itemAttributes, _attributedMarker(forIndex: i), location..<end)
      }
    }

    return sum
  }

  /// Perform layout for fromScratch=false when snapshot has been made.
  @inline(__always)
  private final func _performLayoutFull(_ context: LayoutContext) -> Int {
    precondition(_snapshotRecords != nil && _children.count == _newlines.count)

    guard _children.isEmpty == false else {
      context.deleteBackwards(_layoutLength)
      return _performLayoutEmpty(context)
    }

    let (current, original) = _computeExtendedRecords()
    if original.isEmpty { context.deleteBackwards(_layoutLength) }

    var sum = 0
    var j = original.count - 1

    // first index where item marker changed
    var firstDirtyMarker: Int = _children.count

    for i in _children.indices.reversed() {
      // process deleted in a batch if any.
      if j >= 0 && original[j].mark == .deleted {
        firstDirtyMarker = i
      }
      while j >= 0 && original[j].mark == .deleted {
        NewlineReconciler.delete(old: original[j].trailingNewline, context: context)
        NodeReconciler.delete(old: original[j].layoutLength, context: context)
        StringReconciler.delete(old: _initialFiller(forIndex: j), context: context)
        j -= 1
      }

      // process added.
      if i >= 0 && current[i].mark == .added {
        firstDirtyMarker = i
        //
        sum += NewlineReconciler.insert(
          new: current[i].trailingNewline, context: context, self)
        sum += NodeReconciler.insert(new: _children[i], context: context)
        sum += StringReconciler.insert(
          new: _initialFiller(forIndex: i), context: context, self)
      }
      // skip none
      else if current[i].mark == .none,
        j >= 0 && original[j].mark == .none
      {
        assert(current[i].nodeId == original[j].nodeId)

        sum += NewlineReconciler.reconcile(
          dirty: (original[j].trailingNewline, current[i].trailingNewline),
          context: context, self)
        sum += NodeReconciler.skip(current: current[i].layoutLength, context: context)
        sum += StringReconciler.reconcile(
          dirty: (_initialFiller(forIndex: j), _initialFiller(forIndex: i)),
          context: context, self)
        j -= 1
      }
      else {
        assert(j >= 0 && current[i].nodeId == original[j].nodeId)
        assert(current[i].mark == .dirty && original[j].mark == .dirty)
        sum += NewlineReconciler.reconcile(
          dirty: (original[j].trailingNewline, current[i].trailingNewline),
          context: context, self)
        sum += NodeReconciler.reconcile(dirty: _children[i], context: context)
        sum += StringReconciler.reconcile(
          dirty: (_initialFiller(forIndex: j), _initialFiller(forIndex: i)),
          context: context, self)

        j -= 1
      }
    }
    // process deleted in a batch if any.
    if j >= 0 && original[j].mark == .deleted {
      firstDirtyMarker = 0
    }
    while j >= 0 && original[j].mark == .deleted {
      NewlineReconciler.delete(old: original[j].trailingNewline, context: context)
      NodeReconciler.delete(old: original[j].layoutLength, context: context)
      StringReconciler.delete(old: _initialFiller(forIndex: j), context: context)
      j -= 1
    }
    assert(j < 0)

    if subtype.isMarkerConstant {
      _refreshParagraphStyle(
        context, { i in current[i].mark == .added || current[i].mark == .dirty })
    }
    else {
      let refreshRange = firstDirtyMarker..<_children.count
      _refreshParagraphStyle(
        context, { i in current[i].mark == .dirty || refreshRange.contains(i) })
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
      _children.indices.map { i in
        let node = _children[i]
        let insertNewline = _newlines[i]
        let newlineBefore = _newlines.value(before: i)
        let mark: LayoutMark =
          !originalIds.contains(node.id)
          ? .added
          : (node.isDirty ? .dirty : .none)
        return ExtendedRecord(mark, node, insertNewline, leadingNewline: newlineBefore)
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

  @inline(__always)
  private final func _addItemAttributes(
    _ context: LayoutContext,
    _ itemAttributes: Dictionary<NSAttributedString.Key, Any>,
    _ itemMarker: NSAttributedString, _ range: Range<Int>
  ) {
    var attributesCopy = itemAttributes
    attributesCopy[.rhItemMarker] = itemMarker
    context.addAttributes(attributesCopy, range)
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
    let itemAttributes = _bakeItemAttributes(context.styleSheet)

    var location = context.layoutCursor
    for i in 0..<_children.count {
      let end = location + _initialFiller(forIndex: i).length
      if predicate(i) {
        _addItemAttributes(
          context, itemAttributes, _attributedMarker(forIndex: i), location..<end)
      }
      location = end + _children[i].layoutLength() + _newlines[i].intValue
    }
  }

  final override func getLayoutOffset(_ index: Int) -> Int? {
    guard index <= childCount else { return nil }

    if _children.isEmpty {
      return _initialFiller(forIndex: 0).length
    }
    else {
      assert(isPlaceholderActive == false)
      let range = 0..<index
      let s0 = range.lazy.map { self._initialFiller(forIndex: $0).length }.reduce(0, +)
      let s1 = _children[range].lazy.map { $0.layoutLength() }.reduce(0, +)
      let s2 = _newlines.asBitArray[range].lazy.map(\.intValue).reduce(0, +)
      let sum = s0 + s1 + s2
      return index < _children.count
        ? sum + _initialFiller(forIndex: index).length
        : sum
    }
  }

  // MARK: - ItemListNode

  let subtype: ItemListSubtype

  /// Text list used for this item list.
  private var _textList: RhTextList = RhTextList.itemize(level: 1, marker: "•")
  /// Text attributes used for item markers.
  private var _textAttributes: Dictionary<NSAttributedString.Key, Any> = [:]
  /// Indent for item text.
  private var _listIndent: CGFloat = 0.0

  init(_ subtype: ItemListSubtype, _ children: ElementStore) {
    self.subtype = subtype
    super.init(children)
  }

  private init(deepCopyOf node: ItemListNode) {
    self.subtype = node.subtype
    super.init(deepCopyOf: node)
  }

  /// Set up properties for layout.
  private func _setupNodeProperties(_ styleSheet: StyleSheet) {
    let properties = self.getProperties(styleSheet)
    // resolve list level
    let listLevel =
      ParagraphProperty.listLevel.resolveValue(properties, styleSheet).integer()!
    self._textList = self.subtype.textList(forLevel: listLevel)
    // prepare text attributes
    let textProperty = TextProperty.resolveAggregate(properties, styleSheet)
    self._textAttributes = textProperty.getAttributes()
    // prepare list indent
    self._listIndent =
      Self.indent(forLevel: listLevel).floatValue * textProperty.size.floatValue
  }

  private func _attributedMarker(forIndex index: Int) -> NSAttributedString {
    let marker = _textList.marker(forIndex: index) + "\u{2000}"
    return NSAttributedString(string: marker, attributes: _textAttributes)
  }

  /// String used to fill the initial space of each item.
  private func _initialFiller(forIndex index: Int) -> String { "\u{200B}" }

  private func _bakeItemAttributes(
    _ styleSheet: StyleSheet
  ) -> Dictionary<NSAttributedString.Key, Any> {
    // NOTE: we have to add paragraph properties to item attributes, otherwise
    // there will be a vacuum at the initial filler.
    let properties = self.getProperties(styleSheet)
    let paragraphProperty = ParagraphProperty.resolveAggregate(properties, styleSheet)
    let attributes = paragraphProperty.getAttributes()
    return attributes
  }

  static var commandRecords: Array<CommandRecord> {
    ItemListSubtype.allCases.map { subtype in
      //      let expr = ItemListExpr(subtype, [ParagraphExpr()])
      let expr = ItemListExpr(subtype, [])
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
