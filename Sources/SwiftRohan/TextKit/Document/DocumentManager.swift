// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import _RopeModule

public final class DocumentManager {
  public typealias SegmentType = NSTextLayoutManager.SegmentType
  public typealias SegmentOptions = NSTextLayoutManager.SegmentOptions
  typealias EnumerateContentsBlock = (RhTextRange?, PartialNode) -> Bool
  public typealias EnumerateTextSegmentsBlock = (RhTextRange?, CGRect, CGFloat) -> Bool

  /// The root node of the document
  private let content: DocumentContent
  private var rootNode: RootNode { @inline(__always) get { content.rootNode } }

  /// The style sheet for the document
  public var styleSheet: StyleSheet {
    didSet {
      // reset style cache
      rootNode.resetCachedProperties(recursive: true)

      // clear text content storage
      textContentStorage.performEditingTransaction {
        let documentRange = textContentStorage.documentRange
        textContentStorage.replaceContents(in: documentRange, with: nil)
      }
      assert(textContentStorage.documentRange.isEmpty)
    }
  }

  /// base text content storage
  private(set) var textContentStorage: NSTextContentStorage
  /// base text layout manager
  private(set) var textLayoutManager: NSTextLayoutManager

  var textSelection: RhTextSelection? {
    didSet {
      #if LOG_TEXT_SELECTION
      let string = textSelection?.debugDescription ?? "no selection"
      Rohan.logger.debug("\(string)")
      #endif
    }
  }

  private(set) lazy var textSelectionNavigation: TextSelectionNavigation = .init(self)

  convenience init(_ rootNode: RootNode, _ styleSheet: StyleSheet) {
    self.init(content: DocumentContent(rootNode), styleSheet)
  }

  public init(content: DocumentContent = .init(), _ styleSheet: StyleSheet) {
    self.content = content
    self.styleSheet = styleSheet

    self.textContentStorage = NSTextContentStoragePatched()
    self.textLayoutManager = NSTextLayoutManager()
    self.textSelection = nil

    // set up base content storage and layout manager
    textContentStorage.addTextLayoutManager(textLayoutManager)
    textContentStorage.primaryTextLayoutManager = textLayoutManager
  }

  // MARK: - Properties of base layout manager

  internal var textContainer: NSTextContainer? {
    get { textLayoutManager.textContainer }
    _modify { yield &textLayoutManager.textContainer }
  }

  internal var usageBounds: CGRect { textLayoutManager.usageBoundsForTextContainer }

  internal var textViewportLayoutController: NSTextViewportLayoutController {
    textLayoutManager.textViewportLayoutController
  }

  // MARK: - Query

  public var documentRange: RhTextRange {
    let location = TextLocation([], 0).normalized(for: rootNode)!
    let endLocation = TextLocation([], rootNode.childCount).normalized(for: rootNode)!
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
  internal func mapContents<T>(in range: RhTextRange, _ f: (PartialNode) -> T) -> [T]? {
    var values: [T] = []
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

  /// Returns category of content container where location is in.
  internal func containerCategory(for location: TextLocation) -> ContainerCategory? {
    TreeUtils.containerCategory(for: location, rootNode)
  }

  // MARK: - Editing

  /// Replace contents in range with nodes.
  /// - Returns: the range of inserted contents if successful; otherwise, an error.
  public func replaceContents(
    in range: RhTextRange, with nodes: [Node]?
  ) -> SatzResult<RhTextRange> {
    // just remove contents if nodes is nil or empty
    if nodes == nil || nodes!.isEmpty {
      return _deleteContents(in: range)
        .map { self._normalizeRange($0) }
    }
    // forward to replaceCharacters() if nodes is a single text node
    if let textNode = nodes?.getOnlyTextNode() {
      return replaceCharacters(in: range, with: textNode.string)
    }

    let nodes = nodes!

    // validate insertion
    guard let (content, _) = _validateInsertOperation(nodes, at: range.location)
    else { return .failure(SatzError(.InsertOperationRejected)) }

    // remove contents in range and set insertion point
    let location: TextLocation
    if range.isEmpty {
      location = range.location
    }
    else {
      let result0 = _deleteContents(in: range)
      guard let location_ = result0.success()?.location
      else { return .failure(result0.failure()!) }
      location = location_
    }

    // insert nodes
    let result1: SatzResult<RhTextRange>
    switch content {
    case .plaintext:
      assertionFailure("Unreachable")
      return .failure(SatzError(.UnreachableCodePath))

    case .inlineContent, .containsBlock, .mathListContent:
      result1 = TreeUtils.insertInlineContent(nodes, at: location, rootNode)

    case .paragraphNodes, .topLevelNodes:
      result1 = TreeUtils.insertParagraphNodes(nodes, at: location, rootNode)

    }
    return result1.map { self._normalizeRange($0) }
  }

  /// Returns content and container category if the given nodes can be inserted at the
  /// given location. Otherwise, returns nil.
  private func _validateInsertOperation(
    _ nodes: [Node], at location: TextLocation
  ) -> (ContentCategory, ContainerCategory)? {
    guard let container = TreeUtils.containerCategory(for: location, rootNode),
      let content = TreeUtils.contentCategory(of: nodes),
      content.isCompatible(with: container)
    else { return nil }
    return (content, container)
  }

  /// Replace characters in range with string.
  /// - Returns: the range of inserted contents if successful; otherwise, an error.
  /// - Precondition: `string` is free of newlines except line separators `\u{2028}`
  /// - Postcondition: If `string` is non-empty, the returned range is within a
  ///     single text node.
  internal func replaceCharacters(
    in range: RhTextRange, with string: BigString
  ) -> SatzResult<RhTextRange> {
    precondition(TextNode.validate(string: string))
    // just remove contents if string is empty
    if string.isEmpty {
      return _deleteContents(in: range)
        .map { self._normalizeRange($0) }
    }
    // remove range
    let location: TextLocation
    if range.isEmpty {
      location = range.location
    }
    else {
      let result = _deleteContents(in: range)
      guard let location_ = result.success()?.location
      else { return .failure(result.failure()!) }
      location = location_
    }
    // perform insertion
    return TreeUtils.insertString(string, at: location, rootNode)
      .map { self._normalizeRange($0) }
  }

  /// Returns the nodes that should be inserted if the user presses the return key.
  func resolveInsertParagraphBreak(at range: RhTextRange) -> [Node] {
    func paragraphs(_ n: Int = 2) -> [ParagraphNode] {
      (0..<n).map { _ in ParagraphNode() }
    }

    guard range.isEmpty else { return paragraphs() }

    let location = range.location
    guard let trace = Trace.from(location, rootNode)
    else { return paragraphs() }

    let node = trace.last!.node
    let index = trace.last!.index

    if let node = node as? ElementNode,
      node.isParagraphContainer,
      let index = index.index()
    {
      if node.childCount == 0
        || (index < node.childCount && node.getChild(index).isTransparent)
      {
        return paragraphs()
      }
      else {
        return paragraphs(1)
      }
    }
    else {
      return paragraphs()
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
    textContentStorage.performEditingTransaction {
      let fromScratch = textContentStorage.documentRange.isEmpty
      guard rootNode.isDirty || fromScratch else { return }
      rootNode.performLayout(layoutContext, fromScratch: fromScratch)
    }
    layoutContext.endEditing()
    assert(rootNode.isDirty == false)
    assert(rootNode.layoutLength() == textContentStorage.textStorage!.length)
  }

  /// Synchronize text layout with text content storage.
  public final func ensureLayout(viewportOnly: Bool) {
    precondition(rootNode.isDirty == false)
    // ensure layout synchronization
    let documentRange = textContentStorage.documentRange
    let layoutRange: NSTextRange =
      viewportOnly ? NSTextRange(location: documentRange.endLocation) : documentRange
    textLayoutManager.ensureLayout(for: layoutRange)
  }

  /// Synchronize text layout and text content storage with current document.
  public final func reconcileLayout(viewportOnly: Bool) {
    // ensure content storage synchronization
    reconcileContentStorage()
    // ensure layout synchronization
    ensureLayout(viewportOnly: viewportOnly)
  }

  /// Enumerate text segments in the given range.
  /// - Note: `block` should return `false` to break out of enumeration.
  public func enumerateTextSegments(
    in textRange: RhTextRange, type: SegmentType, options: SegmentOptions = [],
    // (textSegmentRange, textSegmentFrame, baselinePosition) -> continue
    using block: EnumerateTextSegmentsBlock
  ) {
    let path = textRange.location.asPath
    let endPath = textRange.endLocation.asPath
    _ = rootNode.enumerateTextSegments(
      ArraySlice(path), ArraySlice(endPath),
      _getLayoutContext(), layoutOffset: 0, originCorrection: .zero,
      type: type, options: options, using: block)
  }

  /// Resolve the text location for the given point.
  /// - Returns: The resolved text location if successful; otherwise, nil.
  internal func resolveTextLocation(with point: CGPoint) -> TextLocation? {
    #if LOG_PICKING_POINT
    Rohan.logger.debug("Interacting at \(point.debugDescription)")
    #endif

    let context = _getLayoutContext()
    var trace = Trace()

    let modified = rootNode.resolveTextLocation(with: point, context, &trace)
    return modified ? trace.toTextLocation() : nil
  }

  // MARK: - Navigation

  /// Return the destination location for the given location and direction.
  ///
  /// - Parameters:
  ///   - location: The starting location.
  ///   - direction: The navigation direction.
  ///   - extending: Whether the navigation is extending.
  internal func destinationLocation(
    for location: TextLocation,
    _ direction: TextSelectionNavigation.Direction,
    extending: Bool
  ) -> TextLocation? {
    switch direction {
    case .forward, .backward:
      return TreeUtils.moveCaretLR(location, in: direction, rootNode)

    case .up, .down:
      let result = rootNode.rayshoot(
        from: ArraySlice(location.asPath), direction, _getLayoutContext(),
        layoutOffset: 0)
      guard let result else { return nil }
      let position = result.position.with(yDelta: direction == .up ? -0.5 : 0.5)

      if extending {
        if position.y < 0 {
          return documentRange.location
        }
        else if position.y > usageBounds.height {
          return documentRange.endLocation
        }
        // FALL THROUGH
      }
      else {
        if position.y < 0 || position.y > usageBounds.height {
          return location
        }
        // FALL THROUGH
      }
      return resolveTextLocation(with: position)

    default:
      assertionFailure("Invalid direction")
      return nil
    }
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
    // get start layout offset
    guard let startOffset = textNode.getLayoutOffset(last.index) else { return nil }
    // get end layout offset
    guard let endOffset = textNode.getLayoutOffset(endLast.index) else { return nil }
    // get offset
    return endOffset - startOffset
  }

  // MARK: - Location Utility

  /// Normalize the given range or return the fallback range.
  private func _normalizeRange(_ range: RhTextRange) -> RhTextRange {
    if let normalized = range.normalized(for: rootNode) {
      return normalized
    }
    else {
      // It is a programming error if the range cannot be normalized.
      assertionFailure("Failed to normalize range")
      return range
    }
  }

  /// Compute the visual delimiter range for a location in the tree.
  func visualDelimiterRange(for location: TextLocation) -> RhTextRange? {
    TreeUtils.visualDelimiterRange(for: location, rootNode)
  }

  // MARK: - Debug Facility

  func prettyPrint() -> String { rootNode.prettyPrint() }
  func debugPrint() -> String { rootNode.debugPrint() }
}
