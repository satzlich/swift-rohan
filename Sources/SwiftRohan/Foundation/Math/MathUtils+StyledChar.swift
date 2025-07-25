import Foundation

extension MathUtils {
  /// Returns a styled character.
  public static func styledChar(
    for c: Character,
    variant: MathVariant,
    bold: Bool,
    italic: Bool?,
    autoItalic: Bool
  ) -> Character {
    guard c.unicodeScalars.count == 1
    else { return c }
    let c = c.unicodeScalars.first!
    let unicodeScalar = styledChar(
      for: c, variant: variant, bold: bold, italic: italic, autoItalic: autoItalic)
    return Character(unicodeScalar)
  }

  /// Returns a styled character.
  /// - Parameters:
  ///   - c: the character to be styled
  ///   - variant: the math variant
  ///   - bold: whether the character should be bold
  ///   - italic: whether the character should be italic. Can be nil.
  ///   - autoItalic: whether the character should be italicized according to
  ///       typesetting tradition when parameter `italic` is not specified
  public static func styledChar(
    for c: UnicodeScalar,
    variant: MathVariant,
    bold: Bool,
    italic: Bool?,
    autoItalic: Bool
  ) -> UnicodeScalar {
    func matches(_ c: UnicodeScalar) -> Bool {
      switch c {
      case "a"..."z", "ı", "ȷ", "A"..."Z", "α"..."ω", "∂", "ϵ", "ϑ", "ϰ", "ϕ", "ϱ", "ϖ":
        return true
      default:
        return false
      }
    }

    func matches(_ variant: MathVariant) -> Bool {
      variant == .sans || variant == .serif
    }

    let italic = italic ?? (autoItalic && matches(c) && matches(variant))

    if let c = basicException(c) {
      return c
    }

    if let c = latinException(c, variant, bold: bold, italic: italic) {
      return c
    }

    if let c = greekException(c, variant, bold: bold, italic: italic) {
      return c
    }

    // determine base character

    let base: UnicodeScalar
    switch c {
    case "A"..."Z": base = "A"
    case "a"..."z": base = "a"
    case "Α"..."Ω": base = "Α"
    case "α"..."ω": base = "α"
    case "0"..."9": base = "0"
    // Hebrew Alef -> Dalet.
    case "\u{05D0}"..."\u{05D3}":
      base = "\u{05D0}"
    default:
      return c
    }

    // determine start of target family

    let start: UInt32
    switch c {
    // Latin upper.
    case "A"..."Z":
      switch (variant, bold, italic) {
      case (.serif, false, false): start = 0x0041
      case (.serif, true, false): start = 0x1D400
      case (.serif, false, true): start = 0x1D434
      case (.serif, true, true): start = 0x1D468
      case (.sans, false, false): start = 0x1D5A0
      case (.sans, true, false): start = 0x1D5D4
      case (.sans, false, true): start = 0x1D608
      case (.sans, true, true): start = 0x1D63C
      case (.cal, false, _): start = 0x1D49C
      case (.cal, true, _): start = 0x1D4D0
      case (.frak, false, _): start = 0x1D504
      case (.frak, true, _): start = 0x1D56C
      case (.mono, _, _): start = 0x1D670
      case (.bb, _, _): start = 0x1D538
      }

    // Latin lower.
    case "a"..."z":
      switch (variant, bold, italic) {
      case (.serif, false, false): start = 0x0061
      case (.serif, true, false): start = 0x1D41A
      case (.serif, false, true): start = 0x1D44E
      case (.serif, true, true): start = 0x1D482
      case (.sans, false, false): start = 0x1D5BA
      case (.sans, true, false): start = 0x1D5EE
      case (.sans, false, true): start = 0x1D622
      case (.sans, true, true): start = 0x1D656
      case (.cal, false, _): start = 0x1D4B6
      case (.cal, true, _): start = 0x1D4EA
      case (.frak, false, _): start = 0x1D51E
      case (.frak, true, _): start = 0x1D586
      case (.mono, _, _): start = 0x1D68A
      case (.bb, _, _): start = 0x1D552
      }

    // Greek upper.
    case "Α"..."Ω":
      switch (variant, bold, italic) {
      case (.serif, false, false): start = 0x0391
      case (.serif, true, false): start = 0x1D6A8
      case (.serif, false, true): start = 0x1D6E2
      case (.serif, true, true): start = 0x1D71C
      case (.sans, _, false): start = 0x1D756
      case (.sans, _, true): start = 0x1D790
      case (.cal, _, _), (.frak, _, _), (.mono, _, _), (.bb, _, _): return c
      }

    // Greek lower.
    case "α"..."ω":
      switch (variant, bold, italic) {
      case (.serif, false, false): start = 0x03B1
      case (.serif, true, false): start = 0x1D6C2
      case (.serif, false, true): start = 0x1D6FC
      case (.serif, true, true): start = 0x1D736
      case (.sans, _, false): start = 0x1D770
      case (.sans, _, true): start = 0x1D7AA
      case (.cal, _, _), (.frak, _, _), (.mono, _, _), (.bb, _, _): return c
      }

    // Hebrew Alef -> Dalet.
    case "\u{05D0}"..."\u{05D3}": start = 0x2135

    // Numbers.
    case "0"..."9":
      switch (variant, bold, italic) {
      case (.serif, false, _): start = 0x0030
      case (.serif, true, _): start = 0x1D7CE
      case (.bb, _, _): start = 0x1D7D8
      case (.sans, false, _): start = 0x1D7E2
      case (.sans, true, _): start = 0x1D7EC
      case (.mono, _, _): start = 0x1D7F6
      case (.cal, _, _), (.frak, _, _): return c
      }

    default:
      assertionFailure("unexpected character \(c)")
      return c
    }

    return UnicodeScalar(start + (c.value - base.value))!
  }

  private static func basicException(_ c: UnicodeScalar) -> UnicodeScalar? {
    switch c {
    case "〈": return "⟨"
    case "〉": return "⟩"
    case "《": return "⟪"
    case "》": return "⟫"
    default: return nil
    }
  }

  private static func latinException(
    _ c: UnicodeScalar,
    _ variant: MathVariant,
    bold: Bool,
    italic: Bool
  ) -> UnicodeScalar? {
    switch (c, variant, bold, italic) {
    case ("B", .cal, false, _): return "ℬ"
    case ("E", .cal, false, _): return "ℰ"
    case ("F", .cal, false, _): return "ℱ"
    case ("H", .cal, false, _): return "ℋ"
    case ("I", .cal, false, _): return "ℐ"
    case ("L", .cal, false, _): return "ℒ"
    case ("M", .cal, false, _): return "ℳ"
    case ("R", .cal, false, _): return "ℛ"
    case ("C", .frak, false, _): return "ℭ"
    case ("H", .frak, false, _): return "ℌ"
    case ("I", .frak, false, _): return "ℑ"
    case ("R", .frak, false, _): return "ℜ"
    case ("Z", .frak, false, _): return "ℨ"
    case ("C", .bb, _, _): return "ℂ"
    case ("H", .bb, _, _): return "ℍ"
    case ("N", .bb, _, _): return "ℕ"
    case ("P", .bb, _, _): return "ℙ"
    case ("Q", .bb, _, _): return "ℚ"
    case ("R", .bb, _, _): return "ℝ"
    case ("Z", .bb, _, _): return "ℤ"
    case ("D", .bb, _, true): return "ⅅ"
    case ("d", .bb, _, true): return "ⅆ"
    case ("e", .bb, _, true): return "ⅇ"
    case ("i", .bb, _, true): return "ⅈ"
    case ("j", .bb, _, true): return "ⅉ"
    case ("h", .serif, false, true): return "ℎ"
    case ("e", .cal, false, _): return "ℯ"
    case ("g", .cal, false, _): return "ℊ"
    case ("o", .cal, false, _): return "ℴ"
    case ("ħ", .serif, _, true): return "ℏ"
    case ("ı", .serif, _, true): return "𝚤"
    case ("ȷ", .serif, _, true): return "𝚥"
    default: return nil
    }
  }

  private static func greekException(
    _ c: UnicodeScalar,
    _ variant: MathVariant,
    bold: Bool,
    italic: Bool
  ) -> UnicodeScalar? {
    if c == "Ϝ", variant == .serif, bold {
      return "𝟊"
    }
    if c == "ϝ", variant == .serif, bold {
      return "𝟋"
    }

    let list: Array<UnicodeScalar>
    switch c {
    case "ϴ": list = ["𝚹", "𝛳", "𝜭", "𝝧", "𝞡", "ϴ"]
    case "∇": list = ["𝛁", "𝛻", "𝜵", "𝝯", "𝞩", "∇"]
    case "∂": list = ["𝛛", "𝜕", "𝝏", "𝞉", "𝟃", "∂"]
    case "ϵ": list = ["𝛜", "𝜖", "𝝐", "𝞊", "𝟄", "ϵ"]
    case "ϑ": list = ["𝛝", "𝜗", "𝝑", "𝞋", "𝟅", "ϑ"]
    case "ϰ": list = ["𝛞", "𝜘", "𝝒", "𝞌", "𝟆", "ϰ"]
    case "ϕ": list = ["𝛟", "𝜙", "𝝓", "𝞍", "𝟇", "ϕ"]
    case "ϱ": list = ["𝛠", "𝜚", "𝝔", "𝞎", "𝟈", "ϱ"]
    case "ϖ": list = ["𝛡", "𝜛", "𝝕", "𝞏", "𝟉", "ϖ"]
    case "Γ": list = ["𝚪", "𝛤", "𝜞", "𝝘", "𝞒", "ℾ"]
    case "γ": list = ["𝛄", "𝛾", "𝜸", "𝝲", "𝞬", "ℽ"]
    case "Π": list = ["𝚷", "𝛱", "𝜫", "𝝥", "𝞟", "ℿ"]
    case "π": list = ["𝛑", "𝜋", "𝝅", "𝝿", "𝞹", "ℼ"]
    case "∑": list = ["∑", "∑", "∑", "∑", "∑", "⅀"]
    default: return nil
    }

    switch (variant, bold, italic) {
    case (.serif, true, false): return list[0]
    case (.serif, false, true): return list[1]
    case (.serif, true, true): return list[2]
    case (.sans, _, false): return list[3]
    case (.sans, _, true): return list[4]
    case (.bb, _, _): return list[5]
    default: return nil
    }
  }

  /// Resolve a character to a styled character
  static func resolveCharacter(_ char: Character, _ property: MathProperty) -> Character {
    let substituted = MathUtils.SUBS[char] ?? char
    let styled = styledChar(
      for: substituted, variant: property.variant, bold: property.bold,
      italic: property.italic, autoItalic: true)
    return styled
  }
}
