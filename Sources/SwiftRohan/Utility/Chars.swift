// Copyright 2024-2025 Lie Yan

/// Character literals.
enum Chars {
  // control characters
  static let enter: Character = "\u{0003}"
  static let tab: Character = "\u{0009}"
  static let newline: Character = "\u{000A}"
  static let carriageReturn: Character = "\u{000D}"
  static let escape: Character = "\u{001B}"

  // others
  static let space: Character = "\u{0020}"
  static let NBSP: Character = "\u{00A0}"
  static let ZWSP: Character = "\u{200B}"
  static let wordJoiner: Character = "\u{2060}"
  static let dottedSquare: Character = "⬚"  // U+2B1A
  static let replacementChar: Character = "�"  // U+FFFD

  // math
  static let prime: Character = "′"  // U+2032
  static let doublePrime: Character = "″"  // U+2033
  static let triplePrime: Character = "‴"  // U+2034
  static let quadruplePrime: Character = "⁗"  // U+2057

  static func isPrime(_ c: Character) -> Bool {
    c == prime || c == doublePrime || c == triplePrime || c == quadruplePrime
  }

  // macOS-specific, distinguished by "Fn" suffix
  static let upArrowFn: Character = "\u{F700}"
  static let downArrowFn: Character = "\u{F701}"
  static let leftArrowFn: Character = "\u{F702}"
  static let rightArrowFn: Character = "\u{F703}"

  // accent
  static let doubleAcute: Character = "\u{030B}"  // x̋
  static let underbar: Character = "\u{0332}"  // x̲
  static let leftHarpoonAbove: Character = "\u{20D0}"  // x⃐
  static let rightHarpoonAbove: Character = "\u{20D1}"  // x⃑

  // under/over
  static let underShell: Character = "⏡"  // U+23E1
  static let overShell: Character = "⏠"  // U+23E0
}
