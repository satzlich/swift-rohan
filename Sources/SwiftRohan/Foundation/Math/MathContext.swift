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
    guard let mathFont = _MathFont(font) else { return nil }

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

  func with(cramped: Bool) -> MathContext {
    MathContext(mathFont, mathStyle, cramped, textColor)
  }

  func getFont(for style: MathStyle) -> Font { mathFont.getFont(for: style) }

  /// Returns the font for the current math style
  func getFont() -> Font { mathFont.getFont(for: mathStyle) }

  func getFontSize() -> Double { mathFont.getFontSize(for: mathStyle) }

  func getFontSize(for style: MathStyle) -> Double { mathFont.getFontSize(for: style) }

  /// Minimum cursor height (ascent, descent).
  func cursorHeight() -> (ascent: Double, descent: Double) {
    let font = self.getFont()
    return (font.ascent, font.descent)
  }
}

extension MathUtils {
  internal static let previewMathFont: String = "NewComputerModernMath"
  internal static let fallbackMathFont: String = "STIX Two Math"

  static func resolveMathContext(
    for node: Node, _ styleSheet: StyleSheet
  ) -> MathContext {
    let properties = node.getProperties(styleSheet)
    return resolveMathContext(properties, styleSheet)
  }

  static func resolveMathContext(
    _ properties: PropertyDictionary, _ styleSheet: StyleSheet
  ) -> MathContext {
    let key = MathContextKey.resolveKey(properties, styleSheet)
    return _mathContextCache.getOrCreate(key, { () in createMathContext(for: key) })
  }

  static func fallbackMathContext(
    for mathContext: MathContext
  ) -> MathContext {
    let textSize = FontSize(mathContext.getFontSize(for: .text))
    let key = MathContextKey(
      textSize: textSize, mathFont: fallbackMathFont, mathStyle: mathContext.mathStyle,
      cramped: mathContext.cramped, textColor: mathContext.textColor)
    return _mathContextCache.getOrCreate(key, { () in createMathContext(for: key) })
  }

  // MARK: - Implementation

  private static func createMathContext(for key: MathContextKey) -> MathContext {
    let textSize = key.textSize.floatValue
    let mathFont = Font.createWithName(key.mathFont, textSize, isFlipped: true)

    guard
      let mathContext = MathContext(mathFont, key.mathStyle, key.cramped, key.textColor)
    else {
      let fallback = Font.createWithName(fallbackMathFont, textSize, isFlipped: true)
      return MathContext(fallback, key.mathStyle, key.cramped, key.textColor)!
    }
    return mathContext
  }

  // MARK: - Cache

  nonisolated(unsafe) private static let _mathContextCache = MathContextCache()

  private typealias MathContextCache = ConcurrentCache<MathContextKey, MathContext>

  private struct MathContextKey: Equatable, Hashable {
    let textSize: FontSize
    let mathFont: String
    let mathStyle: MathStyle
    let cramped: Bool
    let textColor: Color

    static func resolveKey(
      _ properties: PropertyDictionary, _ stylesheet: StyleSheet
    ) -> MathContextKey {
      func resolveValue(_ key: PropertyKey) -> PropertyValue {
        key.resolveValue(properties, stylesheet)
      }

      return MathContextKey(
        textSize: resolveValue(textSize).fontSize()!,
        mathFont: resolveValue(mathFont).string()!,
        mathStyle: resolveValue(mathStyle).mathStyle()!,
        cramped: resolveValue(cramped).bool()!,
        textColor: resolveValue(textColor).color()!)
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
    case .display, .text: return font
    case .script: return scriptFont
    case .scriptScript: return scriptScriptFont
    }
  }

  func getFontSize(for style: MathStyle) -> Double {
    switch style {
    case .display, .text: return font.size
    case .script: return scriptFont.size
    case .scriptScript: return scriptScriptFont.size
    }
  }
}
