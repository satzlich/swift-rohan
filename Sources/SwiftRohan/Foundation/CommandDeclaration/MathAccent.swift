// Copyright 2024-2025 Lie Yan

import Foundation
import LaTeXParser

struct MathAccent: Codable, CommandDeclarationProtocol {
  /// Command sequence
  let command: String
  var genre: CommandGenre { .other }
  var source: CommandSource { .preBuilt }
  /// The accent character
  let accent: Character

  enum Subtype: String, Codable {
    /// top accent
    case accent
    /// wide top accent
    case wideAccent
    /// bottom accent
    case bottom
    /// wide bottom accent
    case bottomWide
    /// top accent like over-spreader
    case over
    /// bottom accent like under-spreader
    case under

    var isTop: Bool {
      switch self {
      case .accent, .wideAccent, .over: return true
      case .bottom, .bottomWide, .under: return false
      }
    }

    var isBottom: Bool { !isTop }
  }
  let subtype: Subtype

  init(_ command: String, _ accent: Character, _ subtype: Subtype = .accent) {
    self.command = command
    self.accent = accent
    self.subtype = subtype
  }

  func preview() -> CommandBody.CommandPreview {
    switch subtype {
    case .under: .image(command)
    default: .string("⬚\(accent)")
    }
  }

  enum CodingKeys: CodingKey { case command, accent, subtype }

  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.command = try container.decode(String.self, forKey: .command)
    self.accent = try container.decode(Character.self, forKey: .accent)
    self.subtype = try container.decode(Subtype.self, forKey: .subtype)
  }

  func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(command, forKey: .command)
    try container.encode(accent, forKey: .accent)
    try container.encode(subtype, forKey: .subtype)
  }
}

extension MathAccent {
  static let allCommands: [MathAccent] = [
    // Table 259 (total 11)
    .acute,
    .bar,
    .breve,
    .check,
    .dot,
    .ddot,
    .grave,
    .hat,
    .mathring,
    .tilde,
    .vec,
    // Table 260 (total 2)
    .dddot,
    .ddddot,
    // Table 270 (total 9)
    .widetilde,
    .widehat,
    .overleftarrow,
    .overrightarrow,
    // \overline, \underline, \overbrace, \underbrace defined elsewhere.
    // \sqrt defined elsewhere.
    // Table 273 (total 4)
    .overleftrightarrow,
    .underleftrightarrow,
    .underleftarrow,
    .underrightarrow,
    //
    .overbar,
    .widecheck,
    .widebreve,
    .wideoverbar,
  ]

  private static let _dictionary: [String: MathAccent] =
    Dictionary(uniqueKeysWithValues: allCommands.map { ($0.command, $0) })

  static func lookup(_ command: String) -> MathAccent? {
    _dictionary[command]
  }

  static let acute = MathAccent("acute", "\u{0301}")
  static let bar = MathAccent("bar", "\u{0304}")
  static let check = MathAccent("check", "\u{030C}")
  static let dot = MathAccent("dot", "\u{0307}")
  static let ddot = MathAccent("ddot", "\u{0308}")
  static let dddot = MathAccent("dddot", "\u{20DB}")
  static let ddddot = MathAccent("ddddot", "\u{20DC}")
  static let breve = MathAccent("breve", "\u{0306}")
  static let grave = MathAccent("grave", "\u{0300}")
  static let hat = MathAccent("hat", "\u{0302}")
  static let mathring = MathAccent("mathring", "\u{030A}")
  static let overbar = MathAccent("overbar", "\u{0305}")
  static let overleftarrow = MathAccent("overleftarrow", "\u{20D6}", .over)
  static let overrightarrow = MathAccent("overrightarrow", "\u{20D7}", .over)
  static let overleftrightarrow = MathAccent("overleftrightarrow", "\u{20E1}", .over)
  static let tilde = MathAccent("tilde", "\u{0303}")
  static let underleftarrow = MathAccent("underleftarrow", "\u{20EE}", .under)
  static let underrightarrow = MathAccent("underrightarrow", "\u{20EF}", .under)
  static let underleftrightarrow = MathAccent("underleftrightarrow", "\u{034D}", .under)
  static let widecheck = MathAccent("widecheck", "\u{030C}", .wideAccent)
  static let widebreve = MathAccent("widebreve", "\u{0306}", .wideAccent)
  static let widehat = MathAccent("widehat", "\u{0302}", .wideAccent)
  static let wideoverbar = MathAccent("wideoverbar", "\u{0305}", .wideAccent)
  static let widetilde = MathAccent("widetilde", "\u{0303}", .wideAccent)
  static let vec = MathAccent("vec", "\u{20D7}", .wideAccent)
}
