// Copyright 2024-2025 Lie Yan

import AppKit

final class TextLayoutContext: LayoutContext {
  let styleSheet: StyleSheet
  let textContentStorage: NSTextContentStorage
  let textLayoutManager: NSTextLayoutManager

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

    // find text range
    let location = layoutCursor - n
    let characterRange = NSRange(location: location, length: n)
    guard let textRange = textContentStorage.textRange(for: characterRange)
    else { preconditionFailure("text range not found") }

    // update state
    textContentStorage.replaceContents(in: textRange, with: nil)
    layoutCursor = location
  }

  func invalidateBackwards(_ n: Int) {
    precondition(isEditing && n >= 0 && layoutCursor >= n)

    // find text range
    let location = layoutCursor - n
    let characterRange = NSRange(location: location, length: n)
    guard let textRange = textContentStorage.textRange(for: characterRange)
    else { preconditionFailure("text range not found") }

    // update state
    textLayoutManager.invalidateLayout(for: textRange)
    layoutCursor = location
  }

  func insertText(_ textNode: TextNode) {
    precondition(isEditing)

    guard textNode.stringLength > 0 else { return }

    // find text location
    guard let location = textContentStorage.textLocation(for: layoutCursor)
    else { preconditionFailure("text location not found") }
    // styles
    let properties = textNode.resolveProperties(styleSheet) as TextProperty
    // create text element
    let attributedString = NSAttributedString(
      string: String(textNode.bigString), attributes: properties.attributes())
    let textElement = NSTextParagraph(attributedString: attributedString)

    // update state
    textContentStorage.replaceContents(in: NSTextRange(location: location), with: [textElement])
  }

  func insertNewline(_ context: Node) {
    precondition(isEditing)

    // find text location
    guard let location = textContentStorage.textLocation(for: layoutCursor)
    else { preconditionFailure("text location not found") }

    // styles
    let properties = (context.resolveProperties(styleSheet) as TextProperty)

    // create text element
    let attributedString = NSAttributedString(string: "\n", attributes: properties.attributes())
    assert(attributedString.length == 1)

    let textElement = NSTextParagraph(attributedString: attributedString)

    // update state
    textContentStorage.replaceContents(in: NSTextRange(location: location), with: [textElement])
  }

  func insertFragment(_ fragment: any LayoutFragment, _ source: Node) {
    precondition(isEditing)

    // find text location
    guard let location = textContentStorage.textLocation(for: layoutCursor)
    else { preconditionFailure("text location not found") }

    // create text element
    let attributes = (source.resolveProperties(styleSheet) as TextProperty).attributes()
    let textElement: NSTextParagraph
    switch fragment {
    case let mathListLayoutFragment as MathListLayoutFragment:
      textElement = Self.createTextElement(for: mathListLayoutFragment, attributes)
    default:
      let attributedString = NSAttributedString(string: "$", attributes: attributes)
      textElement = NSTextParagraph(attributedString: attributedString)
    }

    if source.layoutLength > 1 {
      let zwsp = Self.createZWSP(count: source.layoutLength - 1, attributes)
      // update state
      textContentStorage.replaceContents(
        in: NSTextRange(location: location), with: [zwsp, textElement])
    }
    else {
      // update state
      textContentStorage.replaceContents(in: NSTextRange(location: location), with: [textElement])
    }
  }

  private static func createTextElement(
    for fragment: MathListLayoutFragment, _ attributes: [NSAttributedString.Key: Any]
  ) -> NSTextParagraph {
    let attachment = MathListLayoutAttachment(fragment)

    let attributedString: NSAttributedString
    if #available(macOS 15.0, *) {
      attributedString = NSAttributedString(attachment: attachment, attributes: attributes)
    }
    else {
      // Fallback on earlier versions
      let attributedString_ = NSMutableAttributedString(attachment: attachment)
      let range = NSRange(location: 0, length: attributedString_.length)
      attributedString_.setAttributes(attributes, range: range)
      attributedString = attributedString_
    }
    return NSTextParagraph(attributedString: attributedString)
  }

  private static func createZWSP(
    count: Int, _ attributes: [NSAttributedString.Key: Any]
  ) -> NSTextParagraph {
    let string = String(repeating: "\u{200B}", count: count)
    let attributedString = NSAttributedString(string: string, attributes: attributes)
    return NSTextParagraph(attributedString: attributedString)
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

    var completed = false
    textLayoutManager.enumerateTextSegments(in: textRange, type: type, options: options) {
      (textRange, segmentFrame, baselinePosition, _) in
      if let textRange {
        let charRange = textContentStorage.characterRange(for: textRange)
        if charRange.location != NSNotFound {
          let range = charRange.lowerBound..<charRange.upperBound
          completed = block(range, segmentFrame, baselinePosition)
          return completed
        }
        // FALL THROUGH
      }
      completed = block(nil, segmentFrame, baselinePosition)
      return completed
    }
    return completed
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

  /** The fraction of distance from the upstream edge */
  private func fractionOfDistanceThroughGlyph(for point: CGPoint) -> Double? {
    guard let textLayoutFragment = textLayoutManager.textLayoutFragment(for: point)
    else { return nil }
    // relative point to the layout fragment
    let relPoint = point.relative(to: textLayoutFragment.layoutFragmentFrame.origin)
    // get text line fragment
    let textLineFragment = textLayoutFragment.textLineFragment(
      forVerticalOffset: relPoint.y, requiresExactMatch: false)
    guard let textLineFragment else { return nil }
    // relative point to the text line fragment
    let relPoint_: CGPoint = relPoint.relative(to: textLineFragment.glyphOrigin)
    // compute fraction
    return textLineFragment.fractionOfDistanceThroughGlyph(for: relPoint_)
  }
}
