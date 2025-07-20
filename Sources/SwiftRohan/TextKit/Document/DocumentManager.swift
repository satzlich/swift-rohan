// Copyright 2024-2025 Lie Yan

import AppKit
import DequeModule
import Foundation
import LatexParser
import _RopeModule

public final class DocumentManager: NSObject {
  typealias SegmentType = NSTextLayoutManager.SegmentType
  typealias SegmentOptions = NSTextLayoutManager.SegmentOptions
  typealias EnumerateContentsBlock = (RhTextRange?, PartialNode) -> Bool
  typealias EnumerateTextSegmentsBlock = (RhTextRange?, CGRect, CGFloat) -> Bool

  /// The content of the document.
  private var content: DocumentContent
  /// The root node of the document.
  private var rootNode: RootNode { content.rootNode }

  /// The style sheet for the document
  public var styleSheet: StyleSheet {
    didSet {
      // reset style cache
      rootNode.resetCachedProperties()

      // clear text content storage
      textContentStorage.performEditingTransaction {
        let documentRange = textContentStorage.documentRange
        textContentStorage.replaceContents(in: documentRange, with: nil)
      }
      assert(textContentStorage.documentRange.isEmpty)
    }
  }

  internal var textSelection: RhTextSelection? {
    didSet {
      #if LOG_TEXT_SELECTION
      let string = textSelection?.debugDescription ?? "no selection"
      Rohan.logger.debug("\(string)")
      #endif
    }
  }

  private(set) lazy var textSelectionNavigation: TextSelectionNavigation = .init(self)

  // MARK: - base Layout Manager

  /// base text content storage
  private(set) var textContentStorage: NSTextContentStorage
  /// base text layout manager
  private(set) var textLayoutManager: NSTextLayoutManager

  internal var textContainer: NSTextContainer? {
    get { textLayoutManager.textContainer }
    _modify { yield &textLayoutManager.textContainer }
  }

  internal var usageBoundsForTextContainer: CGRect {
    textLayoutManager.usageBoundsForTextContainer
  }

  internal var textViewportLayoutController: NSTextViewportLayoutController {
    textLayoutManager.textViewportLayoutController
  }

  // MARK: - Init

  convenience init(_ rootNode: RootNode, _ styleSheet: StyleSheet) {
    self.init(content: DocumentContent(rootNode), styleSheet)
  }

  public init(content: DocumentContent = .init(), _ styleSheet: StyleSheet) {
    self.content = content
    self.styleSheet = styleSheet

    self.textContentStorage = NSTextContentStoragePatched()
    self.textLayoutManager = NSTextLayoutManager()
    self.textSelection = nil

    super.init()

    // set up base content storage and layout manager
    textContentStorage.addTextLayoutManager(textLayoutManager)
    textContentStorage.primaryTextLayoutManager = textLayoutManager

    // set up default text container
    textLayoutManager.textContainer = NSTextContainer()

    // set up delegate
    textContentStorage.delegate = self
    textLayoutManager.delegate = self
  }

  internal func setContent(_ content: DocumentContent, with styleSheet: StyleSheet) {
    // reset content
    self.content = content
    self.styleSheet = styleSheet

    // rest base content storage and layout manager
    textContentStorage.performEditingTransaction {
      textContentStorage.replaceContents(in: textContentStorage.documentRange, with: nil)
    }
    assert(textContentStorage.documentRange.isEmpty)

    // reset text selection
    textSelection = nil
  }

  // MARK: - Query

  public var documentRange: RhTextRange {
    let location = TextLocation([], 0).toUseSpace(for: rootNode)!
    let childCount = rootNode.childCount
    let endLocation = TextLocation([], childCount).toUseSpace(for: rootNode)!
    return RhTextRange(location, endLocation)!
  }

  /// Returns true if the document is empty.
  public var isEmpty: Bool { rootNode.childCount == 0 }

  /// Enumerate contents in the given range.
  ///
  /// - Parameter block: The closure to execute for each content. The closure
  ///     should return false to break out of enumeration.
  /// - Invariant: Partial nodes are guaranteed to be valid before edit operations.
  internal func enumerateContents(
    in range: RhTextRange,
    // (range?, partial node) -> continue
    using block: EnumerateContentsBlock
  ) throws {
    try TreeUtils.enumerateContents(range, rootNode, using: block)
  }

  /// Map contents in the given range to a new array.
  /// - Returns: The array of mapped values, or nil if the range is invalid.
  internal func mapContents<T, S: RangeReplaceableCollection<T>>(
    in range: RhTextRange, _ f: (PartialNode) -> T
  ) -> S? {
    var values: S = .init()
    do {
      try enumerateContents(in: range) { _, node in
        values.append(f(node))
        return true  // continue
      }
      return values
    }
    catch {
      return nil
    }
  }

  internal func containerProperty(for location: TextLocation) -> ContainerProperty? {
    TreeUtils.containerProperty(for: location, rootNode)
  }

  // MARK: - Editing

  /// Replace contents in range with nodes.
  /// - Returns: the range of inserted contents if successful; otherwise, an error.
  internal func replaceContents(
    in range: RhTextRange, with nodes: Array<Node>?
  ) -> EditResult<RhTextRange> {
    guard let nodes, nodes.isEmpty == false else {
      // if node is nil or empty, just delete contents in range
      switch _deleteContents(in: range) {
      case let .success(result):
        if let normalised = result.normalised(for: rootNode) {
          return .success(normalised)
        }
        assertionFailure("Normalisation failed")
        return .success(result)

      case .failure(let error):
        return .failure(error)
      }
    }

    // forward request if nodes is a single text node
    if let textNode = nodes.getOnlyElement() as? TextNode {
      return replaceCharacters(in: range, with: textNode.string)
    }

    // validate insertion
    let content: Array<ContentProperty> = TreeUtils.contentProperty(of: nodes)
    guard content.isEmpty == false,
      let container = containerProperty(for: range.location),
      content.allSatisfy({ $0.isCompatible(with: container) })
    else { return .failure(SatzError(.InsertOperationRejected)) }

    // remove contents in range and set insertion point
    let location: TextLocation
    if range.isEmpty {
      location = range.location
    }
    else {
      let result = _deleteContents(in: range)
      switch result {
      case .failure(let error):
        return .failure(error)
      case .success(let result):
        location = result.location
      }
    }

    // insert nodes
    let result: EditResult<RhTextRange>

    if nodes.allSatisfy(NodePolicy.canBeToplevelNode(_:)) {
      switch TreeUtils.insertBlockNodes(nodes, at: location, rootNode) {
      case let .success(range):
        result = .blockInserted(range)
      case let .failure(error):
        return .failure(error)
      }
    }
    else {
      result = TreeUtils.insertInlineContent(nodes, at: location, rootNode)
    }

    return result.map { range in
      if let normalised = range.normalised(for: rootNode) {
        return normalised
      }
      assertionFailure("Normalisation failed")
      return range
    }
  }

  /// Replace characters in range with string.
  /// - Returns: the range of inserted contents if successful; otherwise, an error.
  /// - Precondition: `string` is free of newlines except line separators `\u{2028}`
  /// - Postcondition: If `string` is non-empty, the returned range is within a
  ///     single text node.
  internal func replaceCharacters(
    in range: RhTextRange, with string: BigString
  ) -> EditResult<RhTextRange> {
    precondition(TextNode.validate(string: string))
    // just remove contents if string is empty
    if string.isEmpty {
      switch _deleteContents(in: range) {
      case let .success(result):
        if let normalised = result.normalised(for: rootNode) {
          return .success(normalised)
        }
        assertionFailure("Normalisation failed")
        return .success(result)

      case let .failure(error):
        return .failure(error)
      }
    }
    // remove range
    let location: TextLocation
    if !range.isEmpty {
      switch _deleteContents(in: range) {
      case .success(let result):
        location = result.location
      case .failure(let error):
        return .failure(error)
      }
    }
    else {
      location = range.location
    }
    // perform insertion
    let result = TreeUtils.insertString(string, at: location, rootNode)
    return result.map { range in
      if let normalised = range.normalised(for: rootNode) {
        return normalised
      }
      assertionFailure("Normalisation failed")
      return range
    }
  }

  /// Returns the nodes that should be inserted if the user presses the return key.
  func resolveInsertParagraphBreak(at range: RhTextRange) -> Array<Node> {
    func paragraphs(_ n: Int) -> Array<ParagraphNode> {
      (0..<n).map { _ in ParagraphNode() }
    }

    guard range.isEmpty,
      let trace = Trace.from(range.location, rootNode)
    else { return paragraphs(2) }

    let node = trace.last!.node
    let index = trace.last!.index

    if let node = node as? ElementNode,
      node.containerType == .block,
      let index = index.index()
    {
      if node.childCount == 0
        || (index < node.childCount && node.getChild(index).isTransparent)
      {
        return paragraphs(2)
      }
      else {
        return paragraphs(1)
      }
    }
    else {
      return paragraphs(2)
    }
  }

  /// Delete contents in range.
  /// - Returns: the new insertion point if successful; otherwise, an error.
  private func _deleteContents(in range: RhTextRange) -> SatzResult<RhTextRange> {
    // if range is empty, just return the location
    if range.isEmpty { return .success(range) }

    // validate range before deletion
    guard TreeUtils.validateRange(range, rootNode)
    else { return .failure(SatzError(.InvalidTextRange)) }

    // perform deletion
    return TreeUtils.removeTextRange(range, rootNode)
      .map { RhTextRange($0.location) }
  }

  // MARK: - Edit Math

  /// Add a math component to the node/nodes at the given range.
  ///
  /// If the node at the location is a math node and the specified math component
  /// can be attached, the component is added to the math node. Otherwise, the
  /// range is replaced with a new math node with the specified component.
  /// - Returns: (range of resulting math node, isAdded) if successful;
  ///   otherwise, an error.
  internal func attachOrGotoMathComponent(
    _ range: RhTextRange, _ mathIndex: MathIndex, _ component: ElementStore
  ) -> SatzResult<(RhTextRange, isAdded: Bool)> {

    let location = range.location
    let end = range.endLocation

    if location.indices == end.indices,
      location.offset + 1 == end.offset,
      let node = TreeUtils.getNode(at: location, rootNode),
      let node = node as? MathNode,
      node.isComponentAllowed(mathIndex)
    {
      // if component is absent, add it to the node
      if node.getComponent(mathIndex) == nil {
        node.addComponent(mathIndex, component, inStorage: true)
        return .success((range, true))
      }
      else {
        return .success((range, false))
      }
    }
    else {
      guard let nucleus: ElementStore = mapContents(in: range, { $0.deepCopy() }),
        let mathNode = composeMathNode(nucleus, mathIndex, component)
      else {
        return .failure(SatzError(.InvalidTextRange))
      }
      let result = replaceContents(in: range, with: [mathNode])
      switch result {
      case let .success(range1):
        // NOTE: we have to use `crossedObjectAt` instead of `getNode(at:)` here,
        //    as replaceContents() may normalise the range.
        guard
          let crossedObject = crossedObjectAt(range1.endLocation, direction: .backward)
        else {
          return .failure(SatzError(.InvalidTextRange))
        }

        switch crossedObject {
        case .nonTextNode(let node, let location):
          assert(node === mathNode)
          let end = location.with(offsetDelta: 1)
          let range2 = RhTextRange(location, end)!
          return .success((range2, true))

        case .text,
          .blockBoundary:
          assertionFailure("Invalid crossed object")
          return .failure(SatzError(.InvalidTextRange))
        }

      case .extraParagraph,
        .blockInserted:
        assertionFailure("Unexpected result")
        return .failure(SatzError(.ModifyMathFailure))

      case let .failure(error):
        return .failure(error)
      }
    }

    // Helper

    func composeMathNode(
      _ nucleus: ElementStore, _ mathIndex: MathIndex, _ component: ElementStore
    ) -> MathNode? {
      switch mathIndex {
      case .sub:
        return AttachNode(nuc: nucleus, sub: component)
      case .sup:
        return AttachNode(nuc: nucleus, sup: component)
      default:
        assertionFailure("Invalid math index")
        return nil
      }
    }
  }

  /// Remove a math component from the math node at the given range.
  /// - Returns: range of resulting math node if the math node remains, or
  ///   range of the substituted nucleus if the math node is removed; otherwise,
  ///   an error.
  internal func removeMathComponent(
    _ range: RhTextRange, _ mathIndex: MathIndex
  ) -> EditResult<RhTextRange> {
    let location = range.location
    let end = range.endLocation

    guard location.indices == end.indices,
      location.offset + 1 == end.offset,
      let node = TreeUtils.getNode(at: location, rootNode)
    else {
      return .failure(SatzError(.InvalidTextRange))
    }

    switch node {
    case let node as AttachNode:
      let remaining = node.enumerateComponents().map(\.index).filter { $0 != mathIndex }
      if remaining.count == 1 {
        assert(remaining[0] == .nuc)
        guard node.getComponent(mathIndex) != nil,
          let nucleus = node.getComponent(.nuc)
        else {
          return .failure(SatzError(.InvalidMathComponent))
        }
        let contents = nucleus.childrenReadonly().map { $0.deepCopy() }
        return replaceContents(in: range, with: contents)
      }
      else {
        assert(remaining.count > 1)
        node.removeComponent(mathIndex, inStorage: true)
        return .success(range)
      }

    case let node as RadicalNode:
      if mathIndex == .index {
        node.removeComponent(mathIndex, inStorage: true)
        return .success(range)
      }
      else {
        return .failure(SatzError(.InvalidMathComponent))
      }

    default:
      return .failure(SatzError(.InvalidTextRange))
    }
  }

  /// Modify the grid node at the given range as specified by the instruction.
  /// - Returns: the range of resulting grid node if successful; otherwise, an error.
  internal func modifyGrid(
    _ range: RhTextRange, _ instruction: GridOperation
  ) -> SatzResult<RhTextRange> {
    let location = range.location
    let end = range.endLocation

    guard location.indices == end.indices,
      location.offset + 1 == end.offset,
      let node = TreeUtils.getNode(at: location, rootNode),
      let node = node as? ArrayNode
    else {
      return .failure(SatzError(.InvalidTextRange))
    }

    switch instruction {
    case let .insertRow(elements, at: row):
      node.insertRow(at: row, inStorage: true)
      // insertRow() above has inserted an empty row, so we need to
      // insert elements at the beginning of the row.
      let n = Swift.min(elements.count, node.columnCount)
      for column in 0..<n {
        node.getElement(row, column)
          .insertChildren(contentsOf: elements[column], at: 0, inStorage: true)
      }

    case let .insertColumn(elements, at: column):
      node.insertColumn(at: column, inStorage: true)
      // insertColumn() above has inserted an empty column, so we need to
      // insert elements at the beginning of the column.
      let n = Swift.min(elements.count, node.rowCount)
      for row in 0..<n {
        node.getElement(row, column)
          .insertChildren(contentsOf: elements[row], at: 0, inStorage: true)
      }

    case let .removeRow(row):
      guard node.rowCount > 1 else { return .failure(SatzError(.ModifyGridFailure)) }
      node.removeRow(at: row, inStorage: true)

    case let .removeColumn(column):
      guard node.columnCount > 1 else { return .failure(SatzError(.ModifyGridFailure)) }
      node.removeColumn(at: column, inStorage: true)
    }

    return .success(range)
  }

  // MARK: - Layout

  private final func _getLayoutContext() -> TextLayoutContext {
    TextLayoutContext(styleSheet, textContentStorage, textLayoutManager)
  }

  /// Synchronize text content storage with current document tree.
  public final func reconcileContentStorage() {
    // create layout context
    let layoutContext = self._getLayoutContext()

    // perform layout
    layoutContext.beginEditing()
    layoutContext.resetCursor()
    textContentStorage.performEditingTransaction {
      let fromScratch = textContentStorage.documentRange.isEmpty
      guard rootNode.isDirty || fromScratch else { return }
      _ = rootNode.performLayout(
        layoutContext, fromScratch: fromScratch, atBlockEdge: true)
    }
    layoutContext.endEditing()
    assert(rootNode.isDirty == false)
    assert(rootNode.layoutLength() == textContentStorage.textStorage!.length)
  }

  public enum LayoutScope { case viewport, document }

  /// Synchronize text layout with text content storage.
  public final func ensureLayout(scope: LayoutScope) {
    precondition(rootNode.isDirty == false)
    // ensure layout synchronization
    let documentRange = textContentStorage.documentRange
    let layoutRange: NSTextRange =
      scope == .viewport
      ? NSTextRange(location: documentRange.endLocation)
      : documentRange
    textLayoutManager.ensureLayout(for: layoutRange)
  }

  /// Synchronize text layout and text content storage with current document.
  public final func reconcileLayout(scope: LayoutScope) {
    // ensure content storage synchronization
    reconcileContentStorage()
    // ensure layout synchronization
    ensureLayout(scope: scope)
  }

  /// Enumerate text segments in the given range.
  /// - Note: `block` should return **false** to break out of enumeration.
  func enumerateTextSegments(
    in textRange: RhTextRange, type: SegmentType, options: SegmentOptions = [],
    // (textSegmentRange, textSegmentFrame, baselinePosition) -> continue
    using block: EnumerateTextSegmentsBlock
  ) {
    let path = textRange.location.asArray
    let endPath = textRange.endLocation.asArray
    _ = rootNode.enumerateTextSegments(
      ArraySlice(path), ArraySlice(endPath),
      context: _getLayoutContext(), layoutOffset: 0, originCorrection: .zero,
      type: type, options: options, using: block)
  }

  /// Resolve the text location for the given point.
  /// - Returns: The resolved text location if successful; otherwise, nil.
  internal func resolveTextLocation(with point: CGPoint) -> AffineLocation? {
    #if LOG_PICKING_POINT
    Rohan.logger.debug("Interacting at \(point.debugDescription)")
    #endif

    let context = _getLayoutContext()
    var trace = Trace()
    var affinity = SelectionAffinity.downstream

    let modified = rootNode.resolveTextLocation(
      with: point, context: context, layoutOffset: 0, trace: &trace, affinity: &affinity)
    guard modified else { return nil }

    // Fix affinity if needed:
    //  When an empty paragraph is selected from beyond the right edge, the
    //  affinity is resolved to upstream, but it should be downstream.
    if let last = trace.last,
      last.node.layoutType.mayEmitBlock,
      last.index == .index(0)
    {
      affinity = .downstream
    }

    if let location = trace.toUserSpaceLocation() {
      return AffineLocation(location, affinity)
    }
    return nil
  }

  // MARK: - Navigation

  internal func destinationLocation(
    for location: AffineLocation,
    direction: TextSelectionNavigation.Direction,
    destination: TextSelectionNavigation.Destination,
    extending: Bool
  ) -> AffineLocation? {

    switch destination {
    case .character:
      return destinationLocationForChar(
        for: location, direction: direction, extending: extending)

    case .word:
      return destinationLocationForWord(
        for: location, direction: direction, extending: extending)
        ?? destinationLocationForChar(
          for: location, direction: direction, extending: extending)

    default:
      return nil
    }
  }

  /// Resolve the selection affinity for the given move.
  /// - Parameters:
  ///   - direction: The navigation direction.
  ///   - location: The target location.
  internal func resolveAffinityForMove(
    in direction: TextSelectionNavigation.Direction,
    target location: TextLocation
  ) -> SelectionAffinity {
    precondition(direction == .forward || direction == .backward)

    func isWhitespace(_ object: CrossedObject) -> Bool {
      switch object {
      case .text(let string, _):
        return string.count == 1 && string.first!.isWhitespace == true
      case .nonTextNode(let node, _):
        return isLinebreakNode(node)
      case .blockBoundary:
        return true
      }
    }

    switch direction {
    case .forward:
      if let object = self.crossedObjectAt(location, direction: .backward),
        isWhitespace(object)
      {
        return .downstream
      }
      else {
        return .upstream
      }

    case .backward:
      if let object = self.crossedObjectAt(location, direction: .forward),
        isWhitespace(object)
      {
        return .upstream
      }
      else {
        return .downstream
      }

    default:
      assertionFailure("Invalid direction")
      return .downstream
    }
  }

  /// Return the destination location for the given location and direction.
  ///
  /// - Parameters:
  ///   - location: The starting location.
  ///   - direction: The navigation direction.
  ///   - extending: Whether the navigation is extending.
  private func destinationLocationForChar(
    for location: AffineLocation,
    direction: TextSelectionNavigation.Direction,
    extending: Bool
  ) -> AffineLocation? {

    switch direction {
    case .forward, .backward:
      guard let target = TreeUtils.moveCaretLR(location.value, in: direction, rootNode)
      else { return nil }
      let affinity = resolveAffinityForMove(in: direction, target: target)
      return AffineLocation(target, affinity)

    case .up, .down:
      guard
        let result = rootNode.rayshoot(
          from: ArraySlice(location.value.asArray), affinity: location.affinity,
          direction: direction, context: _getLayoutContext(), layoutOffset: 0)
      else { return nil }
      let position = result.position.with(yDelta: direction == .up ? -0.5 : 0.5)

      if extending {
        if position.y < 0 {
          return AffineLocation(documentRange.location, .downstream)
        }
        else {
          return resolveTextLocation(with: position)
        }
      }
      else {
        if position.y < 0 {
          return location  // unchanged
        }
        else {
          return resolveTextLocation(with: position)
        }
      }

    default:
      assertionFailure("Invalid direction")
      return nil
    }
  }

  private func destinationLocationForWord(
    for location: AffineLocation,
    direction: TextSelectionNavigation.Direction,
    extending: Bool
  ) -> AffineLocation? {
    let location = location.value

    guard direction == .forward || direction == .backward,
      var trace = Trace.from(location, rootNode),
      let last = trace.last,
      let textNode = last.node as? TextNode,
      let offset = last.index.index()
    else { return nil }

    if direction == .forward {
      let range = StringUtils.wordBoundaryRange(
        textNode.string, offset: offset, direction: .forward)
      if range.isEmpty {
        return nil
      }
      else {
        assert(range.lowerBound == offset)
        assert(range.upperBound <= textNode.string.length)
        trace.moveTo(.index(range.upperBound))

        guard let target = trace.toRawLocation() else { return nil }
        let affinity = resolveAffinityForMove(in: direction, target: target)
        return AffineLocation(target, affinity)
      }
    }
    else {
      let range = StringUtils.wordBoundaryRange(
        textNode.string, offset: offset, direction: .backward)
      if range.isEmpty {
        return nil
      }
      else {
        assert(range.upperBound == offset)
        assert(range.lowerBound >= 0)
        trace.moveTo(.index(range.lowerBound))

        guard let target = trace.toRawLocation() else { return nil }
        let affinity = resolveAffinityForMove(in: direction, target: target)
        return AffineLocation(target, affinity)
      }
    }
  }

  /// Return the text range enclosing the given location for the given granularity.
  /// - Warning: Currently only `.word` granularity is supported.
  internal func enclosingTextRange(
    for granularity: TextSelectionNavigation.Destination, _ location: TextLocation
  ) -> RhTextRange? {
    precondition(granularity == .word)

    guard var trace = Trace.from(location, rootNode),
      let last = trace.last,
      let textNode = last.node as? TextNode,
      let offset = last.index.index()
    else { return nil }

    let range = StringUtils.wordBoundaryRange(textNode.string, enclosing: offset)

    // location
    trace.moveTo(.index(range.lowerBound))
    guard let location = trace.toRawLocation() else { return nil }

    // end location and range
    trace.moveTo(.index(range.upperBound))
    guard let endLocation = trace.toRawLocation(),
      let destination = RhTextRange(location, endLocation)
    else { return nil }

    return destination
  }

  internal func repairTextRange(_ range: RhTextRange) -> RepairResult<RhTextRange> {
    TreeUtils.repairRange(range, rootNode)
  }

  // MARK: - IME Support

  /// Move `location` by `offset` layout units.
  internal func location(
    _ location: TextLocation, llOffsetBy offset: Int
  ) -> TextLocation? {
    guard offset >= 0,
      let trace = Trace.from(location, rootNode),
      let last = trace.last,
      let textNode = last.node as? TextNode
    else { return nil }
    // get start layout offset
    guard let startOffset = textNode.getLayoutOffset(last.index) else { return nil }
    // get new layout offset and newIndex
    let newOffset = startOffset + offset
    guard let newIndex = textNode.getIndex(newOffset) else { return nil }
    // get new location
    return TextLocation(location.indices, newIndex)
  }

  /// Return the attributed substring if the range is into a text node.
  internal func attributedSubstring(for textRange: RhTextRange) -> NSAttributedString? {
    guard let trace = Trace.from(textRange.location, rootNode),
      let endTrace = Trace.from(textRange.endLocation, rootNode),
      let last = trace.last,
      let endLast = endTrace.last,
      let textNode = last.node as? TextNode,
      textNode === endLast.node,
      let startOffset = last.index.index(),
      let endOffset = endLast.index.index()
    else { return nil }
    return textNode.attributedSubstring(for: startOffset..<endOffset, styleSheet)
  }

  /// Return layout offset from `location` to `endLocation` for the same text node.
  internal func llOffset(
    from location: TextLocation, to endLocation: TextLocation
  ) -> Int? {
    guard let trace = Trace.from(location, rootNode),
      let endTrace = Trace.from(endLocation, rootNode),
      let last = trace.last,
      let endLast = endTrace.last,
      let textNode = last.node as? TextNode,
      textNode === endLast.node
    else { return nil }
    guard let startOffset = textNode.getLayoutOffset(last.index),
      let endOffset = textNode.getLayoutOffset(endLast.index)
    else { return nil }
    // get offset
    return endOffset - startOffset
  }

  // MARK: - Replacement Support

  /// Returns a substring before the given location with at most the given
  /// extended-character count.
  /// - Returns: The substring and its range if successful; otherwise, nil.
  /// - Precondition: `location` points to a text node.
  internal func prefixString(from location: TextLocation, count: Int) -> ExtendedString? {
    precondition(count >= 0)

    // trivial case
    if count == 0 { return ExtendedString() }

    // obtain string prefix
    guard let trace = Trace.from(location, rootNode),
      let last = trace.last,
      let textNode = last.node as? TextNode,
      let offset = last.index.index(),
      let prefix = textNode.substring(before: offset, charCount: count)
    else { return nil }

    let secondLast = trace[trace.count - 2]

    // check if we can extend the prefix
    guard prefix.count < count,
      let container = secondLast.node as? GenElementNode,
      var index = secondLast.index.index()
    else { return ExtendedString(prefix) }

    var further = Deque<ExtendedChar>()
    var remaining = count - prefix.count

    while remaining > 0 && index > 0 {
      index -= 1
      let child = container.getChild(index)

      switch child {
      case let node as TextNode:
        let string = node.string
        if string.count < remaining {
          further.prepend(contentsOf: string.map { ExtendedChar.char($0) })
          remaining -= string.count
        }
        else {
          let segment = string.suffix(remaining).map { ExtendedChar.char($0) }
          further.prepend(contentsOf: segment)
          remaining = 0  // break out
        }

      case let node as NamedSymbolNode:
        further.prepend(.symbol(node.namedSymbol))
        remaining -= 1

      default:
        remaining = 0  // break out
      }
    }

    return further + ExtendedString(prefix)
  }

  /// Trace backward to the beginning of the prefix from the given location.
  /// - Parameters:
  ///   - location: The starting location.
  ///   - prefixReversed: The prefix to trace, given in **reverse** order.
  /// - Precondition: `location` points to a text node.
  internal func traceBackward(
    from location: TextLocation, _ prefixReversed: ExtendedSubstring
  ) -> TextLocation? {
    guard var trace = Trace.from(location, rootNode),
      let last = trace.last,
      let textNode = last.node as? TextNode,
      let textOffset = last.index.index()
    else { return nil }

    let secondLast = trace[trace.count - 2]
    guard let container = secondLast.node as? GenElementNode,
      var index = secondLast.index.index()
    else { return nil }

    enum State {
      case textNode(node: TextNode, offset: Int)
      case namedSymbol(node: NamedSymbolNode)
    }

    var state: State = .textNode(node: textNode, offset: textOffset)

    for char in prefixReversed {
      switch char {
      case let .char(c):
        switch state {
        case .textNode(let node, let offset):
          guard offset >= c.length else { return nil }
          let newOffset = offset - c.length
          state = .textNode(node: node, offset: newOffset)

        case .namedSymbol:
          index -= 1
          guard index >= 0,
            let textNode = container.getChild(index) as? TextNode,
            textNode.string.length >= c.length
          else { return nil }
          let newOffset = textNode.string.length - c.length
          state = .textNode(node: textNode, offset: newOffset)
        }

      case let .symbol(symbol):
        switch state {
        case .textNode(_, let offset):
          guard offset == 0 else { return nil }
        case .namedSymbol:
          break
        }
        index -= 1
        guard index >= 0,
          let child = container.getChild(index) as? NamedSymbolNode,
          child.namedSymbol == symbol
        else { return nil }
        state = .namedSymbol(node: child)
      }
    }

    switch state {
    case .textNode(let node, let offset):
      trace.truncate(to: trace.count - 2)
      // CAUTION: Don't use `container` here, as it may not be the same as `secondLast.node`.
      trace.emplaceBack(secondLast.node, .index(index))
      trace.emplaceBack(node, .index(offset))

    case .namedSymbol:
      trace.truncate(to: trace.count - 2)
      // CAUTION: Don't use `container` here, as it may not be the same as `secondLast.node`.
      trace.emplaceBack(secondLast.node, .index(index))
    }

    // return the location
    return trace.toRawLocation()
  }

  // MARK: - Location Query

  /// Returns the node located at the given path.
  internal func getNode(at path: Array<RohanIndex>) -> Node? {
    TreeUtils.getNode(at: path, rootNode)
  }

  /// Returns the node located at the given location.
  internal func getNode(at location: TextLocation) -> Node? {
    TreeUtils.getNode(at: location, rootNode)
  }

  /// Return the object (character/non-text node) covered by the range formed
  /// by the given location and the next location obtained by moving in the
  /// given direction.
  /// - Returns: The object and the location of its downstream edge if successful;
  ///     otherwise, nil.
  internal func crossedObjectAt(
    _ location: TextLocation, direction: LinearDirection
  ) -> CrossedObject? {
    guard var trace = Trace.from(location, rootNode) else {
      assertionFailure("Invalid location")
      return nil
    }

    if direction == .forward {
      while true {
        guard let last = trace.last,
          let offset = last.index.index()
        else {
          assertionFailure("Invalid location")
          return nil
        }
        let node = last.node

        switch node {
        case let node as TextNode:
          if let nextOffset = node.destinationOffset(for: offset, cOffsetBy: 1) {
            let string = node.substring(for: offset..<nextOffset)
            trace.moveTo(.index(nextOffset))
            return .text(String(string), trace.toRawLocation()!)
          }
          else {
            trace.truncate(to: trace.count - 1)
            guard let index = trace.last?.index.index() else {
              assertionFailure("Invalid location")
              return nil
            }
            trace.moveTo(.index(index + 1))
            continue
          }

        case let node as GenElementNode:
          assert(isElementNode(node) || isArgumentNode(node))
          if node.childCount == 0 {
            return nil
          }
          else if offset < node.childCount {
            let child = node.getChild(offset)
            if let textNode = child as? TextNode {
              trace.emplaceBack(textNode, .index(0))
              continue
            }
            else {
              trace.moveTo(.index(offset + 1))
              return .nonTextNode(child, trace.toRawLocation()!)
            }
          }
          else {
            if node.layoutType.mayEmitBlock {
              return .blockBoundary
            }
            else {
              return nil
            }
          }

        default:
          return nil
        }
      }
    }

    assert(direction == .backward)

    while true {
      guard let last = trace.last,
        let offset = last.index.index()
      else {
        assertionFailure("Invalid location")
        return nil
      }
      let node = last.node

      switch node {
      case let node as TextNode:
        if let prevOffset = node.destinationOffset(for: offset, cOffsetBy: -1) {
          let string = node.substring(for: prevOffset..<offset)
          trace.moveTo(.index(prevOffset))
          return .text(String(string), trace.toRawLocation()!)
        }
        else {
          trace.truncate(to: trace.count - 1)
          continue
        }

      case let node as GenElementNode:
        assert(isElementNode(node) || isArgumentNode(node))
        if offset > 0 {
          let child = node.getChild(offset - 1)
          if let textNode = child as? TextNode {
            trace.emplaceBack(textNode, .index(textNode.length))
            continue
          }
          else if child.layoutType.mayEmitBlock {
            return .blockBoundary
          }
          else {
            trace.moveTo(.index(offset - 1))
            return .nonTextNode(child, trace.toRawLocation()!)
          }
        }
        else {
          // for offset == 0 and node is block, blockBoundary is a safe default.
          if node.layoutType.mayEmitBlock {
            return .blockBoundary
          }
          else {
            return nil
          }
        }

      default:
        return nil
      }
    }
  }

  /// Descend from the given location to the node at the given index which is
  /// either a `MathIndex` or a `GridIndex`. In both cases, the returned location
  /// must be at the end of the node at the index.
  /// - Parameters:
  ///   - location: The starting location.
  ///   - index: The index to descend to.
  /// - Returns: The valid insertion point if successful; otherwise, nil.
  internal func descendTo(
    _ location: TextLocation, _ index: Either<MathIndex, GridIndex>
  ) -> TextLocation? {
    switch index {
    case .Left(let mathIndex):
      var indices = location.indices
      indices.append(.index(location.offset))
      indices.append(.mathIndex(mathIndex))
      guard let node = self.getNode(at: indices),
        let node = node as? ContentNode
      else { return nil }
      let newLocation = TextLocation(indices, node.childCount)
      return newLocation.normalised(for: rootNode)

    case .Right(let gridIndex):
      var indices = location.indices
      indices.append(.index(location.offset))
      indices.append(.gridIndex(gridIndex))
      guard let node = self.getNode(at: indices),
        let node = node as? ContentNode
      else { return nil }
      let newLocation = TextLocation(indices, node.childCount)
      return newLocation.normalised(for: rootNode)
    }
  }

  /// Determine the __contextual node__ the location is in.
  ///
  /// A **contextual node** is the lowest ancestor node that emits a command.
  /// According to this definition, text nodes and content nodes are skipped.
  ///
  /// - Returns: The contextual node, its location, and its associated index for
  ///     accessing the next-level node if successful; otherwise, nil.
  internal func contextualNode(
    for location: TextLocation
  ) -> (node: Node, location: TextLocation, index: RohanIndex)? {
    guard var trace = Trace.from(location, rootNode) else { return nil }

    var contextual: Node?
    var childIndex: RohanIndex?
    while trace.isEmpty == false {
      let last = trace.last!
      let node = last.node
      if isTextNode(node) || isContentNode(node) {
        trace.truncate(to: trace.count - 1)
      }
      else {
        contextual = node
        childIndex = last.index
        trace.truncate(to: trace.count - 1)
        break
      }
    }

    guard let contextual = contextual,
      let childIndex = childIndex,
      let target = trace.toRawLocation()
    else { return nil }
    return (contextual, target, childIndex)
  }

  /// Compute the visual delimiter range for a location in the tree and also
  /// the nested level of the node that needs visual delimiter.
  internal func visualDelimiterRange(
    for location: TextLocation
  ) -> (RhTextRange, level: Int)? {
    TreeUtils.visualDelimiterRange(for: location, rootNode, styleSheet)
  }

  // MARK: - Storage

  func exportDocument(to format: DocumentContent.OutputFormat) -> Data? {
    content.writeData(format: format)
  }

  func getLatexContent() -> String? {
    let context = DeparseContext(Rohan.latexRegistry)
    return NodeUtils.getLatexContent(rootNode, context: context)
  }

  func getLatexContent(for range: RhTextRange) -> String? {
    guard let nodes: Array<PartialNode> = mapContents(in: range, { $0 }),
      let parent = _lowestGenElementAncestor(for: range),
      let layoutMode = containerProperty(for: range.location)?.containerMode.layoutMode()
    else { return nil }

    let deparseContext = DeparseContext(Rohan.latexRegistry)

    switch parent {
    case let .Left(element):
      return NodeUtils.getLatexContent(
        as: element, withChildren: nodes, mode: layoutMode, context: deparseContext)
    case let .Right(argument):
      return NodeUtils.getLatexContent(
        as: argument, withChildren: nodes, mode: layoutMode, context: deparseContext)
    }
  }

  /// Returns the lowest ancestor node for the given range that is either an
  /// `ElementNode` or an `ArgumentNode`, which conforms to the `GenElementNode`
  /// protocol.
  private func _lowestGenElementAncestor(
    for range: RhTextRange
  ) -> Either<ElementNode, ArgumentNode>? {
    guard let trace = Trace.from(range.location, rootNode),
      let endTrace = Trace.from(range.endLocation, rootNode)
    else { return nil }

    let minCount = min(trace.count, endTrace.count)
    assert(minCount > 0)
    for i in (0..<minCount).reversed() {
      if trace[i].node !== endTrace[i].node {
        continue
      }
      if let element = trace[i].node as? ElementNode {
        return .Left(element)
      }
      else if let argument = trace[i].node as? ArgumentNode {
        return .Right(argument)
      }
    }
    return nil
  }

  // MARK: - Debug Facility

  func prettyPrint() -> String { rootNode.prettyPrint() }

  func debugPrint() -> String { rootNode.debugPrint() }
}
