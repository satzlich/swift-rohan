// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

public final class DocumentManager {
  public typealias SegmentType = NSTextLayoutManager.SegmentType
  public typealias SegmentOptions = NSTextLayoutManager.SegmentOptions

  /** style sheet */
  private let styleSheet: StyleSheet
  /** root of the document */
  private let rootNode: RootNode

  /** base text content storage */
  private(set) var textContentStorage: NSTextContentStorage
  /** base text layout manager */
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

    // setup base content storage and layout manager
    textContentStorage.addTextLayoutManager(textLayoutManager)
    textContentStorage.primaryTextLayoutManager = textLayoutManager
  }

  convenience public init(_ styleSheet: StyleSheet) {
    self.init(styleSheet, RootNode())
  }

  // MARK: - Properties of Base layout manager

  internal var textContainer: NSTextContainer? {
    @inline(__always) get { textLayoutManager.textContainer }
    @inline(__always) _modify { yield &textLayoutManager.textContainer }
  }

  internal var usageBounds: CGRect {
    @inline(__always) get { textLayoutManager.usageBoundsForTextContainer }
  }

  internal var textViewportLayoutController: NSTextViewportLayoutController {
    @inline(__always) get { textLayoutManager.textViewportLayoutController }
  }

  // MARK: - Query

  public var documentRange: RhTextRange {
    let location = self.normalizeLocation(TextLocation([], 0))!
    let endLocation = self.normalizeLocation(TextLocation([], rootNode.childCount))!
    return RhTextRange(location, endLocation)!
  }

  /**
   Enumerate nodes from `textLocation`.

   Closure `block` should return `false` to stop enumeration.
   */
  internal func enumerateNodes(
    from textLocation: TextLocation?,
    /* (node) -> continue */
    using block: (Node) -> Bool
  ) -> TextLocation? {
    preconditionFailure()
  }

  /**
   Enumerate contents in `range`.
   - Note: Closure `block` should return `false` to stop enumeration.
   */
  internal func enumerateContents(
    in range: RhTextRange,
    /* (range?, partial node) -> continue */
    using block: (RhTextRange?, PartialNode) -> Bool
  ) throws {
    try NodeUtils.enumerateContents(range, rootNode, using: block)
  }

  // MARK: - Editing

  private(set) var isEditing: Bool = false
  public func performEditingTransaction(_ block: () throws -> Void) rethrows {
    isEditing = true
    defer { isEditing = false }
    try block()
    reconcileLayout(viewportOnly: true)
  }

  public func replaceContents(in range: RhTextRange, with nodes: [Node]?) throws {
    var location = range.location
    if !range.isEmpty {
      try removeContents(in: range).map { location = $0 }
    }
    guard let nodes else { return }
    // TODO: implement
    rootNode.insertChildren(
      contentsOf: nodes, at: rootNode.childCount, inStorage: true)
  }

  /**
   Replace contents in `range` with `string`.
   - Returns: the new insertion point if it is not `range.location`; nil otherwise.
   - Precondition: `string` is free of newlines (except line separators `\u{2028}`)
   - Postcondition: If `string` non-empty, the new insertion point is guaranteed to be
    at the start of `string`.
   - Throws: SatzError(.InvalidRootChild), SatzError(.InvalidTextLocation),
      SatzError(.InvalidTextRange)
   */
  @discardableResult
  public func replaceCharacters(
    in range: RhTextRange, with string: String
  ) throws -> TextLocation? {
    precondition(TextNode.validate(string: string))
    if range.isEmpty {
      return try NodeUtils.insertString(string, at: range.location, rootNode)
    }
    else if let location = try removeContents(in: range) {
      return try NodeUtils.insertString(string, at: location, rootNode) ?? location
    }
    else {
      return try NodeUtils.insertString(string, at: range.location, rootNode)
    }
  }

  /**
   Remove contents in `range`. If an exception is thrown, the document is left unchanged.
   - Returns: new insertion point if it is not `range.location`; nil otherwise.
   - Throws: SatzError(.InvalidTextLocation), SatzError(.InvalidTextRange)
   */
  private func removeContents(in range: RhTextRange) throws -> TextLocation? {
    guard NodeUtils.validateTextRange(range, rootNode)
    else { throw SatzError(.InvalidTextRange) }
    return try NodeUtils.removeTextRange(range, rootNode)
  }

  /**
   Insert a paragraph break at given `range`.
   - Returns: new insertion point and whether a paragraph break is inserted.
   */
  public func insertParagraphBreak(
    at range: RhTextRange
  ) throws -> (TextLocation, inserted: Bool) {
    var location = range.location
    if !range.isEmpty {
      try removeContents(in: range)
        .map { location = $0 }
    }
    // insert paragraph break
    let newLocation = NodeUtils.insertParagraphBreak(at: location, rootNode)
    return (newLocation ?? location, newLocation != nil)
  }

  // MARK: - Layout

  /** Synchronize text content storage with current document. */
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

  /** Synchronize text layout with text content storage __without__ reonciling
   content storage. */
  public final func ensureLayout(viewportOnly: Bool) {
    precondition(rootNode.isDirty == false)
    // ensure layout synchronization
    let documentRange = textContentStorage.documentRange
    let layoutRange: NSTextRange =
      viewportOnly ? NSTextRange(location: documentRange.endLocation) : documentRange
    textLayoutManager.ensureLayout(for: layoutRange)
  }

  /** Synchronize text layout with current document */
  public final func reconcileLayout(viewportOnly: Bool) {
    // ensure content storage synchronization
    reconcileContentStorage()
    // ensure layout synchronization
    ensureLayout(viewportOnly: viewportOnly)
  }

  final func getLayoutContext() -> TextLayoutContext {
    TextLayoutContext(styleSheet, textContentStorage, textLayoutManager)
  }

  /**
   Enumerate text layout fragments from the given location.
   - Note: `block` should return `false` to stop enumeration.
   */
  public func enumerateLayoutFragments(
    from location: TextLocation, using block: (LayoutFragment) -> Bool
  ) {
    preconditionFailure()
  }

  /**
   Enumerate text segments in the given range.
   - Note: `block` should return `false` to stop enumeration.
   */
  public func enumerateTextSegments(
    in textRange: RhTextRange, type: SegmentType, options: SegmentOptions = [],
    /* (textSegmentRange, textSegmentFrame, baselinePosition) -> continue */
    using block: (RhTextRange?, CGRect, CGFloat) -> Bool
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

  internal func normalizeLocation(_ location: TextLocation) -> TextLocation? {
    guard let trace = NodeUtils.buildTrace(for: location, rootNode) else { return nil }
    return NodeUtils.buildLocation(from: trace)
  }

  internal func repairTextRange(_ range: RhTextRange) -> RepairResult<RhTextRange> {
    NodeUtils.repairTextRange(range, rootNode)
  }

  // MARK: - IME Support

  /** Move `location` by `offset` layout units. */
  internal func location(
    _ location: TextLocation, llOffsetBy offset: Int
  ) -> TextLocation? {
    guard offset >= 0,
      let trace = NodeUtils.buildTrace(for: location, rootNode),
      let last = trace.last,
      let textNode = last.node as? TextNode
    else { return nil }
    // get start layout offset
    guard let startOffset = textNode.getLayoutOffset(last.index)
    else { return nil }
    // get new layout offset and newIndex
    let newOffset = startOffset + offset
    guard let newIndex = textNode.getIndex(newOffset) else { return nil }
    // get new location
    return TextLocation(location.indices, newIndex)
  }

  /** Return the attributed substring if the range is into a text node */
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

  /** Return layout offset from `location` to `endLocation` for the same text node. */
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

  // MARK: - Debug Facility

  func prettyPrint() -> String { rootNode.prettyPrint() }
  func debugPrint() -> String { rootNode.debugPrint() }
}
