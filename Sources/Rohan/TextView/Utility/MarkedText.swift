// Copyright 2025 Lie Yan

import Foundation

struct MarkedText: CustomDebugStringConvertible {
  private let documentManager: DocumentManager
  let location: TextLocation
  let markedRange: NSRange
  let selectedRange: NSRange

  init(
    _ documentManager: DocumentManager, _ location: TextLocation,
    markedRange: NSRange, selectedRange: NSRange
  ) {
    self.documentManager = documentManager
    self.location = location
    self.markedRange = markedRange
    self.selectedRange = selectedRange
  }

  func with(markedRange: NSRange, selectedRange: NSRange) -> MarkedText {
    MarkedText(documentManager, location, markedRange: markedRange, selectedRange: selectedRange)
  }

  func selectedTextRange() -> RhTextRange? {
    textRange(for: selectedRange)
  }

  func markedTextRange() -> RhTextRange? {
    textRange(for: markedRange)
  }

  func textRange(for range: NSRange) -> RhTextRange? {
    guard let location = documentManager.location(self.location, llOffsetBy: range.location),
      let end = documentManager.location(location, llOffsetBy: range.length)
    else { return nil }
    return RhTextRange(location, end)
  }

  func attributedSubstring(for range: NSRange) -> NSAttributedString? {
    guard let textRange = textRange(for: range) else { return nil }
    return documentManager.attributedSubstring(for: textRange)
  }

  var debugDescription: String {
    "location: \(location), markedRange: \(markedRange), selectedRange: \(selectedRange)"
  }
}
