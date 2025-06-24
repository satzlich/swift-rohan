// Copyright 2024-2025 Lie Yan

import CoreText
import Foundation

internal class CTLineLayoutContext: LayoutContext {
  final let styleSheet: StyleSheet
  final let renderedString: NSMutableAttributedString
  final private(set) var ctLine: CTLine
  final let layoutMode: LayoutMode

  typealias BoundsOption = CTLineLayoutFragment.BoundsOption
  final let boundsOption: BoundsOption

  init(_ styleSheet: StyleSheet, _ fragment: CTLineLayoutFragment) {
    self.styleSheet = styleSheet
    self.renderedString = fragment.attrString
    self.ctLine = fragment.ctLine
    self._layoutCursor = fragment.attrString.length
    self.layoutMode = fragment.layoutMode
    self.boundsOption = fragment.boundsOption
  }

  init(_ styleSheet: StyleSheet, _ layoutMode: LayoutMode, _ boundsOption: BoundsOption) {
    self.styleSheet = styleSheet
    self.renderedString = NSMutableAttributedString()
    self.ctLine = CTLineCreateWithAttributedString(renderedString)
    self._layoutCursor = renderedString.length
    self.layoutMode = layoutMode
    self.boundsOption = boundsOption
  }

  // MARK: - State

  final var _layoutCursor: Int

  final var layoutCursor: Int { _layoutCursor }

  final func resetCursor() {
    self._layoutCursor = renderedString.length
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

  func skipBackwards(_ n: Int) {
    precondition(isEditing && n >= 0 && layoutCursor >= n)
    _layoutCursor -= n
  }

  func deleteBackwards(_ n: Int) {
    precondition(isEditing && n >= 0 && layoutCursor >= n)
    // find range
    let location = layoutCursor - n
    let range = NSRange(location: location, length: n)
    // update state
    renderedString.replaceCharacters(in: range, with: "")
    _layoutCursor = location
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

  // MARK: - Edit

  func skipForward(_ n: Int) {
    precondition(isEditing && n >= 0 && layoutCursor + n <= renderedString.length)
    _layoutCursor += n
  }

  func deleteForward(_ n: Int) {
    precondition(isEditing && n >= 0 && layoutCursor + n <= renderedString.length)
    // find range
    let location = layoutCursor
    let range = NSRange(location: location, length: n)
    // update state
    renderedString.replaceCharacters(in: range, with: "")
    _layoutCursor = location + n
  }

  func invalidateForward(_ n: Int) {
    skipForward(n)
  }

  func insertTextForward(_ text: some Collection<Character>, _ source: Node) {
    preconditionFailure("overriding required")
  }

  func insertNewlineForward(_ context: Node) {
    preconditionFailure("Unsupported operation: \(#function)")
  }

  func insertFragmentForward(_ fragment: any LayoutFragment, _ source: Node) {
    preconditionFailure("Unsupported operation: \(#function)")
  }

  // MARK: - Query

  func getSegmentFrame(
    _ layoutOffset: Int, _ affinity: SelectionAffinity
  ) -> SegmentFrame? {
    precondition(isEditing == false)
    let (_, ascent, descent) = getBounds()
    let x = ctLine.getOffset(for: layoutOffset, nil)
    let frame = CGRect(x: x, y: 0, width: 0, height: ascent + descent)
    return SegmentFrame(frame, ascent)
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
    let frame =
      CGRect(x: x0, y: -ascent + bAscent, width: x1 - x0, height: ascent + descent)
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
    from layoutOffset: Int, affinity: SelectionAffinity,
    direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    guard let segmentFrame = getSegmentFrame(layoutOffset, affinity) else { return nil }

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

  func neighbourLineFrame(
    from layoutOffset: Int, affinity: SelectionAffinity,
    direction: TextSelectionNavigation.Direction
  ) -> SegmentFrame? {
    nil
  }
}
