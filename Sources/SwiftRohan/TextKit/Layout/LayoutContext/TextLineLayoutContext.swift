// Copyright 2024-2025 Lie Yan

import CoreText
import Foundation

final class TextLineLayoutContext: LayoutContext {
  let styleSheet: StyleSheet
  let textStorage: NSMutableAttributedString
  private(set) var ctLine: CTLine

  private init(
    _ styleSheet: StyleSheet,
    _ textStorage: NSMutableAttributedString,
    _ ctLine: CTLine
  ) {
    self.styleSheet = styleSheet
    self.textStorage = textStorage
    self.ctLine = ctLine

    self.layoutCursor = textStorage.length
  }

  init(_ styleSheet: StyleSheet) {
    self.styleSheet = styleSheet
    self.textStorage = NSMutableAttributedString()
    self.ctLine = CTLineCreateWithAttributedString(textStorage)
    self.layoutCursor = textStorage.length
  }

  convenience init(_ styleSheet: StyleSheet, _ fragment: TextLineLayoutFragment) {
    self.init(styleSheet, fragment.attrString, fragment.ctLine)
  }

  // MARK: - State

  private(set) var layoutCursor: Int

  func resetCursor() {
    self.layoutCursor = textStorage.length
  }

  private(set) var isEditing: Bool = false

  func beginEditing() {
    precondition(isEditing == false)
    isEditing = true
  }

  func endEditing() {
    precondition(isEditing == true)
    isEditing = false
    ctLine = CTLineCreateWithAttributedString(textStorage)
  }

  // MARK: - Operations

  func addParagraphStyle(_ source: Node, _ range: Range<Int>) {
    // no-op as we don't have paragraph style
  }

  func skipBackwards(_ n: Int) {
    precondition(isEditing && n >= 0 && layoutCursor >= n)
    layoutCursor -= n
  }

  func deleteBackwards(_ n: Int) {
    precondition(isEditing && n >= 0 && layoutCursor >= n)
    // find range
    let location = layoutCursor - n
    let range = NSRange(location: location, length: n)
    // update state
    textStorage.replaceCharacters(in: range, with: "")
    layoutCursor = location
  }

  func invalidateBackwards(_ n: Int) {
    skipBackwards(n)
  }

  func insertText<S: Collection<Character>>(_ text: S, _ source: Node) {
    precondition(isEditing)
    guard !text.isEmpty else { return }
    // obtain style properties
    let properties: TextProperty = source.resolvePropertyAggregate(styleSheet)
    let attributes = properties.getAttributes(isFlipped: true)  // flip for CTLine
    // create attributed string
    let attrString = NSAttributedString(string: String(text), attributes: attributes)
    // update state
    let location = NSRange(location: layoutCursor, length: 0)
    textStorage.replaceCharacters(in: location, with: attrString)
  }

  func insertNewline(_ context: Node) {
    precondition(isEditing)
    assertionFailure("insertNewline not supported")

    insertText(Strings.replacement, context)
  }

  func insertFragment(_ fragment: any LayoutFragment, _ source: Node) {
    precondition(isEditing)
    precondition(fragment.layoutLength == source.layoutLength())

    assertionFailure("insertFragment not supported")
    let string = String(repeating: Strings.replacement, count: fragment.layoutLength)
    insertText(string, source)
  }

  private func getSegmentFrame(
    for layoutOffset: Int, _ affinity: RhTextSelection.Affinity
  ) -> SegmentFrame? {
    precondition(isEditing == false)

    var ascent: CGFloat = 0
    var descent: CGFloat = 0
    _ = ctLine.getTypographicBounds(&ascent, &descent, nil)
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

    var ascent: CGFloat = 0
    var descent: CGFloat = 0
    _ = ctLine.getTypographicBounds(&ascent, &descent, nil)

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

    let string = textStorage.string
    let u16String = textStorage.string.utf16
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
    from layoutOffset: Int,
    affinity: RhTextSelection.Affinity,
    direction: TextSelectionNavigation.Direction
  ) -> SegmentFrame? {
    nil
  }
}
