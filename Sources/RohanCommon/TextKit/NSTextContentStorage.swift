// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension NSTextContentStorage {
  /** Convert text elements to attributed string */
  public func attributedString(for textElements: [NSTextElement]) -> NSAttributedString {
    let attrString = NSMutableAttributedString()
    attrString.beginEditing()
    textElements.lazy
      .compactMap(self.attributedString(for:))
      .forEach(attrString.append(_:))
    attrString.endEditing()
    return attrString
  }

  /** Convert text ranges to attributed string */
  public func attributedString(for textRanges: [NSTextRange]) -> NSAttributedString {
    // form character ranges
    let characterRanges = textRanges.map(characterRange(for:))
    assert(textStorage != nil)
    // form attributed string
    let mutableString = NSMutableAttributedString()
    mutableString.beginEditing()
    characterRanges.forEach { range in
      mutableString.append(textStorage!.attributedSubstring(from: range))
    }
    mutableString.endEditing()
    return mutableString
  }
}
