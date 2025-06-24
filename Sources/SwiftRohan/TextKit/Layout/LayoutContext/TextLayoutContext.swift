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

  internal func resetCursor() {
    self.layoutCursor = textContentStorage.textStorage!.length
  }

  private(set) var isEditing: Bool = false

  func beginEditing() {
    precondition(isEditing == false)
    isEditing = true
  }

  func endEditing() {
    precondition(isEditing == true)
    isEditing = false
  }

  // MARK: - Paragraph Style

  func addParagraphStyle(_ source: Node, _ range: Range<Int>) {
    precondition(isEditing)
    let properties: ParagraphProperty = source.resolveAggregate(styleSheet)
    let attributes = properties.getAttributes()
    textStorage.addAttributes(attributes, range: NSRange(range))
  }

  func addParagraphStyle(forSegment segment: Int, _ source: Node) {
    precondition(isEditing)
    let begin = self.layoutCursor
    let end = begin + segment
    self.addParagraphStyle(source, begin..<end)
  }

  func addAttributes(
    _ attributes: Dictionary<NSAttributedString.Key, Any>, _ range: Range<Int>
  ) {
    precondition(isEditing)
    textStorage.addAttributes(attributes, range: NSRange(range))
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

  func insertText<S: Collection<Character>>(_ text: S, _ source: Node) {
    precondition(isEditing)
    guard !text.isEmpty else { return }
    // obtain style properties
    let properties: TextProperty = source.resolveAggregate(styleSheet)
    let attributes = properties.getAttributes()
    // create attributed string
    let attrString = NSAttributedString(string: String(text), attributes: attributes)
    // update state
    let location = NSRange(location: layoutCursor, length: 0)
    textStorage.replaceCharacters(in: location, with: attrString)
  }

  func insertNewline(_ source: Node) {
    precondition(isEditing)
    // obtain style properties
    let properties: TextProperty = source.resolveAggregate(styleSheet)
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
    let properties: TextProperty = source.resolveAggregate(styleSheet)
    let attributes = properties.getAttributes()
    // form attributed string
    let attrString = Self.attributedString(for: fragment, attributes)
    // update state
    let location = NSRange(location: layoutCursor, length: 0)
    textStorage.replaceCharacters(in: location, with: attrString)
  }

  /// Wrap given fragment in text attachment which is further embedded in an
  /// attributed string
  private static func attributedString(
    for fragment: any LayoutFragment,
    _ attributes: Dictionary<NSAttributedString.Key, Any>
  ) -> NSAttributedString {
    let attachment = LayoutFragmentAttachment(fragment)
    if #available(macOS 15.0, *) {
      return NSAttributedString(attachment: attachment, attributes: attributes)
    }
    else {
      return NSAttributedString(attachment: attachment)
    }
  }

  // MARK: - Edit

  func skipForward(_ n: Int) {
    precondition(isEditing && n >= 0)
    layoutCursor += n
  }

  func deleteForward(_ n: Int) {
    precondition(isEditing && n >= 0)
    let range = NSRange(location: layoutCursor, length: n)
    textStorage.replaceCharacters(in: range, with: "")
    // cursor remains unchanged.
  }

  func invalidateForward(_ n: Int) {
    precondition(isEditing && n >= 0)
    // find character range
    let range = NSRange(location: layoutCursor, length: n)
    // find text range
    guard let textRange = textContentStorage.textRange(for: range)
    else { assertionFailure("text range not found"); return }
    // update state
    textLayoutManager.invalidateLayout(for: textRange)
    // update layout cursor no matter what
    layoutCursor += n
  }

  func insertTextForward(_ text: some Collection<Character>, _ source: Node) {
    precondition(isEditing)
    guard !text.isEmpty else { return }
    // obtain style properties
    let properties: TextProperty = source.resolveAggregate(styleSheet)
    let attributes = properties.getAttributes()
    // create attributed string
    let attrString = NSAttributedString(string: String(text), attributes: attributes)
    // update state
    textStorage.insert(attrString, at: layoutCursor)
    layoutCursor += attrString.length
  }

  func insertNewlineForward(_ context: Node) {
    precondition(isEditing)
    // obtain style properties
    let properties: TextProperty = context.resolveAggregate(styleSheet)
    let attributes = properties.getAttributes()
    // create attributed string
    let attrString = NSAttributedString(string: "\n", attributes: attributes)
    assert(attrString.length == 1)
    // update state
    textStorage.insert(attrString, at: layoutCursor)
    layoutCursor += attrString.length
  }

  func insertFragmentForward(_ fragment: any LayoutFragment, _ source: Node) {
    precondition(isEditing)
    // obtain style properties
    let properties: TextProperty = source.resolveAggregate(styleSheet)
    let attributes = properties.getAttributes()
    // form attributed string
    let attrString = Self.attributedString(for: fragment, attributes)
    assert(attrString.length == fragment.layoutLength)
    // update state
    textStorage.insert(attrString, at: layoutCursor)
    layoutCursor += attrString.length
  }

  // MARK: - Frame

  func getSegmentFrame(
    _ layoutOffset: Int, _ affinity: SelectionAffinity
  ) -> SegmentFrame? {
    precondition(isEditing == false)

    guard let location = textContentStorage.textLocation(for: layoutOffset)
    else { return nil }
    let textRange = NSTextRange(location: location)

    let options: DocumentManager.SegmentOptions =
      affinity == .upstream ? .upstreamAffinity : []

    var result: SegmentFrame? = nil
    textLayoutManager.enumerateTextSegments(
      in: textRange, type: .standard, options: [.rangeNotRequired, options]
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
    precondition(isEditing == false)

    let charRange = NSRange(location: layoutRange.lowerBound, length: layoutRange.count)
    guard let textRange = textContentStorage.textRange(for: charRange)
    else { return false }

    var shouldContinue = false
    textLayoutManager.enumerateTextSegments(in: textRange, type: type, options: options) {
      (textRange, segmentFrame, baselinePosition, _) in
      if let textRange = textRange {
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

  func getLayoutRange(interactingAt point: CGPoint) -> PickingResult? {
    precondition(isEditing == false)

    // special case: if content is empty, return empty range
    // reason: `textSelections(...)` will return an empty selection.
    guard textContentStorage.documentRange.isEmpty == false else {
      return PickingResult(0..<0, 1.0, .downstream)
    }

    func characterIndex(for point: CGPoint) -> (Int, SelectionAffinity)? {
      let selections = textLayoutManager.textSelectionNavigation.textSelections(
        interactingAt: point, inContainerAt: textLayoutManager.documentRange.location,
        anchors: [], modifiers: [], selecting: false,
        bounds: textLayoutManager.usageBoundsForTextContainer)
      guard let selection = selections.getOnlyElement(),
        let textRange = selection.textRanges.getOnlyElement(),
        textRange.isEmpty
      else { return nil }
      let index = textContentStorage.characterIndex(for: textRange.location)
      return (index, selection.affinity)
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

    guard let (charIndex, affinity) = characterIndex(for: point),
      let charRange = characterRange(for: point)
    else { return nil }

    let fraction = fractionOfDistanceThroughGlyph(for: point) ?? 0.51

    if charIndex == charRange.upperBound {
      return PickingResult(charRange, 1.0, affinity)
    }
    else {
      return PickingResult(charRange, fraction, affinity)
    }
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
    from layoutOffset: Int,
    affinity: SelectionAffinity,
    direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    precondition(isEditing == false)

    guard let segmentFrame = getSegmentFrame(layoutOffset, affinity) else { return nil }

    let usageBounds = textLayoutManager.usageBoundsForTextContainer
    let lineFrame =
      self.neighbourLineFrame(
        from: layoutOffset, affinity: affinity, direction: direction)?.frame
      ?? usageBounds

    switch direction {
    case .up:
      let x = segmentFrame.frame.origin.x
      let y = segmentFrame.frame.minY.clamped(lineFrame.minY, lineFrame.maxY)
      // if we are about to go beyond the top edge, resolved = false
      let resolved = !y.isNearlyEqual(to: usageBounds.minY)
      return RayshootResult(CGPoint(x: x, y: y), resolved)

    case .down:
      let x = segmentFrame.frame.origin.x
      let y = segmentFrame.frame.maxY.clamped(lineFrame.minY, lineFrame.maxY)
      // if we are about to go beyond the bottom edge, resolved = false
      let resolved = !y.isNearlyEqual(to: usageBounds.maxY)
      return RayshootResult(CGPoint(x: x, y: y), resolved)

    default:
      assertionFailure("unexpected direction")
      return nil
    }
  }

  func neighbourLineFrame(
    from layoutOffset: Int,
    affinity: SelectionAffinity,
    direction: TextSelectionNavigation.Direction
  ) -> SegmentFrame? {
    guard let textLocation = textContentStorage.textLocation(for: layoutOffset)
    else { return nil }

    let selection = NSTextSelection(textLocation, affinity: affinity)

    guard
      let target = textLayoutManager.textSelectionNavigation.destinationSelection(
        for: selection, direction: direction, destination: .character,
        extending: false, confined: false),
      let targetLocation = target.textRanges.first?.location
    else { return nil }

    let targetOffset = textContentStorage.characterIndex(for: targetLocation)
    return getSegmentFrame(targetOffset, target.affinity)
  }
}
