// Copyright 2024-2025 Lie Yan

import AppKit

extension DocumentManager: NSTextLayoutManagerDelegate {
  public func textLayoutManager(
    _ textLayoutManager: NSTextLayoutManager,
    textLayoutFragmentFor location: NSTextLocation, in textElement: NSTextElement
  ) -> NSTextLayoutFragment {

    // Empty check is necessary to avoid range exception.
    if textLayoutManager.documentRange.isEmpty == false,
      let textElement = textElement as? NSTextParagraph
    {
      let attrString = textElement.attributedString
      @inline(__always)
      func attribute(forKey key: NSAttributedString.Key) -> Any? {
        attrString.attribute(key, at: 0, effectiveRange: nil)
      }

      if let listLevel = attribute(forKey: .rhListLevel) as? Int,
        listLevel > 0,  // list level must be greater than 0.
        let indent = attribute(forKey: .rhHeadIndent) as? CGFloat,
        let itemMarker = attribute(forKey: .rhItemMarker) as? NSAttributedString
      {
        let fragment = ListItemTextLayoutFragment(
          textElement: textElement, range: textElement.elementRange,
          itemMarker: itemMarker, indent: indent)
        return fragment
      }
      else if let equationNumber =
        attribute(forKey: .rhEquationNumber) as? NSAttributedString,
        let horizontalBounds = attribute(forKey: .rhHorizontalBounds) as? HorizontalBounds
      {
        let fragment = EquationTextLayoutFragment(
          textElement: textElement, range: textElement.elementRange,
          equationNumber: equationNumber, horizontalBounds: horizontalBounds)
        return fragment
      }
    }

    return NSTextLayoutFragment(textElement: textElement, range: textElement.elementRange)
  }
}
