// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

public final class DocumentManager {
  /** style sheet */
  private let styleSheet: StyleSheet
  /** root of the document */
  private let rootNode: RootNode

  /** Base text content storage */
  private(set) var textContentStorage: NSTextContentStorage
  /** Base text layout manager */
  private(set) var textLayoutManager: NSTextLayoutManager

  var textSelections: [RhTextSelection]
  var textSelectionNavigation: TextSelectionNavigation { preconditionFailure() }

  init(_ styleSheet: StyleSheet, _ rootNode: RootNode) {
    self.styleSheet = styleSheet
    self.rootNode = rootNode

    self.textContentStorage = NSTextContentStoragePatched()
    self.textLayoutManager = NSTextLayoutManager()
    self.textSelections = []

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

  internal var usageBoundsForTextContainer: CGRect {
    @inline(__always) get { textLayoutManager.usageBoundsForTextContainer }
  }

  internal var textViewportLayoutController: NSTextViewportLayoutController {
    @inline(__always) get { textLayoutManager.textViewportLayoutController }
  }

  // MARK: - Editing

  private(set) var hasEditingTransaction: Bool = false

  public func performEditingTransaction(_ block: () throws -> Void) throws {
    hasEditingTransaction = true
    try block()
    hasEditingTransaction = false
    ensureLayout(delayed: true)
  }

  public func replaceContents(in range: RhTextRange, with nodes: [Node]?) throws {
    var location = range.location
    if !range.isEmpty {
      try removeContents(in: range)
        .map { location = $0 }
    }
    guard let nodes else { return }
    // TODO: implement
    rootNode.insertChildren(contentsOf: nodes, at: rootNode.childCount)
  }

  /**
   Replace contents in `range` with `string`. If an exception is thrown, the
   document is left unchanged.

   - Returns: new insertion point if it is not `range.location`; nil otherwise.
   - Precondition: `string` is free of newlines (except line separators `\u{2028}`)
   - Throws: SatzError(.InsaneRootChild), SatzError(.InvalidTextLocation),
      SatzError(.InvalidTextRange)
   */
  @discardableResult
  public func replaceContents(in range: RhTextRange, with string: String) throws -> TextLocation? {
    precondition(TextNode.validate(string: string))

    // remove range and assign new location
    var location = range.location
    if !range.isEmpty {
      try removeContents(in: range).map { location = $0 }
    }

    return try NodeUtils.insertString(string, at: location, rootNode)
  }

  /**
   Remove contents in `range`. If an exception is thrown, the document is left
   unchanged.

   - Returns: new insertion point if it is not `range.location`; nil otherwise.
   - Postcondition: `range.location` remains valid after removing contents in `range`,
   whether or not an exception is thrown.
   - Throws: SatzError(.InvalidTextRange)
   */
  private func removeContents(in range: RhTextRange) throws -> TextLocation? {
    guard NodeUtils.validateTextRange(range, rootNode)
    else { throw SatzError(.InvalidTextRange) }
    return try NodeUtils.removeTextRange(range, rootNode)
  }

  // MARK: - Query

  public var documentRange: RhTextRange {
    let location = TextLocation([], 0)
    let endLocation = TextLocation([], rootNode.childCount)
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
   Enumerate subnodes in `range`.

   Closure `block` should return `false` to stop enumeration.
   */
  internal func enumerateSubnodes(
    in range: RhTextRange,
    /* (subnode, subnodeRange) -> continue */
    using block: (Node?, RhTextRange) -> Bool
  ) -> TextLocation? {
    preconditionFailure()
  }

  // MARK: - Layout

  internal final func ensureLayout(delayed: Bool = false) {
    // create layout context
    let layoutContext = self.getLayoutContext()

    // perform layout
    layoutContext.beginEditing()
    textContentStorage.performEditingTransaction {
      let fromScratch = textContentStorage.documentRange.isEmpty
      rootNode.performLayout(layoutContext, fromScratch: fromScratch)
    }
    layoutContext.endEditing()
    assert(rootNode.isDirty == false)

    // ensure layout
    let layoutRange: NSTextRange =
      if delayed { NSTextRange(location: textContentStorage.documentRange.endLocation) }
      else { textContentStorage.documentRange }
    textLayoutManager.ensureLayout(for: layoutRange)
  }

  private final func getLayoutContext() -> TextLayoutContext {
    TextLayoutContext(styleSheet, textContentStorage, textLayoutManager)
  }

  /**
   Enumerate text layout fragments from the given location.

   - Note: `block` should return `false` to stop enumeration.
   */
  public func enumerateTextLayoutFragments(
    from location: TextLocation, using block: (NSTextLayoutFragment) -> Bool
  ) -> TextLocation? {
    preconditionFailure()
  }

  /**
   Enumerate text segments in the given range.

   - Note: `block` should return `false` to stop enumeration.
   */
  public func enumerateTextSegments(
    in textRange: RhTextRange,
    type: NSTextLayoutManager.SegmentType,
    options: NSTextLayoutManager.SegmentOptions = [],
    /* (textSegmentRange, textSegmentFrame, baselinePosition) -> continue */
    using block: (RhTextRange?, CGRect, CGFloat) -> Bool
  ) {
    guard textRange.isEmpty,
      type == .standard
//      options ~= .rangeNotRequired
    else { fatalError("TODO: implement") }
    // deal with (empty text range, standard, [rangeNotRequired]) first

    let location = textRange.location
    let path = location.path + [.index(location.offset)]
    guard let frame: CGRect = rootNode.getLayoutFrame(getLayoutContext(), path[...], 0)
    else { return }
    _ = block(textRange, frame, 0)
  }

  // MARK: - Debug Facility
  func prettyPrint() -> String { rootNode.prettyPrint() }
}
