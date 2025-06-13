// Copyright 2024-2025 Lie Yan

import LatexParser

enum MathStyles: CommandDeclarationProtocol {
  case mathStyle(MathStyle)
  case mathTextStyle(MathTextStyle)
  /// Switch to parallel style in inline.
  case inlineStyle

  var command: String {
    switch self {
    case let .mathStyle(style): return style.command
    case let .mathTextStyle(textStyle): return textStyle.command
    case .inlineStyle: return "_inlinestyle"
    }
  }

  var tag: CommandTag {
    switch self {
    case let .mathStyle(style): return style.tag
    case let .mathTextStyle(textStyle): return textStyle.tag
    case .inlineStyle: return .null
    }
  }
  
  var source: CommandSource {
    switch self {
    case let .mathStyle(style): return style.source
    case let .mathTextStyle(textStyle): return textStyle.source
    case .inlineStyle: return .customExtension
    }
  }

  func preview() -> CommandBody.CommandPreview {
    switch self {
    case .mathStyle: return .string("⬚")
    case let .mathTextStyle(textStyle):
      return .string(textStyle.preview())
    case .inlineStyle:
      return .string("⬚")
    }
  }

  static let allCommands: Array<MathStyles> =
    MathStyle.allCommands.map { .mathStyle($0) }
    + MathTextStyle.allCommands.map { .mathTextStyle($0) }  // + [.inlineStyle]
}

extension MathStyles {
  private static let _dictionary: [String: MathStyles] =
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
  static let _inlinestyle = MathStyles.inlineStyle
}
