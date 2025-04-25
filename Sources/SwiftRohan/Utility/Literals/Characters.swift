// Copyright 2024-2025 Lie Yan

/// Character literals.
enum Characters {
  // control characters
  static let enter: Character = "\u{0003}"
  static let tab: Character = "\u{0009}"
  static let newline: Character = "\u{000A}"
  static let carriageReturn: Character = "\u{000D}"
  static let escape: Character = "\u{001B}"
  static let space: Character = "\u{0020}"
  static let NBSP: Character = "\u{00A0}"

  // macOS-specific, distinguished by "Fn" suffix
  static let upArrowFn: Character = "\u{F700}"
  static let downArrowFn: Character = "\u{F701}"
  static let leftArrowFn: Character = "\u{F702}"
  static let rightArrowFn: Character = "\u{F703}"

  // others
  static let ZWSP: Character = "\u{200B}"
  static let lineSeparator: Character = "\u{2028}"
  static let replacementChar: Character = "\u{FFFD}"

  // accent
  static let grave: Character = "\u{0300}"  // x̀
  static let acute: Character = "\u{0301}"  // x́
  static let circumflex: Character = "\u{0302}"  // x̂
  static let tilde: Character = "\u{0303}"  // x̃
  static let macron: Character = "\u{0304}"  // x̄
  static let overline: Character = "\u{0305}"  // x̅
  static let breve: Character = "\u{0306}"  // x̆
  static let dotAbove: Character = "\u{0307}"  // ẋ
  static let diaeresis: Character = "\u{0308}"  // ẍ (umlaut)
  static let ringAbove: Character = "\u{030A}"  // x̊
  static let doubleAcute: Character = "\u{030B}"  // x̋
  static let caron: Character = "\u{030C}"  // x̌
  static let leftHarpoonAbove: Character = "\u{20D0}"  // x⃐
  static let rightHarpoonAbove: Character = "\u{20D1}"  // x⃑
  static let leftArrowAbove: Character = "\u{20D6}"  // x⃖
  static let rightArrowAbove: Character = "\u{20D7}"  // x⃗
  static let threeDotsAbove: Character = "\u{20DB}"  // x⃛
  static let fourDotsAbove: Character = "\u{20DC}"  // x⃜
  static let leftRightArrowAbove: Character = "\u{20E1}"  // x⃡
}

enum UnicodeScalars {
  // accent
  static let macron: UnicodeScalar = "\u{0304}"  // x̄
}
