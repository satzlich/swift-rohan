// Copyright 2024-2025 Lie Yan

import Foundation

struct MathAccent: Codable, MathDeclarationProtocol {
  /// Command sequence
  let command: String
  /// The accent character
  let accent: Character
  /// true if the accent is stretchable
  let isStretchable: Bool

  init(_ command: String, _ accent: Character, _ isStretchable: Bool = false) {
    self.command = command
    self.accent = accent
    self.isStretchable = isStretchable
  }

  func preview() -> String {
    "⬚\(accent)"
  }

  enum CodingKeys: CodingKey {
    case command
    case accent
    case isStretchable
  }

  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.command = try container.decode(String.self, forKey: .command)
    self.accent = try container.decode(Character.self, forKey: .accent)
    self.isStretchable = try container.decode(Bool.self, forKey: .isStretchable)
  }

  func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(command, forKey: .command)
    try container.encode(accent, forKey: .accent)
    try container.encode(isStretchable, forKey: .isStretchable)
  }
}

extension MathAccent {
  static let predefinedCases: [MathAccent] = [
    .acute,
    .bar,
    .check,
    .dot,
    .ddot,
    .breve,
    .grave,
    .hat,
    .mathring,
    .overbar,
    .ovhook,
    .tilde,
    .widecheck,
    .widebreve,
    .widehat,
    .wideoverbar,
    .widetilde,
    .vec,
  ]

  private static let _dictionary: [String: MathAccent] =
    predefinedCases.reduce(into: [:]) { dict, accent in dict[accent.command] = accent }

  static func lookup(_ command: String) -> MathAccent? {
    _dictionary[command]
  }

  static let acute = MathAccent("acute", "\u{0301}")
  static let bar = MathAccent("bar", "\u{0304}")
  static let check = MathAccent("check", "\u{030C}")
  static let dot = MathAccent("dot", "\u{0307}")
  static let ddot = MathAccent("ddot", "\u{0308}")
  static let breve = MathAccent("breve", "\u{0306}")
  static let grave = MathAccent("grave", "\u{0300}")
  static let hat = MathAccent("hat", "\u{0302}")
  static let mathring = MathAccent("mathring", "\u{030A}")
  static let overbar = MathAccent("overbar", "\u{0305}")
  static let ovhook = MathAccent("ovhook", "\u{0309}")
  static let tilde = MathAccent("tilde", "\u{0303}")
  static let widecheck = MathAccent("widecheck", "\u{030C}", true)
  static let widebreve = MathAccent("widebreve", "\u{0306}", true)
  static let widehat = MathAccent("widehat", "\u{0302}", true)
  static let wideoverbar = MathAccent("wideoverbar", "\u{0305}", true)
  static let widetilde = MathAccent("widetilde", "\u{0303}", true)
  static let vec = MathAccent("vec", "\u{20D7}", true)
}
