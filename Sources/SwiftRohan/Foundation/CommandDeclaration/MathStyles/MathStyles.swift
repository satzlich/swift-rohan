// Copyright 2024-2025 Lie Yan

import LatexParser

enum MathStyles: CommandDeclarationProtocol {
  case mathStyle(MathStyle)
  case mathTextStyle(MathTextStyle)
  /// Switch current math style to corresponding inline style.
  case toInlineStyle

  var command: String {
    switch self {
    case let .mathStyle(style): return style.command
    case let .mathTextStyle(textStyle): return textStyle.command
    case .toInlineStyle: return "_inlinestyle"
    }
  }

  var tag: CommandTag {
    switch self {
    case let .mathStyle(style): return style.tag
    case let .mathTextStyle(textStyle): return textStyle.tag
    case .toInlineStyle: return .null
    }
  }

  var source: CommandSource {
    switch self {
    case let .mathStyle(style): return style.source
    case let .mathTextStyle(textStyle): return textStyle.source
    case .toInlineStyle: return .customExtension
    }
  }

  func preview() -> CommandBody.CommandPreview {
    switch self {
    case .mathStyle: return .string("⬚")
    case let .mathTextStyle(textStyle):
      return .string(textStyle.preview())
    case .toInlineStyle:
      return .string("⬚")
    }
  }

  static let allCommands: Array<MathStyles> =
    MathStyle.allCommands.map { .mathStyle($0) }
    + MathTextStyle.allCommands.map { .mathTextStyle($0) }  // + [.toInlineStyle]
}

extension MathStyles {
  private static let _dictionary: Dictionary<String, MathStyles> =
    Dictionary(uniqueKeysWithValues: allCommands.map { ($0.command, $0) })

  static func lookup(_ command: String) -> MathStyles? {
    _dictionary[command]
  }

  //
  static let displaystyle = MathStyles.mathStyle(.display)
  static let textstyle = MathStyles.mathStyle(.text)
  static let scriptstyle = MathStyles.mathStyle(.script)
  static let scriptscriptstyle = MathStyles.mathStyle(.scriptScript)
  //
  static let mathbb = MathStyles.mathTextStyle(.mathbb)
  static let mathbf = MathStyles.mathTextStyle(.mathbf)
  static let mathcal = MathStyles.mathTextStyle(.mathcal)
  static let mathfrak = MathStyles.mathTextStyle(.mathfrak)
  static let mathit = MathStyles.mathTextStyle(.mathit)
  static let mathrm = MathStyles.mathTextStyle(.mathrm)
  static let mathsf = MathStyles.mathTextStyle(.mathsf)
  static let mathtt = MathStyles.mathTextStyle(.mathtt)

  //
  static let _inlinestyle = MathStyles.toInlineStyle
}
