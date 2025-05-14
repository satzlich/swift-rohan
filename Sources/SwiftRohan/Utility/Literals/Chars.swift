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
  static let lineSeparator: Character = "\u{2028}"
  static let dottedSquare: Character = "\u{2B1A}"
  static let replacementChar: Character = "\u{FFFD}"

  // math
  static let prime: Character = "\u{2032}"  // x′
  static let doublePrime: Character = "\u{2033}"  // x″
  static let triplePrime: Character = "\u{2034}"  // x‴

  static func isPrime(_ c: Character) -> Bool {
    c == prime || c == doublePrime || c == triplePrime
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
  static let leftArrowAbove: Character = "\u{20D6}"  // x⃖
  static let rightArrowAbove: Character = "\u{20D7}"  // x⃗
  static let threeDotsAbove: Character = "\u{20DB}"  // x⃛
  static let fourDotsAbove: Character = "\u{20DC}"  // x⃜
  static let leftRightArrowAbove: Character = "\u{20E1}"  // x⃡

  // under/over
  static let underShell: Character = "⏡"
  static let overShell: Character = "⏠"
}
