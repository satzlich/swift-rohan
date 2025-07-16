// Copyright 2024-2025 Lie Yan

import AppKit

extension DocumentManager: NSTextLayoutManagerDelegate {
  public func textLayoutManager(
    _ textLayoutManager: NSTextLayoutManager,
    textLayoutFragmentFor location: NSTextLocation, in textElement: NSTextElement
  ) -> NSTextLayoutFragment {

    // WARNING: Empty check is necessary to avoid range exception.
    if textLayoutManager.documentRange.isEmpty == false,
      let textElement = textElement as? NSTextParagraph
    {
      let attrString = textElement.attributedString

      @inline(__always)
      func attribute(forKey key: NSAttributedString.Key) -> Any? {
        attrString.attribute(key, at: 0, effectiveRange: nil)
      }

      var decorators: Array<FragmentDecorator> = []

      if let listLevel = attribute(forKey: .rhListLevel) as? Int,
        listLevel > 0,  // list level must be greater than 0.
        let indent = attribute(forKey: .rhHeadIndent) as? CGFloat,
        let itemMarker = attribute(forKey: .rhItemMarker) as? NSAttributedString
      {
        let decorator =
          ItemMarkerFragmentDecorator(itemMarker: itemMarker, indent: indent)
        decorators.append(decorator)
      }

      if let equationNumber = attribute(forKey: .rhEquationNumber) as? NSAttributedString,
        let horizontalBounds = attribute(forKey: .rhHorizontalBounds) as? HorizontalBounds
      {
        let decorator = EquationNumberFragmentDecorator(
          equationNumber: equationNumber, horizontalBounds: horizontalBounds)
        decorators.append(decorator)
      }

      if let verticalRibbon = attribute(forKey: .rhVerticalRibbon) as? NSColor {
        let decorator = VerticalRibbonFragmentDecorator(color: verticalRibbon)
        decorators.append(decorator)
      }

      if decorators.isEmpty == false {
        return DecoratedTextLayoutFragment(
          textElement: textElement, range: textElement.elementRange,
          decorators: decorators)
      }
      // FALL THROUGH: No decorators found, return a standard fragment.
    }

    return NSTextLayoutFragment(textElement: textElement, range: textElement.elementRange)
  }
}
