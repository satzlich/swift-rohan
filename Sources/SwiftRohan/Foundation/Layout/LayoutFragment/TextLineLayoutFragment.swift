// Copyright 2024-2025 Lie Yan

import CoreGraphics
import CoreText
import Foundation
import TTFParser
import UnicodeMathClass

final class TextLineLayoutFragment: LayoutFragment {

  /// Rendered string.
  private(set) var attrString: NSMutableAttributedString
  private(set) var ctLine: CTLine
  private var _width: CGFloat = 0
  private var _ascent: CGFloat = 0
  private var _descent: CGFloat = 0

  let option: BoundsOption

  private(set) var originalString: String
  var resolvedString: String { attrString.string }

  enum BoundsOption {
    case imageBounds
    case typographicBounds
  }

  convenience init(
    _ attrString: NSMutableAttributedString, _ ctLine: CTLine, _ option: BoundsOption
  ) {
    self.init(attrString.string, attrString, ctLine, option)
  }

  init(
    _ string: String, _ attrString: NSMutableAttributedString, _ ctLine: CTLine,
    _ option: BoundsOption
  ) {
    self.originalString = string
    self.attrString = attrString
    self.ctLine = ctLine
    self.glyphOrigin = .zero
    self.option = option

    switch option {
    case .typographicBounds:
      self._width = ctLine.getTypographicBounds(&_ascent, &_descent, nil)
    case .imageBounds:
      self._width = ctLine.getImageBounds(&_ascent, &_descent)
    }
  }

  // MARK: - Frame

  private(set) var glyphOrigin: CGPoint

  func setGlyphOrigin(_ origin: CGPoint) {
    glyphOrigin = origin
  }

  // MARK: - Layout

  var layoutLength: Int { 1 }

  func draw(at point: CGPoint, in context: CGContext) {
    context.saveGState()
    context.translateBy(x: point.x, y: point.y)
    CTLineDraw(ctLine, context)
    context.restoreGState()
  }

  func fixLayout(_ mathContext: MathContext) {
    // no-op
  }

  // MARK: - Metrics

  var width: Double { _width }
  var height: Double { _ascent + _descent }
  var ascent: Double { _ascent }
  var descent: Double { _descent }
}

extension TextLineLayoutFragment {
  static func createTextMode(
    _ node: Node, _ styleSheet: StyleSheet, _ option: TextLineLayoutFragment.BoundsOption
  ) -> TextLineLayoutFragment {
    let context = TextLineLayoutContext(styleSheet)
    context.beginEditing()
    node.performLayout(context, fromScratch: true)
    context.endEditing()
    return TextLineLayoutFragment(context.renderedString, context.ctLine, option)
  }

  static func createMathMode(
    _ node: Node, _ styleSheet: StyleSheet, _ mathContext: MathContext,
    _ option: TextLineLayoutFragment.BoundsOption
  ) -> TextLineLayoutFragment {
    let context = MathTextLineLayoutContext(styleSheet, mathContext)
    context.beginEditing()
    node.performLayout(context, fromScratch: true)
    context.endEditing()
    return TextLineLayoutFragment(
      context.originalString, context.renderedString, context.ctLine, option)
  }

  static func createTextMode(
    _ text: String, _ node: Node, _ styleSheet: StyleSheet,
    _ option: TextLineLayoutFragment.BoundsOption
  ) -> TextLineLayoutFragment {
    let context = TextLineLayoutContext(styleSheet)
    context.beginEditing()
    context.insertText(text, node)
    context.endEditing()
    return TextLineLayoutFragment(context.renderedString, context.ctLine, option)
  }

  static func createMathMode(
    _ text: String, _ node: Node, _ styleSheet: StyleSheet, _ mathContext: MathContext,
    _ option: TextLineLayoutFragment.BoundsOption
  ) -> TextLineLayoutFragment {
    let context = MathTextLineLayoutContext(styleSheet, mathContext)
    context.beginEditing()
    context.insertText(text, node)
    context.endEditing()
    return TextLineLayoutFragment(
      context.originalString, context.renderedString, context.ctLine, option)
  }

  /// Reconciles a `TextLineLayoutFragment` with a `Node`.
  static func reconcileTextMode(
    _ fragment: TextLineLayoutFragment, _ node: Node, _ styleSheet: StyleSheet
  ) -> TextLineLayoutFragment {
    let context = TextLineLayoutContext(styleSheet, fragment)
    context.beginEditing()
    node.performLayout(context, fromScratch: false)
    context.endEditing()
    return TextLineLayoutFragment(context.renderedString, context.ctLine, fragment.option)
  }

  static func reconcileMathMode(
    _ fragment: TextLineLayoutFragment, _ node: Node, _ styleSheet: StyleSheet,
    _ mathContext: MathContext
  ) -> TextLineLayoutFragment {
    let context = MathTextLineLayoutContext(styleSheet, fragment, mathContext)
    context.beginEditing()
    node.performLayout(context, fromScratch: false)
    context.endEditing()
    return TextLineLayoutFragment(
      context.originalString, context.renderedString, context.ctLine, fragment.option)
  }
}
