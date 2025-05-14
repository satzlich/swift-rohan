// Copyright 2024-2025 Lie Yan

import Foundation

struct MathAccent: Codable {
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

  enum CodingKeys: CodingKey {
    case command
    case accent
    case isStretchable
  }

  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.command = try container.decode(String.self, forKey: .command)
    let accentString = try container.decode(String.self, forKey: .accent)
    guard let accent = accentString.first else {
      throw DecodingError.dataCorruptedError(
        forKey: .accent,
        in: container,
        debugDescription: "Accent must be a single character."
      )
    }
    self.accent = accent
    self.isStretchable = try container.decode(Bool.self, forKey: .isStretchable)
  }

  func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(command, forKey: .command)
    try container.encode(String(accent), forKey: .accent)
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

  static let acute = MathAccent("acute", Chars.acute)
  static let bar = MathAccent("bar", Chars.bar)
  static let check = MathAccent("check", Chars.check)
  static let dot = MathAccent("dot", Chars.dotAbove)
  static let ddot = MathAccent("ddot", Chars.ddotAbove)
  static let breve = MathAccent("breve", Chars.breve)
  static let grave = MathAccent("grave", Chars.grave)
  static let hat = MathAccent("hat", Chars.hat)
  static let mathring = MathAccent("mathring", Chars.ocirc)
  static let overbar = MathAccent("overbar", Chars.overbar)
  static let ovhook = MathAccent("ovhook", Chars.ovhook)
  static let tilde = MathAccent("tilde", Chars.tilde)
  static let widecheck = MathAccent("widecheck", Chars.check, true)
  static let widebreve = MathAccent("widebreve", Chars.breve, true)
  static let widehat = MathAccent("widehat", Chars.hat, true)
  static let wideoverbar = MathAccent("wideoverbar", Chars.overbar, true)
  static let widetilde = MathAccent("widetilde", Chars.tilde, true)
  static let vec = MathAccent("vec", Chars.rightArrowAbove, true)
}

extension MathAccent {
  enum Compressed: Codable {
    case predefined(String)
    case custom(MathAccent)

    func decompressed() -> MathAccent {
      switch self {
      case .predefined(let command):
        return MathAccent.lookup(command)!
      case .custom(let accent):
        return accent
      }
    }
  }

  func compressed() -> Compressed {
    if let predefined = MathAccent.lookup(command) {
      return .predefined(predefined.command)
    }
    else {
      return .custom(self)
    }
  }
}
