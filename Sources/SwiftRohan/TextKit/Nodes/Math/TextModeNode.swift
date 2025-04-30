// Copyright 2024-2025 Lie Yan

import CoreText
import Foundation
import _RopeModule

final class TextModeNode: ElementNode {
  override class var type: NodeType { .textMode }

  // MARK: - Clone and Visitor

  override public func deepCopy() -> Self { Self(deepCopyOf: self) }
  override func cloneEmpty() -> Self { Self() }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(textMode: self, context)
  }

  // MARK: - Styles

  override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      var properties = super.getProperties(styleSheet)

      let mathContext = MathUtils.resolveMathContext(for: self, styleSheet)
      let fontSize = FontSize(rawValue: mathContext.getFont().size)

      properties[TextProperty.size] = .fontSize(fontSize)

      _cachedProperties = properties
    }
    return _cachedProperties!
  }

  // MARK: - Layout

  private var _textModeFragment: TextModeLayoutFragment? = nil

  override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    precondition(context is MathListLayoutContext)
    let context = context as! MathListLayoutContext

    if fromScratch {
      let textStorage = NSMutableAttributedString()
      let ctLine = CTLineCreateWithAttributedString(textStorage)
      let subContext = TextLineLayoutContext(context.styleSheet, textStorage, ctLine)

      // layout content
      super.performLayout(subContext, fromScratch: true)

      // set fragment
      let fragment = TextModeLayoutFragment(subContext.textStorage, subContext.ctLine)
      _textModeFragment = fragment

      context.insertFragment(fragment, self)
    }
    else {
      guard var fragment = _textModeFragment
      else {
        assertionFailure("Accent fragment is nil")
        return
      }

      var needsFixLayout = false

      if isDirty {
        let bounds = fragment.bounds

        // layout nucleus
        let subContext = TextLineLayoutContext(context.styleSheet, fragment)
        super.performLayout(subContext, fromScratch: false)

        // set fragment
        fragment = TextModeLayoutFragment(subContext.textStorage, subContext.ctLine)
        _textModeFragment = fragment

        // check if the bounds has changed
        if fragment.bounds.isNearlyEqual(to: bounds) == false {
          needsFixLayout = true
        }
      }

      if needsFixLayout {
        context.invalidateBackwards(layoutLength())
      }
      else {
        context.skipBackwards(layoutLength())
      }
    }
  }

  override func enumerateTextSegments(
    _ path: ArraySlice<RohanIndex>, _ endPath: ArraySlice<RohanIndex>,
    _ context: any LayoutContext, layoutOffset: Int, originCorrection: CGPoint,
    type: DocumentManager.SegmentType, options: DocumentManager.SegmentOptions,
    using block: (RhTextRange?, CGRect, CGFloat) -> Bool
  ) -> Bool {
    precondition(_textModeFragment != nil && context is MathListLayoutContext)

    guard let fragment = _textModeFragment
    else {
      assertionFailure("Text mode fragment is nil")
      return false
    }

    let newContext = TextLineLayoutContext(context.styleSheet, fragment)

    // obtain super frame with given layout offset;
    // affinity doesn't matter for math layout
    guard let superFrame = context.getSegmentFrame(for: layoutOffset, .downstream)
    else { return false }

    // set new layout offset
    let layoutOffset = 0

    // compute new origin correction
    let originCorrection: CGPoint =
      originCorrection.translated(by: superFrame.frame.origin)
      .with(yDelta: superFrame.baselinePosition)  // relative to glyph origin of super frame
      .with(yDelta: -fragment.ascent)  // relative to top-left corner of fragment

    return super.enumerateTextSegments(
      path, endPath, newContext, layoutOffset: layoutOffset,
      originCorrection: originCorrection, type: type, options: options, using: block)
  }

  override func resolveTextLocation(
    with point: CGPoint, _ context: any LayoutContext, _ trace: inout Trace,
    _ affinity: inout RhTextSelection.Affinity
  ) -> Bool {
    precondition(_textModeFragment != nil && context is MathListLayoutContext)

    guard let fragment = _textModeFragment
    else {
      assertionFailure("Text mode fragment is nil")
      return false
    }

    let newContext = TextLineLayoutContext(context.styleSheet, fragment)
    let topLeftCorner = fragment.glyphOrigin.with(yDelta: -fragment.ascent)
    let newPoint = point.relative(to: topLeftCorner)

    return super.resolveTextLocation(with: newPoint, newContext, &trace, &affinity)
  }

  override func rayshoot(
    from path: ArraySlice<RohanIndex>, affinity: RhTextSelection.Affinity,
    direction: TextSelectionNavigation.Direction, context: any LayoutContext,
    layoutOffset: Int
  ) -> RayshootResult? {
    precondition(_textModeFragment != nil && context is MathListLayoutContext)

    guard let fragment = _textModeFragment
    else {
      assertionFailure("Text mode fragment is nil")
      return nil
    }

    let newContext = TextLineLayoutContext(context.styleSheet, fragment)
    let newLayoutOffset = 0

    guard
      let result = super.rayshoot(
        from: path, affinity: affinity, direction: direction, context: newContext,
        layoutOffset: newLayoutOffset)
    else {
      return nil
    }

    let correctedPosition = result.position.translated(by: fragment.glyphOrigin)
    return result.with(position: correctedPosition)
  }
}
