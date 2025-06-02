// Copyright 2024-2025 Lie Yan

import Foundation
import LatexParser

enum MathTextStyle: String, Codable, CaseIterable, CommandDeclarationProtocol {
  case mathbb
  case mathcal
  case mathfrak
  case mathsf
  case mathtt

  case mathbf
  case mathit
  case mathrm

  var command: String {
    switch self {
    case .mathbb: return "mathbb"
    case .mathcal: return "mathcal"
    case .mathfrak: return "mathfrak"
    case .mathsf: return "mathsf"
    case .mathtt: return "mathtt"

    case .mathbf: return "mathbf"
    case .mathit: return "mathit"
    case .mathrm: return "mathrm"
    }
  }

  var tag: CommandTag { .null }
  var source: CommandSource { .preBuilt }

  func tuple() -> (MathVariant, bold: Bool?, italic: Bool?) {
    switch self {
    case .mathbb: return (.bb, nil, nil)
    case .mathcal: return (.cal, nil, nil)
    case .mathfrak: return (.frak, nil, nil)
    case .mathsf: return (.sans, false, false)
    case .mathtt: return (.mono, nil, nil)

    case .mathbf: return (.serif, true, false)
    case .mathit: return (.serif, false, true)
    case .mathrm: return (.serif, false, false)
    }
  }

  func preview() -> String {
    switch self {
    case .mathbb: return "𝔹𝕓"
    case .mathcal: return "𝒞𝒶𝓁"
    case .mathfrak: return "𝔉𝔯𝔞𝔨"
    case .mathsf: return "𝗌𝖺𝗇𝗌"
    case .mathtt: return "𝚖𝚘𝚗𝚘"

    case .mathbf: return "𝐛𝐨𝐥𝐝"
    case .mathit: return "𝑖𝑡𝑎𝑙𝑖𝑐"
    case .mathrm: return "roman"
    }
  }
}

extension MathTextStyle {
  static var allCommands: [MathTextStyle] = allCases

  static func lookup(_ command: String) -> MathTextStyle? {
    MathTextStyle(rawValue: command)
  }
}
