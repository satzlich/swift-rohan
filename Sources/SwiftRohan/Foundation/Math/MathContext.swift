// Copyright 2024-2025 Lie Yan

import CoreText
import Foundation
import TTFParser

struct MathContext {
  private let mathFont: _MathFont

  let mathStyle: MathStyle
  let cramped: Bool
  let textColor: Color

  var table: MathTable { mathFont.table }
  var constants: MathConstantsTable { mathFont.constants }

  init?(_ font: Font, _ mathStyle: MathStyle, _ cramped: Bool, _ textColor: Color) {
    guard let mathFont = _MathFont(font)
    else { return nil }

    self.mathFont = mathFont
    self.mathStyle = mathStyle
    self.cramped = cramped
    self.textColor = textColor
  }

  private init(
    _ mathFont: _MathFont,
    _ mathStyle: MathStyle,
    _ cramped: Bool,
    _ textColor: Color
  ) {
    self.mathFont = mathFont
    self.mathStyle = mathStyle
    self.cramped = cramped
    self.textColor = textColor
  }

  func with(mathStyle: MathStyle) -> MathContext {
    MathContext(mathFont, mathStyle, cramped, textColor)
  }

  func getFont(for style: MathStyle) -> Font { mathFont.getFont(for: style) }

  /// Returns the font for the current math style
  func getFont() -> Font { mathFont.getFont(for: mathStyle) }
}

extension MathUtils {

  /// Resolve math context for node
  static func resolveMathContext(for node: Node, _ styleSheet: StyleSheet) -> MathContext
  {
    let key = MathContextKey.resolve(node, styleSheet)
    return mathContextCache.getOrCreate(key, { () in createMathContext(for: key) })
  }

  private static func createMathContext(for key: MathContextKey) -> MathContext {
    let mathFont =
      Font.createWithName(key.mathFont, key.textSize.floatValue, isFlipped: true)

    guard
      let mathContext = MathContext(mathFont, key.mathStyle, key.cramped, key.textColor)
    else {
      fatalError("TODO: return fallback math context")
    }

    return mathContext
  }

  // MARK: - Cache

  private static let mathContextCache = MathContextCache()

  private typealias MathContextCache = ConcurrentCache<MathContextKey, MathContext>

  private struct MathContextKey: Equatable, Hashable {
    let textSize: FontSize
    let mathFont: String
    let mathStyle: MathStyle
    let cramped: Bool
    let textColor: Color

    static func resolve(_ node: Node, _ stylesheet: StyleSheet) -> MathContextKey {
      let properties = node.getProperties(stylesheet)
      let fallback = stylesheet.defaultProperties

      func resolved(_ key: PropertyKey) -> PropertyValue {
        key.resolve(properties, fallback)
      }

      return MathContextKey(
        textSize: resolved(textSize).fontSize()!,
        mathFont: resolved(mathFont).string()!,
        mathStyle: resolved(mathStyle).mathStyle()!,
        cramped: resolved(cramped).bool()!,
        textColor: resolved(textColor).color()!)
    }

    static let textSize = TextProperty.size
    static let mathFont = MathProperty.font
    static let mathStyle = MathProperty.style
    static let cramped = MathProperty.cramped
    static let textColor = TextProperty.foregroundColor
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
