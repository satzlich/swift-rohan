// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension NSTextContentManager {
  /// Replace text in multiple ranges
  func replaceContents(
    in ranges: [NSTextRange],
    with textElements: [NSTextElement]?
  ) {
    let ranges = ranges.sorted(by: { $0.location > $1.location })
    for range in ranges {
      replaceContents(in: range, with: textElements)
    }
  }
}
