// Copyright 2024-2025 Lie Yan

import AppKit

extension DocumentView: @preconcurrency NSTextLayoutManagerDelegate {
  public func textLayoutManager(
    _ textLayoutManager: NSTextLayoutManager,
    textLayoutFragmentFor location: NSTextLocation, in textElement: NSTextElement
  ) -> NSTextLayoutFragment {

    if let textElement = textElement as? NSTextParagraph {
      let attrString = textElement.attributedString
      let attributes = attrString.attributes(at: 0, effectiveRange: nil)

      if let level = attributes[.listLevel] as? Int,
        level > 0,
        let indent = attributes[.listIndent] as? CGFloat,
        let itemMarker = attributes[.itemMarker] as? NSAttributedString
      {
        let fragment = ListItemTextLayoutFragment(
          textElement: textElement, range: textElement.elementRange,
          itemMarker: itemMarker, indent: indent)
        return fragment
      }
    }

    return NSTextLayoutFragment(textElement: textElement, range: textElement.elementRange)
  }
}
