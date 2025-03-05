// Copyright 2025 Lie Yan

import AppKit
import Foundation

extension TextView: NSTextInputClient {
  private func textInputDidChange() {
    // NOTE: It's important to reconcile content storage otherwise non-TextKit
    //  layout may be delayed until next layout cycle, which may lead to unexpected
    //  behavior, eg., `firstRect(...)` may return wrong rect
    documentManager.reconcileContentStorage()
    needsLayout = true
  }

  // MARK: - Insert Text

  public func insertText(_ string: Any, replacementRange: NSRange) {
    defer {
      assert(_markedText == nil)
      textInputDidChange()
    }

    // get target text range
    let targetTextRange: RhTextRange
    if let markedText = _markedText {
      if replacementRange.location != NSNotFound {
        guard let textRange = markedText.textRange(for: replacementRange)
        else { _unmarkText(); return }
        targetTextRange = textRange
      }
      else {
        guard let textRange = markedText.markedTextRange() else { _unmarkText(); return }
        targetTextRange = textRange
      }
    }
    else {
      // get current selection
      guard let textRange = documentManager.textSelection?.effectiveRange else { return }
      targetTextRange = textRange
    }

    // ensure marked text is cleared
    _markedText = nil

    // get attributed string
    let attrString: NSAttributedString
    switch string {
    case let string as String:
      attrString = NSAttributedString(string: string)
    case let attributedString as NSAttributedString:
      attrString = attributedString
    default:
      assertionFailure("unknown string type: \(Swift.type(of: string))")
      return
    }

    do {
      let newLocation =
        try documentManager.replaceCharacters(in: targetTextRange, with: attrString.string)
        ?? targetTextRange.location
      // update selection
      let insertionPoint = newLocation.with(offsetDelta: attrString.length)
      documentManager.textSelection = RhTextSelection(insertionPoint)
    }
    catch { return }
  }

  // MARK: - Mark Text
  public func setMarkedText(_ string: Any, selectedRange: NSRange, replacementRange: NSRange) {
    defer {
      self.textInputDidChange()

      // log marked text
      if DebugConfig.LOG_MARKED_TEXT {
        if let markedText = _markedText {
          Rohan.logger.debug("marked text: \(markedText.debugDescription)")
        }
        else {
          Rohan.logger.debug("marked text: none")
        }
      }
    }

    let attrString: NSAttributedString
    switch string {
    case let string as String:
      attrString = NSAttributedString(string: string)
    case let attributedString as NSAttributedString:
      attrString = attributedString
    default:  // unknown type
      return
    }

    guard let markedText = _markedText else {
      assert(replacementRange.location == NSNotFound)
      // get current selection
      guard let textRange = documentManager.textSelection?.effectiveRange else { return }
      do {
        // perform edit
        let newLocation =
          try documentManager.replaceCharacters(in: textRange, with: attrString.string)
          ?? textRange.location
        // update marked text
        let markedRange = NSRange(location: 0, length: attrString.length)
        _markedText = MarkedText(
          documentManager, newLocation, markedRange: markedRange, selectedRange: selectedRange)
        // update selection
        guard let selectedTextRange = _markedText!.selectedTextRange() else { return }
        documentManager.textSelection = RhTextSelection(selectedTextRange)
      }
      catch { return }
      return
    }

    let markedLocation: Int
    let replacementTextRange: RhTextRange
    if replacementRange.location != NSNotFound {
      markedLocation = replacementRange.location
      guard let textRange = markedText.textRange(for: replacementRange) else { return }
      replacementTextRange = textRange
    }
    else {  // fix replacement range
      markedLocation = markedText.markedRange.location
      guard let markedTextRange = markedText.markedTextRange() else { return }
      replacementTextRange = markedTextRange
    }
    // set marked text
    let markedRange = NSRange(location: markedLocation, length: attrString.length)
    let selectedRange = NSRange(
      location: markedLocation + selectedRange.location, length: selectedRange.length)
    // perform edit
    do {
      _ = try documentManager.replaceCharacters(in: replacementTextRange, with: attrString.string)
      // update marked text
      _markedText = markedText.with(markedRange: markedRange, selectedRange: selectedRange)
      // update selection
      guard let selectedTextRange = _markedText!.selectedTextRange() else { return }
      documentManager.textSelection = RhTextSelection(selectedTextRange)
    }
    catch {
      return
    }
  }

  private func _unmarkText() {
    // finally unmark text
    defer { _markedText = nil }
    // ensure marked text
    guard let markedText = _markedText,
      let textRange = markedText.markedTextRange()
    else { return }
    // perform edit and keep new insertion point
    let location =
      (try? documentManager.replaceCharacters(in: textRange, with: ""))
      ?? textRange.location
    // update selection
    documentManager.textSelection = RhTextSelection(location)
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
    guard let markedText = _markedText,
      // convert to window coordinate
      let windowPoint = window?.convertPoint(fromScreen: point)
    else { return NSNotFound }
    // convert to content view coordinate
    let point = contentView.convert(windowPoint, from: nil)
    // get text location
    guard let location = documentManager.resolveTextLocation(interactingAt: point)
    else { return NSNotFound }
    return documentManager.llOffset(from: markedText.location, to: location) ?? NSNotFound
  }

  public func firstRect(forCharacterRange range: NSRange, actualRange: NSRangePointer?) -> NSRect {
    guard let markedText = _markedText,
      let textRange = markedText.textRange(for: range)
    else { return .zero }
    // convert to screen rect
    var screenRect = NSRect.zero
    documentManager.enumerateTextSegments(
      in: textRange, type: .standard, options: .rangeNotRequired
    ) { (_, textSegmentFrame, _) in
      let viewRect = contentView.convert(textSegmentFrame, to: nil)
      screenRect = window?.convertToScreen(viewRect) ?? .zero
      return false  // stop enumeration
    }
    return screenRect
  }
}
