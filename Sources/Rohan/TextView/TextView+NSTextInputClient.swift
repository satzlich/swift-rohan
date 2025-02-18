// Copyright 2025 Lie Yan

import AppKit
import Foundation

extension TextView: NSTextInputClient {
  private func textInputDidChange() {
    documentManager.ensureLayout(delayed: true)
    needsLayout = true
    needsDisplay = true
  }

  // MARK: - Insert Text

  public func insertText(_ string: Any, replacementRange: NSRange) {
    // always unmark
    _unmarkText()
    defer { textInputDidChange() }

    let str: String
    switch string {
    case let string as String:
      str = string
    case let attributedString as NSAttributedString:
      str = attributedString.string
    default:  // unknown type
      return
    }

    let replacementTextRange: RhTextRange
    if replacementRange.location == NSNotFound {
      // get current selection
      guard let textSelection = documentManager.textSelection,
        let textRange = textSelection.textRanges.first
      else { return }
      replacementTextRange = textRange
    }
    else {
      return
    }

    do {
      let newLocation =
        try documentManager.replaceCharacters(in: replacementTextRange, with: str)
        ?? replacementTextRange.location
      // update selection
      let newSelection = RhTextRange(newLocation.with(offsetDelta: str.count))
      documentManager.textSelection = RhTextSelection(textRanges: [newSelection])
    }
    catch {
      return
    }
  }

  // MARK: - Mark Text
  public func setMarkedText(
    _ string: Any, selectedRange: NSRange, replacementRange: NSRange
  ) {
    defer {
      textInputDidChange()

      // log marked text
      if DebugConfig.LOG_MARKED_TEXT {
        if let markedText = _markedText {
          Rohan.logger.debug("\(markedText.debugDescription)")
        }
        else {
          Rohan.logger.debug("No marked text")
        }
      }
    }

    let str: String
    switch string {
    case let string as String:
      str = string
    case let attributedString as NSAttributedString:
      str = attributedString.string
    default:  // unknown type
      return
    }

    guard let markedText = _markedText else {
      assert(replacementRange.location == NSNotFound)
      // get current selection
      guard let textSelection = documentManager.textSelection,
        let textRange = textSelection.textRanges.first
      else { return }
      do {
        // perform edit
        let newLocation =
          try documentManager.replaceCharacters(in: textRange, with: str)
          ?? textRange.location
        // update marked text
        let markedRange = NSRange(location: 0, length: str.utf16.count)
        let selectedRange = NSRange(location: selectedRange.location, length: selectedRange.length)
        _markedText = MarkedText(
          documentManager, newLocation, markedRange: markedRange, selectedRange: selectedRange)
        // update selection
        guard let selectedTextRange = _markedText!.selectedTextRange() else { return }
        documentManager.textSelection = RhTextSelection(textRanges: [selectedTextRange])
      }
      catch {
        return
      }
      return
    }

    let markLocation: Int
    let replacementTextRange: RhTextRange
    if replacementRange.location != NSNotFound {
      markLocation = replacementRange.location
      guard let textRange = markedText.textRange(for: replacementRange) else { return }
      replacementTextRange = textRange
    }
    else {  // fix replacement range
      markLocation = markedText.markedRange.location
      guard let markedTextRange = markedText.markedTextRange() else { return }
      replacementTextRange = markedTextRange
    }
    // set marked text
    let markedRange = NSRange(location: markLocation, length: str.utf16.count)
    let selectedRange = NSRange(
      location: markLocation + selectedRange.location, length: selectedRange.length)
    // perform edit
    do {
      let newLocation =
        try documentManager.replaceCharacters(in: replacementTextRange, with: str)
        ?? replacementTextRange.location
      // update marked text
      _markedText = markedText.with(markedRange: markedRange, selectedRange: selectedRange)
      // update selection
      guard let selectedTextRange = _markedText!.selectedTextRange() else { return }
      documentManager.textSelection = RhTextSelection(textRanges: [selectedTextRange])
    }
    catch {
      return
    }
  }

  private func _unmarkText() {
    defer { _markedText = nil }
    if let markedText = _markedText,
      let textRange = markedText.markedTextRange()
    {
      do {
        let newLocation =
          try documentManager.replaceCharacters(in: textRange, with: "")
          ?? textRange.location
        // update selection
        let newSelection = RhTextRange(newLocation)
        documentManager.textSelection = RhTextSelection(textRanges: [newSelection])
      }
      catch {
        return
      }
    }
  }

  public func unmarkText() {
    _unmarkText()
    textInputDidChange()
  }

  public func hasMarkedText() -> Bool {
    _markedText != nil
  }

  public func markedRange() -> NSRange {
    guard let markedText = _markedText
    else { return NSRange(location: NSNotFound, length: 0) }
    return markedText.markedRange
  }

  // MARK: - Selected Range

  public func selectedRange() -> NSRange {
    guard let markedText = _markedText
    else { return NSRange(location: NSNotFound, length: 0) }
    return markedText.selectedRange
  }

  // MARK: - Query Attributed String

  public func attributedSubstring(
    forProposedRange range: NSRange, actualRange: NSRangePointer?
  ) -> NSAttributedString? {
    guard let markedText = _markedText else { return nil }
    let range = range.clamped(to: markedText.markedRange)
    actualRange?.pointee = range
    return markedText.attributedSubstring(for: range)
  }

  public func validAttributesForMarkedText() -> [NSAttributedString.Key] {
    [
      .underlineColor,
      .underlineStyle,
      .markedClauseSegment,
    ]
  }

  // MARK: - Query Index / Coordinate

  public func characterIndex(for point: NSPoint) -> Int {
    guard let markedText = _markedText else { return NSNotFound }
    // convert to content view coordinate
    let windowPoint = window!.convertPoint(fromScreen: point)
    let point = contentView.convert(windowPoint, from: nil)
    // get text location
    guard let location = documentManager.getTextLocation(interactingAt: point)
    else { return NSNotFound }
    return documentManager.llOffset(from: markedText.location, to: location) ?? NSNotFound
  }

  public func firstRect(forCharacterRange range: NSRange, actualRange: NSRangePointer?) -> NSRect {
    func convertToScreenRect(_ textRange: RhTextRange) -> NSRect {
      var screenRect = NSRect.zero
      documentManager.enumerateTextSegments(
        in: textRange, type: .standard, options: .rangeNotRequired
      ) { (_, textSegmentFrame, _) in
        let viewRect = contentView.convert(textSegmentFrame, to: nil)
        screenRect = window!.convertToScreen(viewRect)
        return false  // stop
      }
      return screenRect
    }
    guard let markedText = _markedText else { return .zero }
    guard let textRange = markedText.textRange(for: range) else { return .zero }
    return convertToScreenRect(textRange)
  }
}
