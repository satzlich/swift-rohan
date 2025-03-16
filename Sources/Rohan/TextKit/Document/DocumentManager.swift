// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

public final class DocumentManager {
  public typealias SegmentType = NSTextLayoutManager.SegmentType
  public typealias SegmentOptions = NSTextLayoutManager.SegmentOptions
  typealias EnumerateContentsBlock = (RhTextRange?, PartialNode) -> Bool
  public typealias EnumerateTextSegmentsBlock = (RhTextRange?, CGRect, CGFloat) -> Bool

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

    // set up base content storage and layout manager
    textContentStorage.addTextLayoutManager(textLayoutManager)
    textContentStorage.primaryTextLayoutManager = textLayoutManager
  }

  convenience public init(_ styleSheet: StyleSheet) {
    self.init(styleSheet, RootNode())
  }

  // MARK: - Properties of base layout manager

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

  public func replaceContents(in range: RhTextRange, with nodes: [Node]?) throws {
    // TODO: implement

    if range.isEmpty {
      guard let nodes else { return }
      rootNode.insertChildren(contentsOf: nodes, at: rootNode.childCount, inStorage: true)
    }
    else {
      let result = removeContents(in: range)
      guard let insertionPoint = result.success() else { return }
      guard let nodes else { return }
      rootNode.insertChildren(contentsOf: nodes, at: rootNode.childCount, inStorage: true)
    }
  }

  /**
   Replace contents in `range` with `string`.
   - Returns: the new insertion point if the operation is successful;
      otherwise, SatzError(.InvalidRootChild), SatzError(.InvalidTextLocation), or
      SatzError(.InvalidTextRange)
   - Precondition: `string` is free of newlines (except line separators `\u{2028}`)
   - Postcondition: If `string` non-empty, the new insertion point is guaranteed
      to be at the start of `string`.
   */
  @discardableResult
  func replaceCharacters(
    in range: RhTextRange, with string: String
  ) -> SatzResult<InsertionPoint> {
    precondition(TextNode.validate(string: string))

    do {
      if range.isEmpty {
        let location = try NodeUtils.insertString(string, at: range.location, rootNode)
        let insertionPoint =
          location == nil
          ? InsertionPoint(range.location, isSame: true)
          : InsertionPoint(location!, isSame: false)
        return .success(insertionPoint)
      }

      // remove first
      let result = removeContents(in: range)
      guard let insertionPoint = result.success() else { return result }
      // do insertion
      let newLocation = try NodeUtils.insertString(
        string, at: insertionPoint.location, rootNode)
      let newInsertionPoint =
        newLocation == nil
        ? insertionPoint
        : InsertionPoint(newLocation!, isSame: false)
      return .success(newInsertionPoint)
    }
    catch let error as SatzError {
      return .failure(error)
    }
    catch {
      return .failure(SatzError(.GenericInternalError))
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
    do {
      let location = try NodeUtils.removeTextRange(range, rootNode)
      if let location {
        return .success(InsertionPoint(location, isSame: false))
      }
      else {
        return .success(InsertionPoint(range.location, isSame: true))
      }
    }
    catch let error as SatzError {
      return .failure(error)
    }
    catch {
      return .failure(SatzError(.GenericInternalError))
    }
  }

  /**
   Insert a paragraph break at given `range`.
   - Returns: when successful, the new insertion point and a boolean indicating
      whether the insertion is performed. Otherwise, a SatzError.
   */
  func insertParagraphBreak(
    at range: RhTextRange
  ) -> SatzResult<(InsertionPoint, inserted: Bool)> {
    if range.isEmpty {
      let newLocation = NodeUtils.insertParagraphBreak(at: range.location, rootNode)
      if let newLocation {  // inserted
        return .success((InsertionPoint(newLocation, isSame: false), true))
      }
      else {  // no insertion
        return .success((InsertionPoint(range.location, isSame: true), false))
      }
    }
    assert(!range.isEmpty)
    let result = removeContents(in: range)
    guard let insertionPoint = result.success() else {
      return .failure(result.failure()!)
    }

    if !insertionPoint.isSame {  // insertion point is not at range.location
      let newLocation = NodeUtils.insertParagraphBreak(
        at: insertionPoint.location, rootNode)
      if let newLocation {  // inserted
        return .success((InsertionPoint(newLocation, isSame: false), true))
      }
      else {  // no insertion
        return .success((InsertionPoint(insertionPoint.location, isSame: false), false))
      }
    }
    else {  // insertion point is at range.location
      let newLocation = NodeUtils.insertParagraphBreak(at: range.location, rootNode)
      if let newLocation {  // inserted
        return .success((InsertionPoint(newLocation, isSame: false), true))
      }
      else {  // no insertion
        return .success((InsertionPoint(range.location, isSame: true), false))
      }
    }
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

  /**
   Normalize the given location.

   - Returns: The normalized location if the given location is valid; nil otherwise.
   - Note: See ``NodeUtils.buildLocation(from:)`` for definition of __normalized__.
   */
  private func normalizeLocation(_ location: TextLocation) -> TextLocation? {
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
