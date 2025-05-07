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

  // MARK: - Editing

  internal func containerCategory(for location: TextLocation) -> ContainerCategory? {
    TreeUtils.containerCategory(for: location, rootNode)
  }

  internal func contentCategory(of nodes: [Node]) -> ContentCategory? {
    TreeUtils.contentCategory(of: nodes)
  }

  /// Replace contents in range with nodes.
  /// - Returns: the range of inserted contents if successful; otherwise, an error.
  public func replaceContents(
    in range: RhTextRange, with nodes: [Node]?
  ) -> SatzResult<RhTextRange> {
    // remove contents if nodes is nil or empty
    guard let nodes, !nodes.isEmpty
    else {
      return _deleteContents(in: range)
        .map { self._normalizeRange($0) }
    }

    // forward to replaceCharacters() if nodes is a single text node
    if let textNode = nodes.getOnlyTextNode() {
      return replaceCharacters(in: range, with: textNode.string)
    }

    // validate insertion
    guard let content = contentCategory(of: nodes),
      let container = containerCategory(for: range.location),
      content.isCompatible(with: container)
    else { return .failure(SatzError(.InsertOperationRejected)) }

    // remove contents in range and set insertion point
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

    // insert nodes
    let result: SatzResult<RhTextRange>
    switch content {
    case .plaintext, .textText, .mathText:
      assertionFailure("Unreachable")
      return .failure(SatzError(.UnreachableCodePath))

    case .inlineContent, .containsBlock, .mathContent:
      result = TreeUtils.insertInlineContent(nodes, at: location, rootNode)

    case .paragraphNodes, .topLevelNodes:
      result = TreeUtils.insertParagraphNodes(nodes, at: location, rootNode)
    }
    return result.map { self._normalizeRange($0) }
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

  /// Add a math component to the node/nodes at the given range.
  ///
  /// If the node at the location is a math node and the specified math component
  /// can be attached, the component is added to the math node. Otherwise, the
  /// range is replaced with a new math node with the specified component.
  /// - Returns: (range of resulting math node, isAdded) if successful;
  ///   otherwise, an error.
  internal func addMathComponent(
    _ range: RhTextRange, _ mathIndex: MathIndex, _ component: [Node]
  ) -> SatzResult<(RhTextRange, isAdded: Bool)> {

    let location = range.location
    let end = range.endLocation

    if location.indices == end.indices,
      location.offset + 1 == end.offset,
      let node = TreeUtils.getNode(at: location, rootNode),
      let node = node as? MathNode,
      node.allowsComponent(mathIndex)
    {
      if node.getComponent(mathIndex) == nil {
        node.addComponent(mathIndex, component, inStorage: true)
        return .success((range, true))
      }
      else {
        return .success((range, false))
      }
    }
    else {
      guard let nucleus = mapContents(in: range, { $0.deepCopy() }),
        let mathNode = composeMathNode(nucleus, mathIndex, component)
      else {
        return .failure(SatzError(.InvalidTextRange))
      }
      let result = replaceContents(in: range, with: [mathNode])
      switch result {
      case let .success(range1):
        guard let (object, location) = upstreamObject(from: range1.endLocation)
        else {
          return .failure(SatzError(.InvalidTextRange))
        }
        assert(object.nonText() === mathNode)
        let end = location.with(offsetDelta: 1)
        let range2 = RhTextRange(location, end)!
        return .success((range2, true))

      case let .failure(error):
        return .failure(error)
      }
    }

    // Helper

    func composeMathNode(
      _ nucleus: [Node], _ mathIndex: MathIndex, _ component: [Node]
    ) -> MathNode? {
      switch mathIndex {
      case .sub:
        return AttachNode(nuc: nucleus, sub: component)
      case .sup:
        return AttachNode(nuc: nucleus, sup: component)
      case .index:
        return RadicalNode(nucleus, component)
      default:
        assertionFailure("Invalid math index")
        return nil
      }
    }
  }

  /// Remove a math component from the math node at the given range.
  /// - Returns: range of resuling math node if the math node remains, or
  ///   range of the substituted nucleus if the math node is removed; otherwise,
  ///   an error.
  internal func removeMathComponent(
    _ range: RhTextRange, _ mathIndex: MathIndex
  ) -> SatzResult<RhTextRange> {
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
        let contents = nucleus.getChildren_readonly().map { $0.deepCopy() }
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
  internal func resolveTextLocation(with point: CGPoint) -> AffineLocation? {
    #if LOG_PICKING_POINT
    Rohan.logger.debug("Interacting at \(point.debugDescription)")
    #endif

    let context = _getLayoutContext()
    var trace = Trace()
    var affinity = RhTextSelection.Affinity.downstream

    let modified = rootNode.resolveTextLocation(with: point, context, &trace, &affinity)
    if modified,
      let location = trace.toTextLocation()
    {
      return AffineLocation(location, affinity)
    }
    else {
      return nil
    }
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
      return TreeUtils.moveCaretLR(location.value, in: direction, rootNode)
        .map { AffineLocation($0, .downstream) }  // always downstream

    case .up, .down:
      guard
        let result = rootNode.rayshoot(
          from: ArraySlice(location.value.asPath), affinity: location.affinity,
          direction: direction, context: _getLayoutContext(), layoutOffset: 0)
      else { return nil }
      let position = result.position.with(yDelta: direction == .up ? -0.5 : 0.5)

      if extending {
        if position.y < 0 {
          return AffineLocation(documentRange.location, .downstream)
        }
        else if position.y > usageBounds.height {
          return AffineLocation(documentRange.endLocation, .downstream)
        }
        // FALL THROUGH
      }
      else {
        if position.y < 0 || position.y > usageBounds.height {
          return location  // unchanged
        }
        // FALL THROUGH
      }
      return resolveTextLocation(with: position)

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
        return trace.toTextLocation()
          .map { AffineLocation($0, .downstream) }  // always downstream
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
        return trace.toTextLocation()
          .map { AffineLocation($0, .downstream) }  // always downstream
      }
    }
  }

  func textRange(
    for granularity: TextSelectionNavigation.Destination, enclosing location: TextLocation
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
    guard let location = trace.toRawTextLocation()
    else { return nil }

    // end location and range
    trace.moveTo(.index(range.upperBound))
    guard let endLocation = trace.toRawTextLocation(),
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

  /// Returns a substring before the given location with at most the given
  /// character count.
  internal func prefixString(from location: TextLocation, charCount: Int) -> String? {
    precondition(charCount >= 0)
    if charCount == 0 { return "" }

    guard let trace = Trace.from(location, rootNode),
      let last = trace.last,
      let textNode = last.node as? TextNode,
      let offset = last.index.index()
    else { return nil }
    return textNode.prefixString(for: offset, charCount: charCount)
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

  // MARK: - Location

  /// Returns the node located at the given path.
  internal func getNode(at path: [RohanIndex]) -> Node? {
    TreeUtils.getNode(at: path, rootNode)
  }

  /// Returns the node located at the given location.
  internal func getNode(at location: TextLocation) -> Node? {
    TreeUtils.getNode(at: location, rootNode)
  }

  /// Returns the object (character/non-text node) located to the left of the
  /// given location.
  /// - Returns: The object and its location if successful; otherwise, nil.
  internal func upstreamObject(
    from location: TextLocation
  ) -> (LocateableObject, TextLocation)? {
    guard var trace = Trace.from(location, rootNode)
    else {
      assertionFailure("Invalid location")
      return nil
    }

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
          return (LocateableObject.text(String(string)), trace.toRawTextLocation()!)
        }
        else {
          trace.truncate(to: trace.count - 1)
          continue
        }

      case let node as ElementNode:
        if offset > 0 {
          let node = node.getChild(offset - 1)
          if let textNode = node as? TextNode {
            trace.emplaceBack(textNode, .index(textNode.length))
            continue
          }
          else {
            trace.moveTo(.index(offset - 1))
            return (LocateableObject.nonText(node), trace.toRawTextLocation()!)
          }
        }
        else {
          return nil
        }

      // COPY VERBATIM FROM ElementNode
      case let node as ArgumentNode:
        if offset > 0 {
          let node = node.getChild(offset - 1)
          if let textNode = node as? TextNode {
            trace.emplaceBack(textNode, .index(textNode.length))
            continue
          }
          else {
            trace.moveTo(.index(offset - 1))
            return (LocateableObject.nonText(node), trace.toRawTextLocation()!)
          }
        }
        else {
          return nil
        }

      default:
        return nil
      }
    }
  }

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

  internal func normalizeLocation(_ location: TextLocation) -> TextLocation? {
    location.normalized(for: rootNode)
  }

  /// Compute the visual delimiter range for a location in the tree.
  internal func visualDelimiterRange(for location: TextLocation) -> RhTextRange? {
    TreeUtils.visualDelimiterRange(for: location, rootNode)
  }

  // MARK: - Debug Facility

  func prettyPrint() -> String { rootNode.prettyPrint() }

  func debugPrint() -> String { rootNode.debugPrint() }
}
