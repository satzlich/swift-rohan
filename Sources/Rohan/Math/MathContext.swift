// Copyright 2024-2025 Lie Yan

import CoreText
import Foundation
import TTFParser

struct MathContext {
  private let mathFont: _MathFont

  var table: MathTable { @inline(__always) get { mathFont.table } }
  var constants: MathConstantsTable { @inline(__always) get { mathFont.constants } }
  let mathStyle: MathStyle
  let textColor: Color

  init?(_ font: Font, _ mathStyle: MathStyle, _ textColor: Color) {
    guard let mathFont = _MathFont(font) else { return nil }
    self.mathFont = mathFont
    self.mathStyle = mathStyle
    self.textColor = textColor
  }

  private init(_ mathFont: _MathFont, _ mathStyle: MathStyle, _ textColor: Color) {
    self.mathFont = mathFont
    self.mathStyle = mathStyle
    self.textColor = textColor
  }

  func with(mathStyle: MathStyle) -> MathContext {
    MathContext(mathFont, mathStyle, textColor)
  }

  func getFont(for style: MathStyle) -> Font { mathFont.getFont(for: style) }

  /** Returns the font for the current math style */
  func getFont() -> Font { mathFont.getFont(for: mathStyle) }
}

extension MathUtils {
  /// Resolve math context for node
  static func resolveMathContext(for node: Node, _ styleSheet: StyleSheet) -> MathContext
  {
    // math font
    let textSize = node.resolveProperty(TextProperty.size, styleSheet).fontSize()!
    let fontName = node.resolveProperty(MathProperty.font, styleSheet).string()!
    let mathFont = Font.createWithName(fontName, textSize.floatValue, isFlipped: true)

    // math style
    let mathStyle = node.resolveProperty(MathProperty.style, styleSheet).mathStyle()!

    // text color
    let textColor = node.resolveProperty(TextProperty.foregroundColor, styleSheet)
      .color()!

    guard let mathContext = MathContext(mathFont, mathStyle, textColor)
    else { fatalError("TODO: return fallback math context") }
    return mathContext
  }
}

/// Font-related data for math layout
private final class _MathFont {
  let font: Font
  let table: MathTable
  let constants: MathConstantsTable

  private(set) lazy var scriptFont: Font = {
    let scaleDown = CGFloat(constants.scriptPercentScaleDown) / 100
    return font.createCopy(font.size * scaleDown)
  }()

  private(set) lazy var scriptScriptFont: Font = {
    let scaleDown = CGFloat(constants.scriptScriptPercentScaleDown) / 100
    return font.createCopy(font.size * scaleDown)
  }()

  init?(_ font: Font) {
    guard let table = font.copyMathTable(),
      let constants = table.constants
    else { return nil }
    self.font = font
    self.table = table
    self.constants = constants
  }

  func getFont(for style: MathStyle) -> Font {
    switch style {
    case .display, .text:
      return font
    case .script:
      return scriptFont
    case .scriptScript:
      return scriptScriptFont
    }
  }
}
