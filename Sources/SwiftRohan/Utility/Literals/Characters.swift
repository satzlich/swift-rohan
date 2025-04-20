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

  // macOS-specific, distinguished by "Fn" suffix
  static let upArrowFn: Character = "\u{F700}"
  static let downArrowFn: Character = "\u{F701}"
  static let leftArrowFn: Character = "\u{F702}"
  static let rightArrowFn: Character = "\u{F703}"

  // others
  static let ZWSP: Character = "\u{200B}"
  static let lineSeparator: Character = "\u{2028}"
  static let replacementChar: Character = "\u{FFFD}"
}
