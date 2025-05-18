// Copyright 2024-2025 Lie Yan

import CoreText
import Foundation

class _TextLineLayoutContext: LayoutContext {
  final let styleSheet: StyleSheet
  final let renderedString: NSMutableAttributedString
  final private(set) var ctLine: CTLine
  final let layoutMode: LayoutMode

  fileprivate init(
    _ styleSheet: StyleSheet,
    _ renderedString: NSMutableAttributedString,
    _ ctLine: CTLine,
    _ layoutMode: LayoutMode
  ) {
    self.styleSheet = styleSheet
    self.renderedString = renderedString
    self.ctLine = ctLine
    self.layoutCursor = renderedString.length
    self.layoutMode = layoutMode
  }

  init(_ styleSheet: StyleSheet, _ layoutMode: LayoutMode) {
    self.styleSheet = styleSheet
    self.renderedString = NSMutableAttributedString()
    self.ctLine = CTLineCreateWithAttributedString(renderedString)
    self.layoutCursor = renderedString.length
    self.layoutMode = layoutMode
  }

  init(
    _ styleSheet: StyleSheet, _ fragment: TextLineLayoutFragment,
    _ layoutMode: LayoutMode
  ) {
    self.styleSheet = styleSheet
    self.renderedString = fragment.attrString
    self.ctLine = fragment.ctLine
    self.layoutCursor = fragment.attrString.length
    self.layoutMode = layoutMode
  }

  // MARK: - State

  final private(set) var layoutCursor: Int

  final func resetCursor() {
    self.layoutCursor = renderedString.length
  }

  final private(set) var isEditing: Bool = false

  final func beginEditing() {
    precondition(isEditing == false)
    isEditing = true
  }

  final func endEditing() {
    precondition(isEditing == true)
    isEditing = false
    ctLine = CTLineCreateWithAttributedString(renderedString)
  }

  // MARK: - Operations

  final func addParagraphStyle(_ source: Node, _ range: Range<Int>) {
    // no-op as we don't have paragraph style
  }

  final func skipBackwards(_ n: Int) {
    precondition(isEditing && n >= 0 && layoutCursor >= n)
    layoutCursor -= n
  }

  final func deleteBackwards(_ n: Int) {
    precondition(isEditing && n >= 0 && layoutCursor >= n)
    // find range
    let location = layoutCursor - n
    let range = NSRange(location: location, length: n)
    // update state
    renderedString.replaceCharacters(in: range, with: "")
    layoutCursor = location
  }

  final func invalidateBackwards(_ n: Int) {
    skipBackwards(n)
  }

  func insertText<S: Collection<Character>>(_ text: S, _ source: Node) {
    preconditionFailure("override this method")
  }

  final func insertNewline(_ context: Node) {
    precondition(isEditing)

    assertionFailure("insertNewline not supported")
    insertText("\u{FFFD}", context)
  }

  final func insertFragment(_ fragment: any LayoutFragment, _ source: Node) {
    precondition(isEditing)
    precondition(fragment.layoutLength == source.layoutLength())

    assertionFailure("insertFragment not supported")
    let string = String(repeating: "\u{FFFD}", count: fragment.layoutLength)
    insertText(string, source)
  }

  private func getBounds() -> (width: CGFloat, ascent: CGFloat, descent: CGFloat) {
    var width: CGFloat = 0
    var ascent: CGFloat = 0
    var descent: CGFloat = 0
    switch layoutMode {
    case .textMode:
      width = ctLine.getTypographicBounds(&ascent, &descent, nil)
    case .mathMode:
      width = ctLine.getImageBounds(&ascent, &descent)
    }
    return (width, ascent, descent)
  }

  private func getSegmentFrame(
    for layoutOffset: Int, _ affinity: RhTextSelection.Affinity
  ) -> SegmentFrame? {
    precondition(isEditing == false)
    let (_, ascent, descent) = getBounds()
    let x = ctLine.getOffset(for: layoutOffset, nil)
    let frame = CGRect(x: x, y: 0, width: 0, height: ascent + descent)
    return SegmentFrame(frame, ascent)
  }

  func getSegmentFrame(
    for layoutOffset: Int, _ affinity: RhTextSelection.Affinity, _ node: Node
  ) -> SegmentFrame? {
    self.getSegmentFrame(for: layoutOffset, affinity)
  }

  /// - Note: Origins of the segment frame is relative to __the top-left corner__
  /// of the container.
  func enumerateTextSegments(
    _ layoutRange: Range<Int>, type: DocumentManager.SegmentType,
    options: DocumentManager.SegmentOptions,
    using block: (Range<Int>?, CGRect, CGFloat) -> Bool
  ) -> Bool {
    precondition(isEditing == false)

    let (_, ascent, descent) = getBounds()
    let x0 = ctLine.getOffset(for: layoutRange.lowerBound, nil)
    let x1 = ctLine.getOffset(for: layoutRange.upperBound, nil)

    let frame = CGRect(x: x0, y: 0, width: x1 - x0, height: ascent + descent)
    return block(layoutRange, frame, ascent)
  }

  func getLayoutRange(interactingAt point: CGPoint) -> PickingResult? {
    precondition(isEditing == false)

    // char index
    let charIndex = ctLine.getStringIndex(for: point)

    // next char index

    let string = renderedString.string
    let u16String = renderedString.string.utf16
    guard
      let index = u16String.index(
        string.startIndex, offsetBy: charIndex, limitedBy: string.endIndex)
    else { return nil }
    let nextIndex: String.Index =
      index < string.endIndex ? string.index(after: index) : index

    let nextCharIndex = u16String.distance(from: string.startIndex, to: nextIndex)

    // range
    let range = charIndex..<nextCharIndex

    //
    if charIndex == nextCharIndex {
      return PickingResult(range, 0, .downstream)
    }
    else {
      // fraction
      let x0 = ctLine.getOffset(for: charIndex, nil)
      let x1 = ctLine.getOffset(for: nextCharIndex, nil)
      let x = point.x.clamped(x0, x1)
      let fraction = (x - x0) / (x1 - x0)
      return PickingResult(range, fraction, .downstream)
    }
  }

  func rayshoot(
    from layoutOffset: Int, affinity: RhTextSelection.Affinity,
    direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    guard let segmentFrame = getSegmentFrame(for: layoutOffset, affinity)
    else { return nil }

    switch direction {
    case .up:
      let x = segmentFrame.frame.origin.x
      let y = segmentFrame.frame.minY
      return RayshootResult(CGPoint(x: x, y: y), false)

    case .down:
      let x = segmentFrame.frame.origin.x
      let y = segmentFrame.frame.maxY
      return RayshootResult(CGPoint(x: x, y: y), false)

    default:
      assertionFailure("Unexpected direction")
      return nil
    }
  }

  func lineFrame(
    from layoutOffset: Int, affinity: RhTextSelection.Affinity,
    direction: TextSelectionNavigation.Direction
  ) -> SegmentFrame? {
    nil
  }
}

final class TextLineLayoutContext: _TextLineLayoutContext {
  init(
    _ styleSheet: StyleSheet, _ renderedString: NSMutableAttributedString,
    _ ctLine: CTLine
  ) {
    super.init(styleSheet, renderedString, ctLine, .textMode)
  }

  init(_ styleSheet: StyleSheet, _ fragment: TextLineLayoutFragment) {
    super.init(styleSheet, fragment, .textMode)
  }

  init(_ styleSheet: StyleSheet) {
    super.init(styleSheet, .textMode)
  }

  override func insertText<S: Collection<Character>>(_ text: S, _ source: Node) {
    precondition(isEditing)
    guard !text.isEmpty else { return }
    // obtain style properties
    let properties: TextProperty = source.resolvePropertyAggregate(styleSheet)
    let attributes = properties.getAttributes(isFlipped: true)  // flip for CTLine
    // create attributed string
    let attrString = NSAttributedString(string: String(text), attributes: attributes)
    // update state
    let location = NSRange(location: layoutCursor, length: 0)
    renderedString.replaceCharacters(in: location, with: attrString)
  }
}

final class MathTextLineLayoutContext: _TextLineLayoutContext {
  let mathContext: MathContext
  private var resolvedString: ResolvedString
  var originalString: String { resolvedString.string }

  init(
    _ styleSheet: StyleSheet,
    _ originalString: String,
    _ renderedString: NSMutableAttributedString,
    _ ctLine: CTLine,
    _ mathContext: MathContext
  ) {
    self.mathContext = mathContext
    self.resolvedString =
      ResolvedString(string: originalString, resolved: renderedString.string)
    super.init(styleSheet, renderedString, ctLine, .mathMode)
  }

  init(
    _ styleSheet: StyleSheet, _ fragment: TextLineLayoutFragment,
    _ mathContext: MathContext
  ) {
    self.mathContext = mathContext
    self.resolvedString = ResolvedString(
      string: fragment.originalString, resolved: fragment.resolvedString)
    super.init(styleSheet, fragment, .mathMode)
  }

  init(_ styleSheet: StyleSheet, _ mathContext: MathContext) {
    self.mathContext = mathContext
    self.resolvedString = ResolvedString(string: "", resolved: "")
    super.init(styleSheet, .mathMode)
  }

  override func insertText<S: Collection<Character>>(_ text: S, _ source: Node) {
    precondition(isEditing)
    guard !text.isEmpty else { return }

    //
    let mathProperty = source.resolvePropertyAggregate(styleSheet) as MathProperty
    let textProperty = source.resolvePropertyAggregate(styleSheet) as TextProperty
    let attributes = mathProperty.getAttributes(
      isFlipped: true,  // flip for CTLine
      textProperty, mathContext)
    //
    let range = layoutCursor..<layoutCursor
    let (rrange, rstring) =
      resolvedString.replaceSubrange(range, with: String(text), mathProperty)
    let attrString = NSAttributedString(string: rstring, attributes: attributes)
    //
    renderedString.replaceCharacters(in: NSRange(rrange), with: attrString)
  }

  override func getSegmentFrame(
    for layoutOffset: Int, _ affinity: RhTextSelection.Affinity, _ node: Node
  ) -> SegmentFrame? {
    let resolvedOffset = resolvedString.resolvedOffset(for: layoutOffset)
    return super.getSegmentFrame(for: resolvedOffset, affinity, node)
  }

  override func enumerateTextSegments(
    _ layoutRange: Range<Int>, type: DocumentManager.SegmentType,
    options: DocumentManager.SegmentOptions,
    using block: (Range<Int>?, CGRect, CGFloat) -> Bool
  ) -> Bool {
    let resolvedRange = resolvedString.resolvedRange(for: layoutRange)
    return super.enumerateTextSegments(
      resolvedRange, type: type, options: options, using: block)
  }

  override func rayshoot(
    from layoutOffset: Int, affinity: RhTextSelection.Affinity,
    direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    let resolvedOffset = resolvedString.resolvedOffset(for: layoutOffset)
    return super.rayshoot(
      from: resolvedOffset, affinity: affinity, direction: direction)
  }

  override func lineFrame(
    from layoutOffset: Int, affinity: RhTextSelection.Affinity,
    direction: TextSelectionNavigation.Direction
  ) -> SegmentFrame? {
    let resolvedOffset = resolvedString.resolvedOffset(for: layoutOffset)
    return super.lineFrame(from: resolvedOffset, affinity: affinity, direction: direction)
  }

  override func getLayoutRange(interactingAt point: CGPoint) -> PickingResult? {
    guard let result = super.getLayoutRange(interactingAt: point)
    else { return nil }
    let originalRange = resolvedString.range(for: result.layoutRange)
    return result.with(layoutRange: originalRange)
  }
}

private struct ResolvedString {
  private(set) var string: String
  private(set) var resolved: String

  init(string: String, resolved: String) {
    precondition(string.count == resolved.count)
    self.string = string
    self.resolved = resolved
  }

  func resolvedOffset(for offset: Int) -> Int {
    precondition(offset >= 0 && offset <= string.length)

    let index = string.utf16.index(string.startIndex, offsetBy: offset)
    let charOffset = string.distance(from: string.startIndex, to: index)
    let resolvedCharIndex = resolved.index(resolved.startIndex, offsetBy: charOffset)
    let resolvedOffset = resolved.utf16.distance(
      from: resolved.startIndex, to: resolvedCharIndex)
    return resolvedOffset
  }

  func offset(for resolvedOffset: Int) -> Int {
    precondition(resolvedOffset >= 0 && resolvedOffset <= resolved.length)

    let index = resolved.utf16.index(resolved.startIndex, offsetBy: resolvedOffset)
    let charOffset = resolved.distance(from: resolved.startIndex, to: index)
    let originalCharIndex = string.index(string.startIndex, offsetBy: charOffset)
    let originalOffset = string.utf16.distance(
      from: string.startIndex, to: originalCharIndex)
    return originalOffset
  }

  func resolvedRange(for range: Range<Int>) -> Range<Int> {
    precondition(range.lowerBound >= 0 && range.upperBound <= string.length)

    if range.lowerBound == range.upperBound {
      let resolvedOffset = resolvedOffset(for: range.lowerBound)
      return resolvedOffset..<resolvedOffset
    }
    else {
      let lowerBound = resolvedOffset(for: range.lowerBound)
      let upperBound = resolvedOffset(for: range.upperBound)
      return lowerBound..<upperBound
    }
  }

  func range(for resolvedRange: Range<Int>) -> Range<Int> {
    precondition(
      resolvedRange.lowerBound >= 0 && resolvedRange.upperBound <= resolved.length)

    if resolvedRange.lowerBound == resolvedRange.upperBound {
      let originalOffset = offset(for: resolvedRange.lowerBound)
      return originalOffset..<originalOffset
    }
    else {
      let lowerBound = offset(for: resolvedRange.lowerBound)
      let upperBound = offset(for: resolvedRange.upperBound)
      return lowerBound..<upperBound
    }
  }

  /// Replace a range of characters with a string.
  /// - Returns: The range and string for replacement in the resolved string.
  mutating func replaceSubrange(
    _ range: Range<Int>, with string: String, _ properties: MathProperty
  ) -> (Range<Int>, String) {
    precondition(range.lowerBound >= 0 && range.upperBound <= string.length)

    // equivalent strings
    let resolved = Self.resolveString(string, properties)

    // equivalent ranges
    let resolvedRange = resolvedRange(for: range)

    // perform replacements
    self.string.replaceSubrange(self.string.indexRange(for: range), with: string)
    self.resolved.replaceSubrange(
      self.resolved.indexRange(for: resolvedRange), with: resolved)

    return (resolvedRange, resolved)
  }

  private static func resolveString(
    _ string: String, _ mathProperty: MathProperty
  ) -> String {
    switch mathProperty.variant {
    case .bb, .cal, .frak, .mono, .sans:
      let result = string.map { char in MathUtils.resolveCharacter(char, mathProperty) }
      return String(result)

    case .serif:
      return string
    }
  }
}
