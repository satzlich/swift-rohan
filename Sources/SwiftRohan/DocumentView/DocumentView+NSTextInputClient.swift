// Copyright 2025 Lie Yan

import AppKit
import Foundation
import _RopeModule

extension DocumentView: NSTextInputClient {

  // MARK: - Insert Text

  @objc public func insertText(_ string: Any, replacementRange: NSRange) {
    beginEditing()
    defer {
      assert(_markedText == nil)
      endEditing()
    }

    // prepare range

    let targetRange: RhTextRange  // range to replace

    if let markedText = _markedText {

      let initRange: RhTextRange  // initial range to replace

      if replacementRange.location != NSNotFound {
        guard let textRange = markedText.textRange(for: replacementRange)
        else { _unmarkText(); return }
        initRange = textRange
      }
      else {
        guard let markedRange = markedText.markedTextRange()
        else { _unmarkText(); return }
        initRange = markedRange
      }
      let result = replaceCharacters(in: initRange, with: "", registerUndo: false)
      guard let resultRange = result.success(),
        resultRange.isEmpty
      else { return }
      targetRange = resultRange
    }
    else {
      guard let textRange = documentManager.textSelection?.textRange else { return }
      targetRange = textRange
    }

    // reset marked text
    _markedText = nil

    // execute insertion
    if let string = getString(string),
      TextExpr.validate(string: string)
    {
      let result = replaceCharactersForEdit(in: targetRange, with: string)
      guard let insertionRange = result.success()
      else {
        assertionFailure("failed to insert text: \(string)")
        return
      }
      executeReplacementIfNeeded(for: string, at: insertionRange)
    }
    else {
      let result = replaceCharactersForEdit(in: targetRange, with: "")
      assert(result.isSuccess)
    }
  }

  // MARK: - Mark Text

  @objc public func setMarkedText(
    _ string: Any, selectedRange: NSRange, replacementRange: NSRange
  ) {
    beginEditing()
    defer { endEditing() }

    guard let replacement = getString(string) else { return }

    if let markedText = _markedText {

      let location: Int  // start location of marked text
      let replacementRange_: RhTextRange  // range to replace

      if replacementRange.location != NSNotFound {
        location = replacementRange.location
        guard let textRange = markedText.textRange(for: replacementRange)
        else { return }
        replacementRange_ = textRange
      }
      else {
        // fix replacement range
        location = markedText.markedRange.location
        guard let markedRange = markedText.markedTextRange() else { return }
        replacementRange_ = markedRange
      }

      let result =
        replaceCharacters(in: replacementRange_, with: replacement, registerUndo: false)

      guard let insertionRange = result.success()
      else {
        assertionFailure("failed to set marked text: \(replacement)")
        return
      }

      // compute new marked range and selected range
      let markedRange = NSRange(location: location, length: replacement.length)
      let selectedRange =
        NSRange(location: location + selectedRange.location, length: selectedRange.length)

      if markedRange.length == 0 {
        _markedText = nil
        // update selection
        documentManager.textSelection = RhTextSelection(insertionRange)
      }
      else {
        // update marked text
        _markedText = markedText.withRanges(marked: markedRange, selected: selectedRange)
        // update selection
        guard let selectedTextRange = _markedText!.selectedTextRange()
        else { return }
        documentManager.textSelection = RhTextSelection(selectedTextRange)
      }
    }
    else {
      assert(replacementRange.location == NSNotFound)
      guard let textRange = documentManager.textSelection?.textRange
      else { return }
      let result =
        replaceCharacters(in: textRange, with: replacement, registerUndo: false)

      guard let location = result.success()?.location
      else {
        assertionFailure("failed to set marked text: \(replacement)")
        return
      }

      let markedRange = NSRange(location: 0, length: replacement.length)
      _markedText = MarkedText(
        documentManager, location,
        markedRange: markedRange, selectedRange: selectedRange)

      guard let selectedTextRange = _markedText!.selectedTextRange()
      else { return }
      documentManager.textSelection = RhTextSelection(selectedTextRange)
    }
  }

  private func _unmarkText() {
    defer { _markedText = nil }

    guard let markedText = _markedText,
      let markedRange = markedText.markedTextRange()
    else { return }

    let result: ReplaceResult<RhTextRange> =
      replaceCharacters(in: markedRange, with: "", registerUndo: false)

    guard let insertionRange = result.success()
    else {
      assertionFailure("failed to unmark text")
      return
    }
    documentManager.textSelection = RhTextSelection(insertionRange)
  }

  @objc public func unmarkText() {
    beginEditing()
    defer { endEditing() }

    _unmarkText()
  }

  @objc public func hasMarkedText() -> Bool {
    _markedText != nil
  }

  @objc public func markedRange() -> NSRange {
    _markedText?.markedRange ?? .notFound
  }

  @objc public func selectedRange() -> NSRange {
    _markedText?.selectedRange ?? .notFound
  }

  // MARK: - Query Attributed String

  @objc public func attributedSubstring(
    forProposedRange range: NSRange, actualRange: NSRangePointer?
  ) -> NSAttributedString? {
    guard let markedText = _markedText else { return nil }

    let validRange = range.clamped(to: markedText.markedRange)
    actualRange?.pointee = validRange

    return markedText.attributedSubstring(for: validRange)
  }

  @objc public func validAttributesForMarkedText() -> [NSAttributedString.Key] {
    [
      .underlineColor,
      .underlineStyle,
      .markedClauseSegment,
    ]
  }

  // MARK: - Query Index / Coordinate

  @objc public func characterIndex(for point: NSPoint) -> Int {
    guard let markedText = _markedText,
      let window = window
    else { return NSNotFound }

    let point = contentView.convert(window.convertPoint(fromScreen: point), from: nil)

    guard let location = documentManager.resolveTextLocation(with: point)
    else { return NSNotFound }

    return documentManager.llOffset(from: markedText.location, to: location.value)
      ?? NSNotFound
  }

  @objc public func firstRect(
    forCharacterRange range: NSRange, actualRange: NSRangePointer?
  ) -> NSRect {
    guard let window = window,
      let markedText = _markedText,
      let textRange = markedText.textRange(for: range)
    else { return .zero }

    var screenRect = NSRect.zero
    documentManager.enumerateTextSegments(
      in: textRange, type: .standard, options: .rangeNotRequired
    ) { (_, textSegmentFrame, _) in
      screenRect = window.convertToScreen(contentView.convert(textSegmentFrame, to: nil))
      return false  // stop
    }
    return screenRect
  }
}

private func getString(_ string: Any) -> String? {
  switch string {
  case let string as String:
    return string
  case let attributedString as NSAttributedString:
    return attributedString.string
  default:
    assertionFailure("unknown string type: \(Swift.type(of: string))")
    return nil
  }
}
