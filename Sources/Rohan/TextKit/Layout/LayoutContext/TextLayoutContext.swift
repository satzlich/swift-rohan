// Copyright 2024-2025 Lie Yan

import AppKit
import _RopeModule

final class TextLayoutContext: LayoutContext {
  let styleSheet: StyleSheet
  let textContentStorage: NSTextContentStorage
  let textLayoutManager: NSTextLayoutManager
  private var textStorage: NSTextStorage { textContentStorage.textStorage! }

  init(
    _ styleSheet: StyleSheet, _ textContentStorage: NSTextContentStorage,
    _ textLayoutManager: NSTextLayoutManager
  ) {
    self.styleSheet = styleSheet

    assert(textContentStorage is NSTextContentStoragePatched)
    self.textContentStorage = textContentStorage
    self.textLayoutManager = textLayoutManager

    self.layoutCursor = textContentStorage.textStorage!.length
  }

  // MARK: - State

  private(set) var layoutCursor: Int
  private(set) var isEditing: Bool = false

  func beginEditing() {
    precondition(isEditing == false)
    isEditing = true
  }

  func endEditing() {
    precondition(isEditing == true)
    isEditing = false
  }

  // MARK: - Operations

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
    precondition(isEditing && n >= 0 && layoutCursor >= n)
    // find character range
    let location = layoutCursor - n
    let range = NSRange(location: location, length: n)
    // update layout cursor no matter what
    defer { layoutCursor = location }
    // find text range
    guard let textRange = textContentStorage.textRange(for: range)
    else { assertionFailure("text range not found"); return }
    // update state
    textLayoutManager.invalidateLayout(for: textRange)
  }

  func insertText<S>(_ text: S, _ source: Node)
  where S: Collection, S.Element == Character {
    precondition(isEditing)
    guard !text.isEmpty else { return }
    // obtain style properties
    let properties: TextProperty = source.resolvePropertyAggregate(styleSheet)
    let attributes = properties.getAttributes()
    // create attributed string
    let attrString = NSAttributedString(string: String(text), attributes: attributes)
    // update state
    let location = NSRange(location: layoutCursor, length: 0)
    textStorage.replaceCharacters(in: location, with: attrString)
  }

  func insertNewline(_ context: Node) {
    precondition(isEditing)
    // obtain style properties
    let properties: TextProperty = context.resolvePropertyAggregate(styleSheet)
    let attributes = properties.getAttributes()
    // create attributed string
    let attrString = NSAttributedString(string: "\n", attributes: attributes)
    assert(attrString.length == 1)
    // update state
    let location = NSRange(location: layoutCursor, length: 0)
    textStorage.replaceCharacters(in: location, with: attrString)
  }

  func insertFragment(_ fragment: any LayoutFragment, _ source: Node) {
    precondition(isEditing)
    // obtain style properties
    let properties: TextProperty = source.resolvePropertyAggregate(styleSheet)
    let attributes = properties.getAttributes()
    // form attributed string
    let attrString = Self.attributedString(for: fragment, attributes)
    // update state
    let location = NSRange(location: layoutCursor, length: 0)
    textStorage.replaceCharacters(in: location, with: attrString)
    // padding if necessary
    assert(fragment.layoutLength == source.layoutLength)
    assert(fragment.layoutLength >= attrString.length)
    let n = source.layoutLength - attrString.length
    if n > 0 {
      let padding = Self.createZWSP(count: n, attributes)
      textStorage.replaceCharacters(in: location, with: padding)
    }
  }

  /// Wrap given fragment in text attachment which is further embedded in an
  /// attributed string
  private static func attributedString(
    for fragment: any LayoutFragment, _ attributes: [NSAttributedString.Key: Any]
  ) -> NSAttributedString {
    let attachment = LayoutFragmentAttachment(fragment)
    if #available(macOS 15.0, *) {
      return NSAttributedString(attachment: attachment, attributes: attributes)
    }
    else {
      // Fallback on earlier versions
      let mutableString = NSMutableAttributedString(attachment: attachment)
      let range = NSRange(location: 0, length: mutableString.length)
      mutableString.setAttributes(attributes, range: range)
      return mutableString
    }
  }

  /// Create a string of zero-width space characters
  private static func createZWSP(
    count: Int, _ attributes: [NSAttributedString.Key: Any]
  ) -> NSAttributedString {
    precondition(count > 0)
    let string = String(repeating: "\u{200B}", count: count)
    return NSAttributedString(string: string, attributes: attributes)
  }

  // MARK: - Frame

  func getSegmentFrame(for layoutOffset: Int) -> SegmentFrame? {
    guard let location = textContentStorage.textLocation(for: layoutOffset)
    else { return nil }
    let textRange = NSTextRange(location: location)
    var result: SegmentFrame? = nil
    textLayoutManager.enumerateTextSegments(
      in: textRange, type: .standard, options: .rangeNotRequired
    ) { (_, segmentFrame, baselinePosition, _) in
      // pass frame to caller
      result = SegmentFrame(segmentFrame, baselinePosition)
      return false  // stop
    }
    return result
  }

  func enumerateTextSegments(
    _ layoutRange: Range<Int>,
    type: DocumentManager.SegmentType,
    options: DocumentManager.SegmentOptions,
    using block: (Range<Int>?, CGRect, CGFloat) -> Bool
  ) -> Bool {
    let charRange = NSRange(location: layoutRange.lowerBound, length: layoutRange.count)
    guard let textRange = textContentStorage.textRange(for: charRange)
    else { return false }

    var shouldContinue = false
    textLayoutManager.enumerateTextSegments(in: textRange, type: type, options: options) {
      (textRange, segmentFrame, baselinePosition, _) in
      if let textRange {
        let charRange = textContentStorage.characterRange(for: textRange)
        if charRange.location != NSNotFound {
          let range = charRange.lowerBound..<charRange.upperBound
          shouldContinue = block(range, segmentFrame, baselinePosition)
          return shouldContinue
        }
        // FALL THROUGH
      }
      shouldContinue = block(nil, segmentFrame, baselinePosition)
      return shouldContinue
    }
    return shouldContinue
  }

  func getLayoutRange(interactingAt point: CGPoint) -> (Range<Int>, Double)? {
    func characterIndex(for point: CGPoint) -> Int? {
      let selections = textLayoutManager.textSelectionNavigation.textSelections(
        interactingAt: point, inContainerAt: textLayoutManager.documentRange.location,
        anchors: [], modifiers: [], selecting: false, bounds: .infinite)
      guard let selection = selections.getOnlyElement(),
        let textRange = selection.textRanges.getOnlyElement(),
        textRange.isEmpty
      else { return nil }
      return textContentStorage.characterIndex(for: textRange.location)
    }
    func characterRange(for point: CGPoint) -> Range<Int>? {
      let selection = textLayoutManager.textSelectionNavigation.textSelection(
        for: .character, enclosing: point,
        inContainerAt: textLayoutManager.documentRange.location)
      guard let selection,
        let textRange = selection.textRanges.getOnlyElement()
      else { return nil }
      let charRange = textContentStorage.characterRange(for: textRange)
      return charRange.lowerBound..<charRange.upperBound
    }
    guard let charIndex = characterIndex(for: point),
      let charRange = characterRange(for: point),
      var fraction = fractionOfDistanceThroughGlyph(for: point)
    else { return nil }
    if charIndex == charRange.upperBound {
      fraction = 1.0
    }
    return (charRange, fraction)
  }

  /// The fraction of distance from the upstream edge
  private func fractionOfDistanceThroughGlyph(for point: CGPoint) -> Double? {
    guard let textLayoutFragment = textLayoutManager.textLayoutFragment(for: point)
    else { return nil }
    // position relative to the text layout fragment
    let layoutFragPoint =
      point.relative(to: textLayoutFragment.layoutFragmentFrame.origin)
    // get text line fragment
    let textLineFragment = textLayoutFragment.textLineFragment(
      forVerticalOffset: layoutFragPoint.y, requiresExactMatch: false)
    guard let textLineFragment else { return nil }
    // position relative to the text line fragment
    let lineFragPoint = layoutFragPoint.relative(to: textLineFragment.glyphOrigin)
    // compute fraction
    return textLineFragment.fractionOfDistanceThroughGlyph(for: lineFragPoint)
  }

  func rayshoot(
    from layoutOffset: Int, _ direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    guard let segmentFrame = self.getSegmentFrame(for: layoutOffset) else { return nil }
    switch direction {
    case .up:
      let x = segmentFrame.frame.origin.x
      let y = segmentFrame.frame.minY
      let usageBounds = textLayoutManager.usageBoundsForTextContainer
      // if we are about to go beyond the top edge, resolved = false
      let resolved = !y.isApproximatelyEqual(to: usageBounds.minY)
      return RayshootResult(CGPoint(x: x, y: y), resolved)

    case .down:
      let x = segmentFrame.frame.origin.x
      let y = segmentFrame.frame.maxY
      let usageBounds = textLayoutManager.usageBoundsForTextContainer
      // if we are about to go beyond the bottom edge, resolved = false
      let resolved = !y.isApproximatelyEqual(to: usageBounds.maxY)
      return RayshootResult(CGPoint(x: x, y: y), resolved)

    default:
      assertionFailure("unexpected direction")
      return nil
    }
  }
}
