// Copyright 2024-2025 Lie Yan

import CoreGraphics
import CoreText
import Foundation
import TTFParser
import UnicodeMathClass

/// Fragment for a single line of text or math layout.
final class CTLineLayoutFragment: LayoutFragment {

  /// Rendered string.
  private(set) var attrString: NSMutableAttributedString
  private(set) var ctLine: CTLine
  private var _width: CGFloat = 0
  private var _ascent: CGFloat = 0
  private var _descent: CGFloat = 0

  let layoutMode: LayoutMode
  let boundsOption: BoundsOption

  private(set) var originalString: String
  var resolvedString: String { attrString.string }

  enum BoundsOption: CaseIterable {
    case imageBounds
    case typographicBounds
  }

  convenience init(
    _ attrString: NSMutableAttributedString, _ ctLine: CTLine,
    _ layoutMode: LayoutMode, _ option: BoundsOption
  ) {
    self.init(attrString.string, attrString, ctLine, layoutMode, option)
  }

  init(_ context: MathLineLayoutContext) {
    self.originalString = context.originalString
    self.attrString = context.renderedString
    self.ctLine = context.ctLine
    self.layoutMode = .mathMode
    self.boundsOption = .imageBounds
    //
    self.glyphOrigin = .zero
    self._width = ctLine.getImageBounds(&_ascent, &_descent)
  }

  init(_ context: TextLineLayoutContext, _ option: BoundsOption) {
    self.originalString = context.renderedString.string
    self.attrString = context.renderedString
    self.ctLine = context.ctLine
    self.layoutMode = .textMode
    self.boundsOption = option
    //
    self.glyphOrigin = .zero

    switch option {
    case .typographicBounds:
      self._width = ctLine.getTypographicBounds(&_ascent, &_descent, nil)
    case .imageBounds:
      self._width = ctLine.getImageBounds(&_ascent, &_descent)
    }
  }

  init(
    _ string: String, _ attrString: NSMutableAttributedString, _ ctLine: CTLine,
    _ layoutMode: LayoutMode, _ option: BoundsOption
  ) {
    self.originalString = string
    self.attrString = attrString
    self.ctLine = ctLine
    self.glyphOrigin = .zero
    self.layoutMode = layoutMode
    self.boundsOption = option

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

extension CTLineLayoutFragment {
  static func createTextMode(
    _ node: Node, _ styleSheet: StyleSheet, _ boundsOption: BoundsOption
  ) -> CTLineLayoutFragment {
    let context = TextLineLayoutContext(styleSheet, boundsOption)
    context.beginEditing()
    _ = node.performLayoutForward(context, fromScratch: true)
    context.endEditing()
    return CTLineLayoutFragment(context, boundsOption)
  }

  static func createTextMode(
    _ text: String, _ node: Node, _ styleSheet: StyleSheet, _ boundsOption: BoundsOption
  ) -> CTLineLayoutFragment {
    let context = TextLineLayoutContext(styleSheet, boundsOption)
    context.beginEditing()
    context.insertTextForward(text, node)
    context.endEditing()
    return CTLineLayoutFragment(context, boundsOption)
  }

  /// Reconciles a `TextLineLayoutFragment` with a `Node`.
  static func reconcileTextMode(
    _ fragment: CTLineLayoutFragment, _ node: Node, _ styleSheet: StyleSheet
  ) -> CTLineLayoutFragment {
    precondition(fragment.layoutMode == .textMode)
    let context = TextLineLayoutContext(styleSheet, fragment)
    context.beginEditing()
    context.resetCursorForForwardEditing()
    _ = node.performLayoutForward(context, fromScratch: false)
    context.endEditing()
    return CTLineLayoutFragment(context, fragment.boundsOption)
  }
}
