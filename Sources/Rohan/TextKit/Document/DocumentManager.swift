// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import _RopeModule

public final class DocumentManager {
  public typealias SegmentType = NSTextLayoutManager.SegmentType
  public typealias SegmentOptions = NSTextLayoutManager.SegmentOptions
  typealias EnumerateContentsBlock = (RhTextRange?, PartialNode) -> Bool
  public typealias EnumerateTextSegmentsBlock = (RhTextRange?, CGRect, CGFloat) -> Bool

  /// The style sheet of the document.
  private let styleSheet: StyleSheet
  /// The root node of the document.
  private let rootNode: RootNode

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
  var textSelectionNavigation: TextSelectionNavigation { TextSelectionNavigation(self) }

  init(_ styleSheet: StyleSheet, _ rootNode: RootNode) {
    self.styleSheet = styleSheet
    self.rootNode = rootNode

    self.textContentStorage = NSTextContentStoragePatched()
    self.textLayoutManager = NSTextLayoutManager()
    self.textSelection = nil

    // set up base content storage and layout manager
    textContentStorage.addTextLayoutManager(textLayoutManager)
    textContentStorage.primaryTextLayoutManager = textLayoutManager
  }

  convenience public init(_ styleSheet: StyleSheet) {
    self.init(styleSheet, RootNode())
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
    let location = self.normalize(location: TextLocation([], 0))!
    let endLocation = self.normalize(location: TextLocation([], rootNode.childCount))!
    return RhTextRange(location, endLocation)!
  }

  /**
   Enumerate contents in `range`.

   - Note: Closure `block` should return `false` to stop enumeration.
   - Note: Partial nodes may become invalid after the enumeration when the
      document is edited.
   */
  internal func enumerateContents(
    in range: RhTextRange,
    /* (range?, partial node) -> continue */
    using block: EnumerateContentsBlock
  ) throws {
    try NodeUtils.enumerateContents(range, rootNode, using: block)
  }

  // MARK: - Editing

  private(set) var isEditing: Bool = false

  func beginEditing() {
    precondition(isEditing == false)
    isEditing = true
  }

  func endEditing() {
    precondition(isEditing == true)
    isEditing = false
    reconcileLayout(viewportOnly: true)
  }

  public func replaceContents(
    in range: RhTextRange, with nodes: [Node]?
  ) -> SatzResult<InsertionRange> {
    let result = self._replaceContents(in: range, with: nodes)
    let normalzed = result.map { range in
      guard let normalized = self.normalize(range: range) else {
        assertionFailure("Failed to normalize range")
        return range
      }
      return normalized
    }
    return normalzed
  }

  private func _replaceContents(
    in range: RhTextRange, with nodes: [Node]?
  ) -> SatzResult<InsertionRange> {
    // ensure nodes is not nil
    guard let nodes,
      !nodes.isEmpty
    else {
      // otherwise, remove contents in range
      if range.isEmpty {
        return .success(InsertionRange(range.location))
      }
      else {
        return removeContents(in: range).map { InsertionRange($0.location) }
      }
    }

    // validate insertion
    guard let (content, _) = validateInsertion(nodes, at: range.location)
    else { return .failure(SatzError(.ContentToInsertIsIncompatible)) }

    // remove contents in range if non-empty
    let insertionPoint: InsertionPoint
    if range.isEmpty {
      insertionPoint = InsertionPoint(range.location, isSame: true)
    }
    else {
      let result = removeContents(in: range)
      guard let p = result.success() else {
        return .failure(result.failure()!)
      }
      insertionPoint = p
    }

    switch content {
    case .plaintext:
      // if content is plaintext, forward to replaceCharacters(...)
      guard let textNode = nodes.first as? TextNode else {
        return .failure(SatzError(.InsertNodesFailure))
      }
      let insertionPoint = RhTextRange(insertionPoint.location)
      return replaceCharacters(in: insertionPoint, with: textNode.string)

    case .inlineContent, .containsBlock, .mathListContent:
      // insert into an element node
      return NodeUtils.insertInlineContent(nodes, at: insertionPoint.location, rootNode)

    case .paragraphNodes, .topLevelNodes:
      // insert into a container node
      return NodeUtils.insertParagraphNodes(nodes, at: insertionPoint.location, rootNode)
    }

    // Helper function

    /// Returns content and container category if the given nodes can be inserted at the
    /// given location. Otherwise, returns nil.
    func validateInsertion(
      _ nodes: [Node], at location: TextLocation
    ) -> (ContentCategory, ContentContainerCategory)? {
      // ensure container category can be obtained
      guard let container = NodeUtils.contentContainerCategory(for: location, rootNode)
      else { return nil }
      // ensure content category can be obtained
      guard let content = NodeUtils.contentCategory(of: nodes) else { return nil }
      // ensure compatibility
      guard NodeUtils.isCompatible(content: content, container) else { return nil }
      return (content, container)
    }
  }

  /**
   Replace contents in `range` with `string`.
   - Returns: the new insertion range if the operation is successful;
      otherwise, SatzError(.InvalidRootChild), SatzError(.InvalidTextLocation), or
      SatzError(.InvalidTextRange)
   - Precondition: `string` is free of newlines (except line separators `\u{2028}`)
   - Postcondition: If `string` non-empty, the new insertion point is guaranteed
      to be at the start of `string` within the TextNode contains it.
   */
  func replaceCharacters(
    in range: RhTextRange, with string: BigString
  ) -> SatzResult<InsertionRange> {
    let result = self._replaceCharacters(in: range, with: string)
    let normalzed = result.map { range in
      guard let normalized = self.normalize(range: range) else {
        assertionFailure("Failed to normalize range")
        return range
      }
      return normalized
    }
    return normalzed
  }

  private func _replaceCharacters(
    in range: RhTextRange, with string: BigString
  ) -> SatzResult<InsertionRange> {
    precondition(TextNode.validate(string: string))

    if range.isEmpty {
      guard !string.isEmpty else {
        return .success(InsertionRange(range.location))
      }
      return NodeUtils.insertString(string, at: range.location, rootNode)
    }

    // remove range
    let result = removeContents(in: range)
    guard let insertionPoint = result.success() else {
      return .failure(result.failure()!)
    }
    guard !string.isEmpty else {
      return .success(InsertionRange(insertionPoint.location))
    }
    // perform insertion
    return NodeUtils.insertString(string, at: insertionPoint.location, rootNode)
  }

  /**
   Insert a paragraph break at the given range.
   - Returns: when successful, the new insertion range; otherwise,
      SatzError(.InsertParagraphBreakFailure).
   */
  func insertParagraphBreak(at range: RhTextRange) -> SatzResult<InsertionRange> {
    let nodes = [ParagraphNode(), ParagraphNode()]
    let result = replaceContents(in: range, with: nodes)
    return result.mapError { error in
      error.code != .ContentToInsertIsIncompatible
        ? SatzError(.InsertParagraphBreakFailure)
        : error
    }
  }

  /**
   Remove contents in `range`. If unsuccessful, the document is left unchanged.
   - Returns: when successful, the new insertion point; otherwise,
      SatzError(.InvalidTextLocation), or SatzError(.InvalidTextRange).
   */
  private func removeContents(in range: RhTextRange) -> SatzResult<InsertionPoint> {
    guard NodeUtils.validateTextRange(range, rootNode)
    else { return .failure(SatzError(.InvalidTextRange)) }
    return NodeUtils.removeTextRange(range, rootNode)
  }

  // MARK: - Layout

  final func getLayoutContext() -> TextLayoutContext {
    TextLayoutContext(styleSheet, textContentStorage, textLayoutManager)
  }

  /// Synchronize text content storage with current document.
  public final func reconcileContentStorage() {
    // create layout context
    let layoutContext = self.getLayoutContext()

    // perform layout
    layoutContext.beginEditing()
    textContentStorage.performEditingTransaction {
      let fromScratch = textContentStorage.documentRange.isEmpty
      guard rootNode.isDirty || fromScratch else { return }
      rootNode.performLayout(layoutContext, fromScratch: fromScratch)
    }
    layoutContext.endEditing()
    assert(rootNode.isDirty == false)
    assert(rootNode.layoutLength == textContentStorage.textStorage!.length)
  }

  /// Synchronize text layout with text content storage __without__ reonciling
  /// content storage.
  public final func ensureLayout(viewportOnly: Bool) {
    precondition(rootNode.isDirty == false)
    // ensure layout synchronization
    let documentRange = textContentStorage.documentRange
    let layoutRange: NSTextRange =
      viewportOnly ? NSTextRange(location: documentRange.endLocation) : documentRange
    textLayoutManager.ensureLayout(for: layoutRange)
  }

  /// Synchronize text layout with current document.
  public final func reconcileLayout(viewportOnly: Bool) {
    // ensure content storage synchronization
    reconcileContentStorage()
    // ensure layout synchronization
    ensureLayout(viewportOnly: viewportOnly)
  }

  /// Enumerate text layout fragments from the given location.
  /// - Note: `block` should return `false` to stop enumeration.
  public func enumerateLayoutFragments(
    from location: TextLocation, using block: (LayoutFragment) -> Bool
  ) {
    preconditionFailure()
  }

  /// Enumerate text segments in the given range.
  /// - Note: `block` should return `false` to stop enumeration.
  public func enumerateTextSegments(
    in textRange: RhTextRange, type: SegmentType, options: SegmentOptions = [],
    /* (textSegmentRange, textSegmentFrame, baselinePosition) -> continue */
    using block: EnumerateTextSegmentsBlock
  ) {
    let path = textRange.location.asPath
    let endPath = textRange.endLocation.asPath
    _ = rootNode.enumerateTextSegments(
      ArraySlice(path), ArraySlice(endPath),
      getLayoutContext(), layoutOffset: 0, originCorrection: .zero,
      type: type, options: options, using: block)
  }

  internal func resolveTextLocation(interactingAt point: CGPoint) -> TextLocation? {
    #if LOG_PICKING_POINT
    Rohan.logger.debug("Interacting at \(point.debugDescription)")
    #endif

    let context = getLayoutContext()
    var trace: [TraceElement] = []
    let modified = rootNode.resolveTextLocation(interactingAt: point, context, &trace)
    guard modified else { return nil }
    return NodeUtils.buildLocation(from: trace)
  }

  // MARK: - Navigation

  /**
   Return the destination location for the given location and direction.

   - Parameters:
      - location: The starting location.
      - direction: The navigation direction.
      - extending: Whether the navigation is extending.
   */
  internal func destinationLocation(
    for location: TextLocation, _ direction: TextSelectionNavigation.Direction,
    extending: Bool
  ) -> TextLocation? {
    switch direction {
    case .forward, .backward:
      return NodeUtils.destinationLocation(for: location, direction, rootNode)

    case .up, .down:
      let result = rootNode.rayshoot(
        from: ArraySlice(location.asPath), direction, getLayoutContext(), layoutOffset: 0)
      // ignore result.isResolved (which is used in rayshoot for other purposes)
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
      return resolveTextLocation(interactingAt: position)

    default:
      assertionFailure("Invalid direction")
      return nil
    }
  }

  internal func repairTextRange(_ range: RhTextRange) -> RepairResult<RhTextRange> {
    NodeUtils.repairTextRange(range, rootNode)
  }

  // MARK: - IME Support

  /// Move `location` by `offset` layout units.
  internal func location(
    _ location: TextLocation, llOffsetBy offset: Int
  ) -> TextLocation? {
    guard offset >= 0,
      let trace = NodeUtils.buildTrace(for: location, rootNode),
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
    guard let trace = NodeUtils.buildTrace(for: textRange.location, rootNode),
      let endTrace = NodeUtils.buildTrace(for: textRange.endLocation, rootNode),
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
    guard let trace = NodeUtils.buildTrace(for: location, rootNode),
      let endTrace = NodeUtils.buildTrace(for: endLocation, rootNode),
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

  /// Normalize the given location.
  /// - Returns: The normalized location if the given location is valid; nil otherwise.
  /// - Note: See ``NodeUtils.buildLocation(from:)`` for definition of __normalized__.
  private func normalize(location: TextLocation) -> TextLocation? {
    guard let trace = NodeUtils.buildTrace(for: location, rootNode) else { return nil }
    return NodeUtils.buildLocation(from: trace)
  }

  /// Normalize the given range.
  /// - Returns: The normalized range if the given range is valid; nil otherwise.
  private func normalize(range: RhTextRange) -> RhTextRange? {
    if range.isEmpty {
      guard let location = normalize(location: range.location) else { return nil }
      return RhTextRange(location)
    }
    else {
      guard let location = normalize(location: range.location),
        let endLocation = normalize(location: range.endLocation)
      else { return nil }
      return RhTextRange(location, endLocation)
    }
  }

  // MARK: - Debug Facility

  func prettyPrint() -> String { rootNode.prettyPrint() }
  func debugPrint() -> String { rootNode.debugPrint() }
}
