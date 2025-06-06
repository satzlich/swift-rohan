// Copyright 2024-2025 Lie Yan

import CoreText
import Foundation

final class TextLineLayoutContext: _CTLineLayoutContext {
  override init(_ styleSheet: StyleSheet, _ fragment: TextLineLayoutFragment) {
    super.init(styleSheet, fragment)
  }

  init(_ styleSheet: StyleSheet, _ boundsOption: BoundsOption) {
    super.init(styleSheet, .textMode, boundsOption)
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

internal class _CTLineLayoutContext: LayoutContext {
  final let styleSheet: StyleSheet
  final let renderedString: NSMutableAttributedString
  final private(set) var ctLine: CTLine
  final let layoutMode: LayoutMode

  typealias BoundsOption = TextLineLayoutFragment.BoundsOption
  final let boundsOption: BoundsOption

  init(_ styleSheet: StyleSheet, _ fragment: TextLineLayoutFragment) {
    self.styleSheet = styleSheet
    self.renderedString = fragment.attrString
    self.ctLine = fragment.ctLine
    self.layoutCursor = fragment.attrString.length
    self.layoutMode = fragment.layoutMode
    self.boundsOption = fragment.boundsOption
  }

  init(_ styleSheet: StyleSheet, _ layoutMode: LayoutMode, _ boundsOption: BoundsOption) {
    self.styleSheet = styleSheet
    self.renderedString = NSMutableAttributedString()
    self.ctLine = CTLineCreateWithAttributedString(renderedString)
    self.layoutCursor = renderedString.length
    self.layoutMode = layoutMode
    self.boundsOption = boundsOption
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
    switch boundsOption {
    case .typographicBounds:
      width = ctLine.getTypographicBounds(&ascent, &descent, nil)
    case .imageBounds:
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

    //
    var minAscent: CGFloat = 0
    var minDescent: CGFloat = 0
    _ = ctLine.getTypographicBounds(&minAscent, &minDescent, nil)

    //
    let (_, bAscent, bDescent) = getBounds()
    let x0 = ctLine.getOffset(for: layoutRange.lowerBound, nil)
    let x1 = ctLine.getOffset(for: layoutRange.upperBound, nil)

    //
    let ascent = max(bAscent, minAscent)
    let descent = max(bDescent, minDescent)
    let frame = CGRect(
      x: x0, y: -ascent + bAscent, width: x1 - x0, height: ascent + descent)
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
      var x0 = ctLine.getOffset(for: charIndex, nil)
      var x1 = ctLine.getOffset(for: nextCharIndex, nil)
      // swap if needed for right-to-left languages
      if x0 > x1 { swap(&x0, &x1) }
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
