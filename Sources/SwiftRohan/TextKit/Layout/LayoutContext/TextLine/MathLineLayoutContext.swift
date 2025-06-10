// Copyright 2024-2025 Lie Yan

import CoreText
import Foundation

final class MathLineLayoutContext: LayoutContext {
  private let layoutContext: CTLineLayoutContext

  private var resolvedString: ResolvedString
  var originalString: String { resolvedString.string }

  let mathContext: MathContext

  // expose layout context properties
  var styleSheet: StyleSheet { layoutContext.styleSheet }
  var renderedString: NSMutableAttributedString { layoutContext.renderedString }
  var ctLine: CTLine { layoutContext.ctLine }

  init(
    _ styleSheet: StyleSheet, _ fragment: UniLineLayoutFragment,
    _ mathContext: MathContext
  ) {
    self.mathContext = mathContext
    self.resolvedString =
      ResolvedString(string: fragment.originalString, resolved: fragment.resolvedString)
    self.layoutCursor = resolvedString.string.length
    self.layoutContext = CTLineLayoutContext(styleSheet, fragment)
  }

  init(_ styleSheet: StyleSheet, _ mathContext: MathContext) {
    self.mathContext = mathContext
    self.resolvedString = ResolvedString()
    self.layoutCursor = resolvedString.string.length
    self.layoutContext = CTLineLayoutContext(styleSheet, .mathMode, .imageBounds)
  }

  // MARK: - Editing

  private(set) var layoutCursor: Int

  func resetCursor() {
    layoutCursor = originalString.length
  }

  var isEditing: Bool { layoutContext.isEditing }

  func beginEditing() {
    layoutContext.beginEditing()
  }

  func endEditing() {
    layoutContext.endEditing()

    assert(resolvedString.string.count == resolvedString.resolved.count)
    assert(resolvedString.resolved.length == renderedString.length)
  }

  func addParagraphStyle(_ source: Node, _ range: Range<Int>) {
    precondition(isEditing)
    let resolvedRange = resolvedString.resolvedRange(for: range)
    layoutContext.addParagraphStyle(source, resolvedRange)
  }

  func skipBackwards(_ n: Int) {
    precondition(isEditing)
    let location = layoutCursor - n
    let resolvedRange = resolvedString.resolvedRange(for: location..<layoutCursor)
    layoutContext.skipBackwards(resolvedRange.count)
    layoutCursor = location
  }

  func deleteBackwards(_ n: Int) {
    precondition(isEditing)
    let location = layoutCursor - n
    let resolvedRange = resolvedString.removeSubrange(location..<layoutCursor)
    layoutContext.deleteBackwards(resolvedRange.count)
    layoutCursor = location
  }

  func insertText<S: Collection<Character>>(_ text: S, _ source: Node) {
    precondition(isEditing)
    guard !text.isEmpty else { return }

    //
    let mathProperty = source.resolveAggregate(styleSheet) as MathProperty
    let textProperty = source.resolveAggregate(styleSheet) as TextProperty
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

  func insertFragment(_ fragment: any LayoutFragment, _ source: Node) {
    precondition(isEditing)
    precondition(fragment.layoutLength == source.layoutLength())

    assertionFailure("insertFragment not supported")
    let string = String(repeating: "\u{FFFD}", count: fragment.layoutLength)
    _ = resolvedString.replaceSubrange(layoutCursor..<layoutCursor, with: string)

    layoutContext.insertFragment(fragment, source)
  }

  func insertNewline(_ context: Node) {
    precondition(isEditing)
    assertionFailure("insertNewline not supported")
    _ = resolvedString.replaceSubrange(layoutCursor..<layoutCursor, with: "\u{FFFD}")

    layoutContext.insertNewline(context)
  }

  func invalidateBackwards(_ n: Int) {
    self.skipBackwards(n)
  }

  // MARK: - Query

  func getSegmentFrame(
    _ layoutOffset: Int, _ affinity: RhTextSelection.Affinity
  ) -> SegmentFrame? {
    let resolvedOffset = resolvedString.resolvedOffset(for: layoutOffset)
    return layoutContext.getSegmentFrame(resolvedOffset, affinity)
  }

  func enumerateTextSegments(
    _ layoutRange: Range<Int>, type: DocumentManager.SegmentType,
    options: DocumentManager.SegmentOptions,
    using block: (Range<Int>?, CGRect, CGFloat) -> Bool
  ) -> Bool {
    let resolvedRange = resolvedString.resolvedRange(for: layoutRange)
    return layoutContext.enumerateTextSegments(
      resolvedRange, type: type, options: options, using: block)
  }

  func rayshoot(
    from layoutOffset: Int, affinity: RhTextSelection.Affinity,
    direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    let resolvedOffset = resolvedString.resolvedOffset(for: layoutOffset)
    return layoutContext.rayshoot(
      from: resolvedOffset, affinity: affinity, direction: direction)
  }

  func lineFrame(
    from layoutOffset: Int, affinity: RhTextSelection.Affinity,
    direction: TextSelectionNavigation.Direction
  ) -> SegmentFrame? {
    let resolvedOffset = resolvedString.resolvedOffset(for: layoutOffset)
    return layoutContext.lineFrame(
      from: resolvedOffset, affinity: affinity, direction: direction)
  }

  func getLayoutRange(interactingAt point: CGPoint) -> PickingResult? {
    guard let result = layoutContext.getLayoutRange(interactingAt: point)
    else { return nil }
    let originalRange = resolvedString.range(for: result.layoutRange)
    return result.with(layoutRange: originalRange)
  }
}

private struct ResolvedString {
  private(set) var string: String
  private(set) var resolved: String

  init() {
    self.string = ""
    self.resolved = ""
  }

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
    precondition(range.lowerBound >= 0 && range.upperBound <= self.string.length)

    // equivalent strings
    let resolved = Self.resolveString(string, properties)
    assert(string.count == resolved.count)
    // equivalent ranges
    let resolvedRange = resolvedRange(for: range)

    // perform replacements
    self.string.replaceSubrange(self.string.indexRange(for: range), with: string)
    self.resolved.replaceSubrange(
      self.resolved.indexRange(for: resolvedRange), with: resolved)

    return (resolvedRange, resolved)
  }

  mutating func replaceSubrange(
    _ range: Range<Int>, with string: String
  ) -> Range<Int> {
    precondition(range.lowerBound >= 0 && range.upperBound <= string.length)
    // equivalent ranges
    let resolvedRange = resolvedRange(for: range)
    // perform replacements
    self.string.replaceSubrange(self.string.indexRange(for: range), with: string)
    self.resolved.replaceSubrange(
      self.resolved.indexRange(for: resolvedRange), with: string)
    return resolvedRange
  }

  mutating func removeSubrange(_ range: Range<Int>) -> Range<Int> {
    precondition(range.lowerBound >= 0 && range.upperBound <= string.length)
    let resolvedRange = resolvedRange(for: range)

    self.string.removeSubrange(self.string.indexRange(for: range))
    self.resolved.removeSubrange(self.resolved.indexRange(for: resolvedRange))

    return resolvedRange
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
