// Copyright 2024-2025 Lie Yan

import Foundation

struct MathOverSpreader: Codable {
  let command: String
  let spreader: Character

  init(_ command: String, _ spreader: Character) {
    self.command = command
    self.spreader = spreader
  }

  private enum CodingKeys: String, CodingKey {
    case command
    case spreader
  }

  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.command = try container.decode(String.self, forKey: .command)

    let spreaderString = try container.decode(String.self, forKey: .spreader)
    guard let spreader = spreaderString.first else {
      throw DecodingError.dataCorruptedError(
        forKey: .spreader, in: container,
        debugDescription: "Invalid spreader character")
    }
    self.spreader = spreader
  }

  func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(command, forKey: .command)
    try container.encode(String(spreader), forKey: .spreader)
  }
}

struct MathUnderSpreader: Codable {
  let command: String
  let spreader: Character

  init(_ command: String, _ spreader: Character) {
    self.command = command
    self.spreader = spreader
  }

  private enum CodingKeys: String, CodingKey {
    case command
    case spreader
  }

  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.command = try container.decode(String.self, forKey: .command)

    let spreaderString = try container.decode(String.self, forKey: .spreader)
    guard let spreader = spreaderString.first else {
      throw DecodingError.dataCorruptedError(
        forKey: .spreader, in: container,
        debugDescription: "Invalid spreader character")
    }
    self.spreader = spreader
  }

  func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(command, forKey: .command)
    try container.encode(String(spreader), forKey: .spreader)
  }
}

extension MathOverSpreader {
  static let predefinedCases: [MathOverSpreader] = [
    .overbrace,
    .overbracket,
    .overparen,
  ]

  private static let _dictionary: [String: MathOverSpreader] =
    Dictionary(uniqueKeysWithValues: predefinedCases.map { ($0.command, $0) })

  static func lookup(_ command: String) -> MathOverSpreader? {
    _dictionary[command]
  }

  static let overbrace = MathOverSpreader("overbrace", "⏞")
  static let overbracket = MathOverSpreader("overbracket", "⎴")
  static let overparen = MathOverSpreader("overparen", "⏜")
}

extension MathUnderSpreader {
  static let predefinedCases: [MathUnderSpreader] = [
    .underbrace,
    .underbracket,
    .underparen,
  ]

  private static let _dictionary: [String: MathUnderSpreader] =
    Dictionary(uniqueKeysWithValues: predefinedCases.map { ($0.command, $0) })

  static func lookup(_ command: String) -> MathUnderSpreader? {
    _dictionary[command]
  }

  static let underbrace = MathUnderSpreader("underbrace", "⏟")
  static let underbracket = MathUnderSpreader("underbracket", "⎵")
  static let underparen = MathUnderSpreader("underparen", "⏝")
}
