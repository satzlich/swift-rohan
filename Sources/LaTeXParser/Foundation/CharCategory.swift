// Copyright 2024-2025 Lie Yan

public enum CharCategory: Int {
  case escapeChar = 0  // \
  case groupBeginning = 1  // { or [
  case groupEnd = 2  // } or ]
  case mathShift = 3  // $
  case alignmentTab = 4  // &
  case endOfLine = 5  // newline
  case parameter = 6  // #
  case superscript = 7  // ^
  case subscript_ = 8  // _
  case ignoredChar = 9  // <null>
  case space = 10
  case letter = 11  // A-Za-z
  case otherChar = 12  // none of the above or below
  case activeChar = 13  // ~
  case commentChar = 14  // %
  case invalidChar = 15  // <delete>
}

extension Character {
  var charCategory: CharCategory {
    switch self {
    case "\\": .escapeChar
    case "{", "[": .groupBeginning
    case "}", "]": .groupEnd
    case "$": .mathShift
    case "&": .alignmentTab
    case "\n", "\r", "\r\n": .endOfLine
    case "#": .parameter
    case "^": .superscript
    case "_": .subscript_
    case "\u{00}": .ignoredChar
    case "\u{09}", "\u{20}": .space
    case "A"..."Z", "a"..."z": .letter
    case "~": .activeChar
    case "%": .commentChar
    default: .otherChar
    }
  }
}
