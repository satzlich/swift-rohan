// Copyright 2024-2025 Lie Yan

import AppKit

final class TextLayoutContext: LayoutContext, SegmentContext {
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

  /** current cursor location */
  private(set) var layoutCursor: Int

  /** `true` if the layout context is in the process of editing */
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

  func insertText(_ text: TextNode) {
    precondition(isEditing)

    // find text location
    guard let location = textContentStorage.textLocation(for: layoutCursor)
    else { preconditionFailure("text location not found") }
    // styles
    let properties = text.resolveProperties(styleSheet) as TextProperty
    // create text element
    let attributedString = NSAttributedString(
      string: text.getString(), attributes: properties.attributes())
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
    textContentStorage.replaceContents(
      in: NSTextRange(location: location),
      with: [textElement])
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

  func getSegmentFrame(_ layoutOffset: Int) -> SegmentFrame? {
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
  ) {
    let charRange = NSRange(location: layoutRange.lowerBound, length: layoutRange.count)
    guard let textRange = textContentStorage.textRange(for: charRange) else { return }
    textLayoutManager.enumerateTextSegments(in: textRange, type: type, options: options) {
      (textRange, segmentFrame, baselinePosition, _) in
      guard textRange != nil else { return block(nil, segmentFrame, baselinePosition) }
      let charRange = textContentStorage.characterRange(for: textRange!)
      if charRange.location != NSNotFound {
        let range = charRange.location..<charRange.location + charRange.length
        return block(range, segmentFrame, baselinePosition)
      }
      return block(nil, segmentFrame, baselinePosition)
    }
  }
}

typealias TextSegmentContext = TextLayoutContext
