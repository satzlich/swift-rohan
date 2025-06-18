// Copyright 2024-2025 Lie Yan

import AppKit

extension DocumentView: @preconcurrency NSTextLayoutManagerDelegate {
  public func textLayoutManager(
    _ textLayoutManager: NSTextLayoutManager,
    textLayoutFragmentFor location: NSTextLocation, in textElement: NSTextElement
  ) -> NSTextLayoutFragment {
    NSTextLayoutFragment(textElement: textElement, range: textElement.elementRange)
  }
}
