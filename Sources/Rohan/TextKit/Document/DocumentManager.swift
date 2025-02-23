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
      if DebugConfig.LOG_TEXT_SELECTION {
        let string = textSelection?.debugDescription ?? "nil"
        Rohan.logger.debug("TextSelection: \(string)")
      }
    }
  }
  var textSelectionNavigation: TextSelectionNavigation { .init(self) }

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
      try removeContents(in: range).map { location = $0 }
    }
    guard let nodes else { return }
    // TODO: implement
    rootNode.insertChildren(contentsOf: nodes, at: rootNode.childCount)
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
  public func replaceCharacters(in range: RhTextRange, with string: String) throws -> TextLocation?
  {
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
      guard rootNode.isDirty || fromScratch else { return }
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
      getLayoutContext(), path[...], endPath[...],
      layoutOffset: 0, originCorrection: .zero,
      type: type, options: options, using: block)
  }

  internal func getTextLocation(interactingAt point: CGPoint) -> TextLocation? {
    let context = getLayoutContext()
    var trace: [TraceElement] = []
    let modified = rootNode.getTextLocation(interactingAt: point, context, &trace)
    guard modified,
      let last = trace.popLast(),
      let offset = last.index.index()
    else { return nil }
    var path = trace.map(\.index)
    // fix last
    if let elementNode = last.node as? ElementNode {
      if offset < elementNode.childCount,
        elementNode.getChild(offset) is TextNode
      {
        path.append(.index(offset))
        return TextLocation(path, 0)
      }
      else if offset > 0,
        let textNode = elementNode.getChild(offset - 1) as? TextNode
      {
        path.append(.index(offset - 1))
        return TextLocation(path, textNode.stringLength)
      }
      // FALL THROUGH
    }
    return TextLocation(path, offset)
  }

  // MARK: - IME Support

  /** Move `location` by `offset` layout units. */
  internal func location(_ location: TextLocation, llOffsetBy offset: Int) -> TextLocation? {
    guard offset >= 0,
      let trace = NodeUtils.traceNodes(location, rootNode),
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
    guard let trace = NodeUtils.traceNodes(textRange.location, rootNode),
      let endTrace = NodeUtils.traceNodes(textRange.endLocation, rootNode),
      let last = trace.last,
      let endLast = endTrace.last,
      let textNode = last.node as? TextNode,
      textNode === endLast.node,
      let startOffset = last.index.index(),
      let endOffset = endLast.index.index()
    else { return nil }
    let substring = StringUtils.subString(textNode.bigString, startOffset..<endOffset)
    let attributes = (textNode.resolveProperties(styleSheet) as TextProperty).attributes()
    return NSAttributedString(string: substring, attributes: attributes)
  }

  /**
   Return layout offset from `location` to `endLocation` for the same text node.
   */
  internal func llOffset(from location: TextLocation, to endLocation: TextLocation) -> Int? {
    guard let trace = NodeUtils.traceNodes(location, rootNode),
      let endTrace = NodeUtils.traceNodes(endLocation, rootNode),
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
}
